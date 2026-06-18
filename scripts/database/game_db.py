"""
Game data layer for a py4godot shooter: four tables + their APIs.

Builds on the generic engine in database.py. NO Godot/py4godot imports, so the
whole layer runs and tests in plain CPython (see the bottom of this file).

The four tables
---------------
1. save_state   (lives in database.py) - flexible key/value store. Save ANY
				JSON-serialisable variable: numbers, strings, lists, whole dicts.
				API: save(), load(), delete_save(), all_saves().
2. enemies      - one row per enemy type, columns matching your stat block. NUMERIC
				columns preserve your exact int/float values on read.
3. cards        - ROUNDS-style upgrade pool. Metadata + a JSON `effects` map of
				stat -> {op, amount}, so effects are explicit and easy to apply.
4. player_stats - a long-format stat LOG (one row per stat per snapshot). Built for
				three jobs: a current overview, time-series graphs, and balancing
				aggregates.

enemies + cards are static content seeded from the Python definitions below.
save_state + player_stats start empty and fill during play.
"""

import json
from database import get_db, close_db

# Bump whenever you change ENEMIES or CARDS; the bootstrap re-seeds on change.
CONTENT_VERSION = 1
print("test")

# --------------------------------------------------------------------------
# Schema
# --------------------------------------------------------------------------
SCHEMA = """
-- (1) save_state is created by database.py; shown here for reference:
--     CREATE TABLE save_state (key TEXT PRIMARY KEY, value TEXT NOT NULL);

-- (2) enemy types. NUMERIC keeps ints as ints and floats as floats.
CREATE TABLE IF NOT EXISTS enemies (
	type           TEXT PRIMARY KEY,
	damage         NUMERIC NOT NULL DEFAULT 0,
	health         NUMERIC NOT NULL DEFAULT 0,
	bullets        INTEGER NOT NULL DEFAULT 0,
	spread         NUMERIC NOT NULL DEFAULT 0,
	movement_speed NUMERIC NOT NULL DEFAULT 0,
	bullet_speed   NUMERIC NOT NULL DEFAULT 0,
	firerate       NUMERIC NOT NULL DEFAULT 0
);

-- (3) card upgrades. `effects` is JSON: {stat: {"op": "add|mult|set", "amount": n}}
CREATE TABLE IF NOT EXISTS cards (
	id          TEXT PRIMARY KEY,
	name        TEXT NOT NULL,
	rarity      TEXT NOT NULL DEFAULT 'common',
	description TEXT NOT NULL DEFAULT '',
	effects     TEXT NOT NULL DEFAULT '{}'
);

-- (4) stat snapshots, long format. One row = one stat at one moment.
CREATE TABLE IF NOT EXISTS player_stats (
	id          INTEGER PRIMARY KEY AUTOINCREMENT,
	label       TEXT NOT NULL,                       -- "round_3", "wave_5", a run id...
	recorded_at TEXT NOT NULL DEFAULT (datetime('now')),
	stat        TEXT NOT NULL,
	value       REAL NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_pstats_stat  ON player_stats(stat);
CREATE INDEX IF NOT EXISTS idx_pstats_label ON player_stats(label);
"""


# --------------------------------------------------------------------------
# Static content -- edit these, then bump CONTENT_VERSION
# --------------------------------------------------------------------------
ENEMIES = {
	"normal": {"damage": 10, "health": 150, "bullets": 1, "spread": 0, "movement_speed": 60,"bullet_speed": 100, "firerate": 0.6},
	"boss": {"damage": 10, "health": 1000, "bullets": 20, "spread": 360, "movement_speed": 10, "bullet_speed": 75, "firerate": 1},
	"shotgun": {"damage": 2, "health": 200, "bullets": 5, "spread": 20, "movement_speed": 60, "bullet_speed": 100, "firerate": 1}
}

# Effects use explicit ops so balancing math is unambiguous:
#   "mult" multiplies the stat, "add" adds to it, "set" overrides it.
CARDS = [
	{"id": "berserker", "name": "Berserker", "rarity": "rare",
	 "description": "+30% damage", "effects": {"damage": {"op": "mult", "amount": 1.3}}},
	{"id": "splitshot", "name": "Splitshot", "rarity": "common",
	 "description": "+1 bullet", "effects": {"bullets": {"op": "add", "amount": 1}}},
	{"id": "bouncy", "name": "Bouncing Bullets", "rarity": "uncommon",
	 "description": "Bullets bounce twice", "effects": {"bounces": {"op": "add", "amount": 2}}},
	{"id": "tank_up", "name": "Tank", "rarity": "common",
	 "description": "+50% health, -10% move speed",
	 "effects": {"health": {"op": "mult", "amount": 1.5},
				 "movement_speed": {"op": "mult", "amount": 0.9}}},
	{"id": "rapid_fire", "name": "Rapid Fire", "rarity": "uncommon",
	 "description": "+25% fire rate", "effects": {"firerate": {"op": "mult", "amount": 1.25}}},
]


