import sqlite3

conn = sqlite3.connect("items.db")
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS shop_items (
	id INTEGER PRIMARY KEY,
	name TEXT,
	description TEXT,
	effect TEXT,
	value REAL,
	image_path TEXT
)
""")

items = [
	("Speed", "Move faster", "speed", 25, "res://speed.png"),
	("Damage", "More damage", "bullet_damage", 5, "res://damage.png"),
	("Fire Rate", "Shoot faster", "fire_rate", -0.03, "res://fire.png")
]

cursor.executemany("""
INSERT INTO shop_items (name, description, effect, value, image_path)
VALUES (?, ?, ?, ?, ?)
""", items)

conn.commit()
conn.close()
