
from py4godot.methods import private
from py4godot.signals import signal, SignalArg
from py4godot.classes import gdclass
from py4godot.classes.core import Vector3
from py4godot.classes.Node import Node
import sqlite3

@gdclass
class stats_database(Node):
	def _ready(self) -> None:
		self.conn = sqlite3.connect('stats.db')
		self.cursor = self.conn.cursor()
		c = self.conn.cursor()
		print(c)
		self.cursor.execute("""CREATE TABLE IF NOT EXISTS stats (
			id INTEGER PRIMARY KEY,
			health INT
		)""")
		self.cursor.execute("SELECT health FROM stats WHERE id = 1")
		if self.cursor.fetchone() is None:
			self.cursor.execute("INSERT INTO stats (id, health) VALUES (1,100)")
			self.conn.commit()
		def update_health(self, new_health_value: int) -> None:
				"""Call this function whenever health changes"""
				self.cursor.execute("UPDATE stats SET health = ? WHERE id = 1", (new_health_value,))
				self.conn.commit()
				print(f"Database Updated: Health is now {new_health_value}")
		def get_health(self) ->int:
			"""Call this to load the health from the database"""
			self.cursor.execute("Select health from stats where id = 1")
			