# --------------------------------------------------------------------------
# Seeding / migration
# --------------------------------------------------------------------------
def ensure_schema(db=None) -> None:
	"""Create any missing tables. Idempotent; safe every launch."""
	(db or get_db()).script(SCHEMA)


def seed_content(db=None) -> None:
	"""Materialise ENEMIES and CARDS into the database (in-place upsert)."""
	db = db or get_db()
	ensure_schema(db)

	for etype, s in ENEMIES.items():
		db.execute("""
			INSERT INTO enemies
				(type, damage, health, bullets, spread, movement_speed, bullet_speed, firerate)
			VALUES (?,?,?,?,?,?,?,?)
			ON CONFLICT(type) DO UPDATE SET
				damage=excluded.damage, health=excluded.health, bullets=excluded.bullets,
				spread=excluded.spread, movement_speed=excluded.movement_speed,
				bullet_speed=excluded.bullet_speed, firerate=excluded.firerate
		""", [etype, s["damage"], s["health"], s["bullets"], s["spread"],
			  s["movement_speed"], s["bullet_speed"], s["firerate"]])

	for c in CARDS:
		db.execute("""
			INSERT INTO cards (id, name, rarity, description, effects)
			VALUES (?,?,?,?,?)
			ON CONFLICT(id) DO UPDATE SET
				name=excluded.name, rarity=excluded.rarity,
				description=excluded.description, effects=excluded.effects
		""", [c["id"], c["name"], c["rarity"], c["description"], json.dumps(c["effects"])])

	db.set_state("__content_version__", CONTENT_VERSION)


def needs_seeding(db=None) -> bool:
	return (db or get_db()).get_state("__content_version__", 0) != CONTENT_VERSION


# --------------------------------------------------------------------------
# (1) Save store -- store any variables you want
# --------------------------------------------------------------------------
def save(key: str, value) -> None:
	"""Persist any JSON-serialisable value (int, str, list, dict, ...)."""
	get_db().set_state(key, value)


def load(key: str, default=None):
	return get_db().get_state(key, default)


def delete_save(key: str) -> None:
	get_db().delete_state(key)


def all_saves() -> dict:
	"""Everything in the save store -- handy for a debug/overview screen."""
	rows = get_db().query("SELECT key, value FROM save_state ORDER BY key")
	return {r["key"]: json.loads(r["value"]) for r in rows}


# --------------------------------------------------------------------------
# (2) Enemies
# --------------------------------------------------------------------------
_ENEMY_STATS = ("damage", "health", "bullets", "spread",
				"movement_speed", "bullet_speed", "firerate")


def get_enemy(enemy_type: str):
	"""One enemy's stat block as a dict (your exact format), or None."""
	row = get_db().query_one("SELECT * FROM enemies WHERE type = ?", [enemy_type])
	return {k: row[k] for k in _ENEMY_STATS} if row else None


def get_all_enemies() -> dict:
	"""All enemies as {type: {stat: value, ...}} -- your exact format."""
	rows = get_db().query("SELECT * FROM enemies ORDER BY type")
	return {r["type"]: {k: r[k] for k in _ENEMY_STATS} for r in rows}


def set_enemy(enemy_type: str, stats: dict) -> None:
	"""Add or live-tune an enemy type at runtime (e.g. from a debug console)."""
	merged = {**(get_enemy(enemy_type) or {k: 0 for k in _ENEMY_STATS}), **stats}
	get_db().execute("""
		INSERT INTO enemies
			(type, damage, health, bullets, spread, movement_speed, bullet_speed, firerate)
		VALUES (?,?,?,?,?,?,?,?)
		ON CONFLICT(type) DO UPDATE SET
			damage=excluded.damage, health=excluded.health, bullets=excluded.bullets,
			spread=excluded.spread, movement_speed=excluded.movement_speed,
			bullet_speed=excluded.bullet_speed, firerate=excluded.firerate
	""", [enemy_type] + [merged[k] for k in _ENEMY_STATS])


# --------------------------------------------------------------------------
# (3) Cards
# --------------------------------------------------------------------------
def _card_row_to_dict(r):
	return {"id": r["id"], "name": r["name"], "rarity": r["rarity"],
			"description": r["description"], "effects": json.loads(r["effects"])}


def get_card(card_id: str):
	r = get_db().query_one("SELECT * FROM cards WHERE id = ?", [card_id])
	return _card_row_to_dict(r) if r else None


def list_cards(rarity: str = None):
	if rarity is None:
		rows = get_db().query("SELECT * FROM cards ORDER BY id")
	else:
		rows = get_db().query("SELECT * FROM cards WHERE rarity = ? ORDER BY id", [rarity])
	return [_card_row_to_dict(r) for r in rows]


