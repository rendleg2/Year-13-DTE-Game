"""
Portable SQLite database core for a Godot 4 game (Python plugin).

This module has NO Godot dependencies, so it runs and tests in plain CPython and
behaves identically under any Python-for-Godot binding (py4godot,
godot-python-extension, etc.) -- they all run real CPython with sqlite3.

The Godot-specific part (resolving a *writable* path) lives in the bootstrap
script, kept separate so this file stays testable on its own.

Headline feature: set_state / get_state give you a JSON-backed key/value store.
That is the simplest robust way to save/load arbitrary game data -- numbers,
strings, lists, or whole dictionaries -- without designing a schema up front.
"""

import sqlite3
import json
from typing import Any, Iterable, Optional


class GameDatabase:
	def __init__(self, db_path: str):
		# db_path MUST be a real OS filesystem path. Inside Godot, get it from
		# ProjectSettings.globalize_path("user://game.db") -- never pass a raw
		# "res://" or "user://" string here; Python's sqlite3 can't open those.
		self.path = db_path
		self.conn = sqlite3.connect(db_path)
		self.conn.row_factory = sqlite3.Row          # rows behave like dicts
		self.conn.execute("PRAGMA foreign_keys = ON")
		self.conn.execute("PRAGMA journal_mode = WAL")  # safer writes; see note
		self._ensure_core_tables()

	def _ensure_core_tables(self) -> None:
		# Universal key/value store for save data. Values are JSON text, so any
		# JSON-serialisable Python object can be stored and round-tripped.
		self.conn.execute("""
			CREATE TABLE IF NOT EXISTS save_state (
				key   TEXT PRIMARY KEY,
				value TEXT NOT NULL
			)
		""")
		self.conn.commit()

	# ---------- key/value save API (the easy win) ----------
	def set_state(self, key: str, value: Any) -> None:
		self.conn.execute("""
			INSERT INTO save_state (key, value) VALUES (?, ?)
			ON CONFLICT(key) DO UPDATE SET value = excluded.value
		""", (key, json.dumps(value)))
		self.conn.commit()

	def get_state(self, key: str, default: Any = None) -> Any:
		row = self.conn.execute(
			"SELECT value FROM save_state WHERE key = ?", (key,)).fetchone()
		return json.loads(row["value"]) if row is not None else default

	def delete_state(self, key: str) -> None:
		self.conn.execute("DELETE FROM save_state WHERE key = ?", (key,))
		self.conn.commit()

	# ---------- generic helpers for your own tables ----------
	def script(self, sql: str) -> None:
		"""Run a multi-statement SQL script (e.g. your CREATE TABLE schema)."""
		self.conn.executescript(sql)
		self.conn.commit()

	def execute(self, sql: str, params: Iterable = ()) -> int:
		"""Run a write (INSERT/UPDATE/DELETE). Returns the new row id."""
		cur = self.conn.execute(sql, tuple(params))
		self.conn.commit()
		return cur.lastrowid

	def query(self, sql: str, params: Iterable = ()) -> list[dict]:
		"""Run a SELECT. Returns a list of plain dicts (easy to pass to Godot)."""
		rows = self.conn.execute(sql, tuple(params)).fetchall()
		return [dict(r) for r in rows]

	def query_one(self, sql: str, params: Iterable = ()) -> Optional[dict]:
		row = self.conn.execute(sql, tuple(params)).fetchone()
		return dict(row) if row is not None else None

	def close(self) -> None:
		self.conn.close()


# ---------- module-level singleton so any script shares one connection ----------
_db: Optional[GameDatabase] = None


def get_db(db_path: Optional[str] = None) -> GameDatabase:
	"""Return the shared database, creating it on first call.

	Pass db_path the first time (from the Godot bootstrap). Later calls,
	anywhere in your Python code, can simply do `get_db()`.
	"""
	global _db
	if _db is None:
		if db_path is None:
			raise RuntimeError("get_db() needs db_path on the first call")
		_db = GameDatabase(db_path)
	return _db


def close_db() -> None:
	global _db
	if _db is not None:
		_db.close()
		_db = None


if __name__ == "__main__":
	# Standalone smoke test -- no Godot required. Run: python3 database.py
	import tempfile, os
	tmp = os.path.join(tempfile.gettempdir(), "godot_db_test.db")
	for suffix in ("", "-wal", "-shm"):
		if os.path.exists(tmp + suffix):
			os.remove(tmp + suffix)

	db = get_db(tmp)

	# Save-state demo (the most common use in an existing game)
	db.set_state("player", {"name": "Mara", "hp": 40, "level": 5})
	db.set_state("settings", {"music": 0.8, "fullscreen": True})
	db.set_state("playtime_seconds", 1234)

	print("player   ->", db.get_state("player"))
	print("settings ->", db.get_state("settings"))
	print("playtime ->", db.get_state("playtime_seconds"))
	print("missing  ->", db.get_state("nope", default="(fallback)"))

	# Custom-table demo (when you outgrow key/value)
	db.script("""
		CREATE TABLE IF NOT EXISTS quests (
			id    INTEGER PRIMARY KEY,
			title TEXT NOT NULL,
			done  INTEGER NOT NULL DEFAULT 0
		);
	""")
	db.execute("INSERT INTO quests (title, done) VALUES (?, ?)", ("Lost Cargo", 0))
	db.execute("INSERT INTO quests (title, done) VALUES (?, ?)", ("Find the Map", 1))
	print("quests   ->", db.query("SELECT * FROM quests ORDER BY id"))
	print("open     ->", db.query("SELECT title FROM quests WHERE done = 0"))

	close_db()
	print("\nOK -- database file at", tmp)
