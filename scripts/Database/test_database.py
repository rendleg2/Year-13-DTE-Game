
from py4godot.methods import private
from py4godot.signals import signal, SignalArg
from py4godot.classes import gdclass
from py4godot.classes.core import Vector3
from py4godot.classes.Control import Control
import sqlite3
@gdclass
class test_database(Control):

	# define properties like this
	test_int: int = 5
	test_float: float = 5.2
	test_bool: bool = True
	test_vector: Vector3 = Vector3.new3(1,2,3)

	# define signals like this
	test_signal = signal([SignalArg("test_arg", int)])


	def _ready(self) -> None:

		conn = sqlite3.connect('employee.db')
		c = conn.cursor()
		print(c)
		#c.execute("""CREATE TABLE employees (
		#	first text,
		#	last text,
		#	pay integer
		#	)""")
		
		#c.execute("INSERT INTO employees VALUES ('Mary', 'Schafer', 70000)")
		
		#conn.commit()
		
		c.execute("SELECT * FROM employees WHERE last='Schafer'")
		
		print(c.fetchall())
		
		conn.commit()
		
		conn.close()
		
		

	def _process(self, delta:float) -> None:
		pass
		# put dynamic code here

	# Hide the method in the godot editor
	@private
	def test_method(self):
		pass
