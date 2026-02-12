
from py4godot.methods import private
from py4godot.signals import signal, SignalArg
from py4godot.classes import gdclass
from py4godot.classes.core import Vector3
from py4godot.classes.Control import Control
import sqlite3
	#howdy

@gdclass
class control(Control):

	def _ready(self) -> None:  #bleh
		connection = sqlite3.connect('store_transaction.db')
		cursor = connection.cursor()
		#different
		command1 = """create table if not exists
		stores(store_id integer primary key, location text)"""
		cursor.execute(command1)
		# purchasing table
		#command2 = """create table if not exists
		#purchases(purchase_id integer primary key, """
	def _process(self, delta:float) -> None:
		pass
		# put dynamic code here
