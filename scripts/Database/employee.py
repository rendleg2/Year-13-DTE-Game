
from py4godot.methods import private
from py4godot.signals import signal, SignalArg
from py4godot.classes import gdclass
from py4godot.classes.core import Vector3
from py4godot.classes.Node import Node
import sqlite3

@gdclass
class employee(Node):
	def _ready(self) -> None:
		pass
		# put initialization code here
class Employee:
	"""A sample Employee class"""
	def __init__(self, first, last, pay):
		self.first = first
		self.last = last
		self.pay = pay
		
		@property
		def email(self):
			return '{}.{}@email.com'.format(self.first, self.last)
		
		@property
		def fullname(self):
			return '{} {}'.format(self.first, self.last)
			
		def __repr__(self):
			return "Employee('{}', '{}', {})".format(self.first, self.last, self.pay)



	
