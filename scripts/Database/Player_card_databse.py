
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
		conn = sqlite3.connect('employee.db')
		
		c = conn.cursor()
		
		
		
	def _process(self, delta:float) -> None:
		pass
		# put dynamic code here