def apply_card_effects(base_stats: dict, card_ids: list) -> dict:
	"""Apply a list of owned cards to a base stat block -> effective stats.

	This is the bridge between cards and balancing: feed it a player's base
	stats and their owned cards to get the real numbers to display or graph.
	"""
	result = dict(base_stats)
	for cid in card_ids:
		card = get_card(cid)
		if not card:
			continue
		for stat, eff in card["effects"].items():
			op, amount = eff["op"], eff["amount"]
			current = result.get(stat, 0)
			if op == "add":
				result[stat] = current + amount
			elif op == "mult":
				result[stat] = current * amount
			elif op == "set":
				result[stat] = amount
	return result


# --------------------------------------------------------------------------
# (4) Player stats -- overview + graphs + balancing
# --------------------------------------------------------------------------
def record_stats(label: str, stats: dict) -> None:
	"""Write a snapshot: one row per stat, all tagged with `label` and a timestamp."""
	db = get_db()
	for stat, value in stats.items():
		db.execute("INSERT INTO player_stats (label, stat, value) VALUES (?,?,?)",
				   [label, stat, float(value)])


def get_overview() -> dict:
	"""Current value of every tracked stat (latest recorded wins). For a stats screen."""
	rows = get_db().query("""
		SELECT stat, value FROM player_stats p
		WHERE id = (SELECT MAX(id) FROM player_stats WHERE stat = p.stat)
		ORDER BY stat
	""")
	return {r["stat"]: r["value"] for r in rows}


def get_snapshot(label: str) -> dict:
	"""All stats recorded under one label (e.g. a single round)."""
	rows = get_db().query(
		"SELECT stat, value FROM player_stats WHERE label = ? ORDER BY id", [label])
	return {r["stat"]: r["value"] for r in rows}


def get_stat_series(stat: str):
	"""A stat's values over time -> ready to plot. [{label, recorded_at, value}, ...]."""
	return get_db().query("""
		SELECT label, recorded_at, value
		FROM player_stats WHERE stat = ? ORDER BY id
	""", [stat])


def list_recorded_stats():
	return [r["stat"] for r in
			get_db().query("SELECT DISTINCT stat FROM player_stats ORDER BY stat")]


# --------------------------------------------------------------------------
# Standalone test -- no Godot:  python3 game_db.py
# --------------------------------------------------------------------------
if __name__ == "__main__":
	import tempfile, os
	path = os.path.join(tempfile.gettempdir(), "shooter_db_test.db")
	for suffix in ("", "-wal", "-shm"):
		if os.path.exists(path + suffix):
			os.remove(path + suffix)

	db = get_db(path)
	seed_content(db)

	print("== (1) SAVE: any variables ==")
	save("player_pos", {"x": 320.5, "y": 96.0})
	save("difficulty", "hard")
	save("owned_cards", ["berserker", "splitshot", "rapid_fire"])
	print("loaded owned_cards:", load("owned_cards"))
	print("all saves         :", all_saves())

	print("\n== (2) ENEMIES: exact format ==")
	print("normal            :", get_enemy("normal"))
	print("all (keys)        :", list(get_all_enemies().keys()))
	# a balancing query straight off the table:
	rows = db.query("SELECT type, health FROM enemies ORDER BY health DESC")
	print("by health         :", [(r["type"], r["health"]) for r in rows])

	print("\n== (3) CARDS ==")
	print("uncommon cards    :", [c["id"] for c in list_cards("uncommon")])
	print("berserker         :", get_card("berserker"))

	print("\n== bridge: cards -> effective stats ==")
	base = {"damage": 20, "health": 100, "bullets": 1, "firerate": 0.5, "movement_speed": 100}
	owned = load("owned_cards")
	effective = apply_card_effects(base, owned)
	print("base              :", base)
	print("with cards", owned, "->")
	print("effective         :", {k: round(v, 2) for k, v in effective.items()})

	print("\n== (4) PLAYER STATS: overview + graph + balancing ==")
	# imagine recording the player's effective stats each round
	for rnd, dmg_cards in enumerate([[], ["berserker"], ["berserker", "splitshot"]], start=1):
		eff = apply_card_effects(base, dmg_cards)
		eff["dps"] = eff["damage"] * eff["bullets"] / eff["firerate"]
		record_stats(f"round_{rnd}", eff)

	print("overview (latest) :", {k: round(v, 2) for k, v in get_overview().items()})
	print("tracked stats     :", list_recorded_stats())
	print("dps over rounds   :",
		  [(r["label"], round(r["value"], 1)) for r in get_stat_series("dps")])

	close_db()
	print("\nOK -- database file at", path)
