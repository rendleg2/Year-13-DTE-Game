
from py4godot.methods import private
from py4godot.signals import signal, SignalArg
from py4godot.classes import gdclass
from py4godot.classes.core import Vector3
from py4godot.classes.Control import Control
import sqlite3
from scripts.Database.employee import Employee
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
		
		conn = sqlite3.connect('employee.db') #you can change to ':memory:' for no errors
		c = conn.cursor()
		print(c)
		#c.execute("""CREATE TABLE employees (
			#first text,
			#last text,
			#pay integer
			#)""")
				
		def insert_emp(emp):
			with conn:
				c.execute("INSERT INTO employees VALUES (:first, :last, :pay)", {'first': emp.first, 'last': emp.last, 'pay': emp.pay})
				
		def get_emps_by_name(lastname):
			c.execute("SELECT * FROM employees WHERE last=:last", {'last': lastname})
			return c.fetchall()
		def update_pay(emp, pay):
			with conn:
				c.execute("""update employees set pay = :pay
					where first = :first and last = :last""",
					{'first': emp.first, 'last': emp.last, 'pay': pay})
				
		def remove_emp(emp):
			with conn:
				c.execute("delete from employees where first = :first and last = :last",
				{'first': emp.first, 'last': emp.last})
			
		emp_1 = Employee('John', 'Doe', 80000)
		emp_2 = Employee('Jane', 'Doe', 90000)
			
			#print(emp_1.first)
			#print(emp_1.last)
			#print(emp_1.pay,)
			
		insert_emp(emp_1)
		insert_emp(emp_2)
		
		emps = get_emps_by_name('Doe')
		print(emps)
		
		update_pay(emp_2, 95000)
		remove_emp(emp_1)
			
		emps = get_emps_by_name('Doe')
		print(emps)
		
		conn.close()
			
			

	def _process(self, delta:float) -> None:
		pass
			# put dynamic code here

		# Hide the method in the godot editor
		@private
		def test_method(self):
			pass
