
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
		#store id
		command1 = """create table if not exists
		stores(store_id integer primary key, location text)"""
		
		cursor.execute(command1)
		# purchasing table
		command2 = """create table if not exists
		purchases(purchase_id integer primary key, store_id integer, total_cost float, foreign key(store_id) references stores(store_id))"""
		
		cursor.execute(command2)
		#add to stores
		cursor.execute("insert into stores values(21, 'Minneapolis, MN')") 
		cursor.execute("insert into stores values(95, 'Chicago, IL')")
		cursor.execute("insert into stores values(64, 'Iowa City, IA')")
		#add to purchases
		cursor.execute("insert into purchases values(54, 21, 15.49)")
		cursor.execute("insert into purchases values(23, 64, 21.12)")
		#get results
		cursor.execute("select * from purchases")
		
		results = cursor.fetchall()
		print(results)
		
		#update
		cursor.execute("update purchases set total_cost = 3.67 where purchase_id = 54")
		#delete
		cursor.execute("delete from purchases where purchase_id = 54")
		
		
		
	def _process(self, delta:float) -> None:
		pass
		# put dynamic code here
