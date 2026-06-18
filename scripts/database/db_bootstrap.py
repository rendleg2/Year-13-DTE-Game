# db_bootstrap.py
#
# py4godot autoload. Register it under Project Settings > Globals > Autoload
# with the node name "DB". py4godot requires the class name to match the
# file name, so this file must stay named db_bootstrap.py.
#
# Its only jobs at startup: resolve a writable path, open the shared database,
# and seed/refresh static content. After that, ANY other Python script reaches
# the data by importing game_db directly (the connection is a module-level
# singleton shared across the single Python interpreter) -- no get_pyscript()
# needed:
#
#     import game_db
#     game_db.add_to_inventory(2, 3)
#     print(game_db.get_inventory())

import os

from py4godot.classes import gdclass
from py4godot.classes.Node import Node
from py4godot.classes.ProjectSettings import ProjectSettings

from database import get_db
import game_db


@gdclass
class db_bootstrap(Node):

	def _ready(self) -> None:
		# 1. Turn Godot's virtual user:// path into a real OS path. user:// is
		#    the writable per-user location and survives export; res:// would be
		#    read-only inside the packed .pck. Engine singletons in py4godot are
		#    reached via .instance().
		os_path = ProjectSettings.instance().globalize_path("user://game.db")

		# 2. Godot normally creates user:// already, but make sure the parent
		#    folder exists before sqlite opens the file.
		os.makedirs(os.path.dirname(os_path), exist_ok=True)

		# 3. Open the shared connection. Every other script gets this same
		#    instance from game_db / get_db().
		db = get_db(os_path)

		# 4. Make sure tables exist, and (re)seed static content when the
		#    bundled CONTENT_VERSION differs from what's stored. Player progress
		#    is left untouched.
		game_db.ensure_schema(db)
		if game_db.needs_seeding(db):
			game_db.seed_content(db)
			print("DB: seeded content to version", game_db.CONTENT_VERSION)

		print("DB ready at", os_path)
