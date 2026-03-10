from py4godot.methods import private
from py4godot.signals import signal, SignalArg
from py4godot.classes import gdclass
from py4godot.classes.core import Vector3
from py4godot.classes.Control import Control
import sqlite3
from employee import Employee

@gdclass
class test_database(Control):
	
	def _ready(self) -> None:  #bleh
		print("hello")
		conn = sqlite3.connect('employee.db')
		print(conn)
		c = conn.cursor()
		
		#c.execute("""CREATE TABLE employees (
		#	first text,
		#	last text,
		#	pay integer
		#	)""")
		
		emp_1 = Employee('John', 'Doe', 80000)
		emp_2 = Employee('Jane', 'Doe', 90000)
		
		print(emp_1.first)
		print(emp_1.last)
		print(emp_1.pay)
		
		#c.execute("INSERT INTO employees VALUES ('corey', 'schafer', 50000)")
		
		c.execute("SELECT * FROM employees WHERE last='Schafer'")
		
		print(c.fetchone())
		conn.commit()
		
		conn.close()
		
		
		
		
		
		
	def _process(self, delta:float) -> None:
		pass
		# put dynamic code here


#control._ready(conn)
