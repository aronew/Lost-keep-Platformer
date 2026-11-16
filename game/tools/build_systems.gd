extends "res://tools/level_builder.gd"
## Builds the systems arena: one of every level system in a short strip, for
## the systems tests (`playtest room=sys mode=systems`) and for trying them by
## hand. Not a level of the game.
##
##   godot --headless --path game --script res://tools/build_systems.gd
##
## West to east (tiles; the floor is row 20): the start, a thorn bed, the first
## checkpoint, a row of beads, a pit, a chest, a Thornhound's stretch, the
## second checkpoint, a crate and a cracked wall into a bonus room, a moving
## platform over a long pit, a pool, a cocoon, and the level's end.

const ROOM_PATH := "res://scenes/levels/systems_arena.tscn"
const FLOOR := 320.0

const ROOM := Rect2i(0, 0, 150, 24)
const ROCK := [
	[0, 20, 150, 4, 0],     # the floor
	[76, 16, 14, 4, 0],     # the block with the bonus room inside
]
const SPACES := [
	[30, 20, 4, 4],         # a pit
	[76, 17, 2, 3],         # the cracked wall's mouth (the wall fills it)
	[78, 17, 9, 3],         # the bonus room
	[92, 20, 14, 4],        # the long pit under the moving platform
	[112, 20, 4, 4],        # the pool
]


func _initialize() -> void:
	room = ROOM
	rock = ROCK
	spaces = SPACES
	masses = []
	skip = []
	spawn = Vector2(3 * TILE, FLOOR)
	room_path = ROOM_PATH
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://scenes/levels"))
	_level_begin("SystemsArena", "Systems arena")
	_thorns(8 * TILE, 11 * TILE, FLOOR)
	_checkpoint(16 * TILE, FLOOR, "sys_cp1")
	_beads([Vector2(21 * TILE, FLOOR - 12), Vector2(23 * TILE, FLOOR - 12), Vector2(25 * TILE, FLOOR - 12), Vector2(27 * TILE, FLOOR - 12)], "sys_b")
	_chest(37 * TILE, FLOOR, 6, "sys_chest")
	_thornhound(54 * TILE, FLOOR, 44 * TILE, 62 * TILE)
	_checkpoint(64 * TILE, FLOOR, "sys_cp2")
	_crate(69 * TILE, FLOOR)
	_cracked_wall(Rect2i(76, 17, 2, 3), "sys_crack")
	_bonus_room(Rect2(78 * TILE, 17 * TILE, 9 * TILE, 3 * TILE),
		[Vector2(80 * TILE, FLOOR - 10), Vector2(82 * TILE, FLOOR - 10), Vector2(84 * TILE, FLOOR - 10), Vector2(86 * TILE, FLOOR - 26)],
		Vector2(85 * TILE, FLOOR - 2), "sys_bonus", "sys_cocoon_bonus", "the arena's keeper", 10.0, 34.0)
	_mover(Vector2(92 * TILE, FLOOR), 48.0, [Vector2(0, 0), Vector2(160, 0)], 50.0, 0.5, true)
	_water("Pool", Vector2(112 * TILE, FLOOR + 6), Vector2(4 * TILE, 4 * TILE - 6), Vector2(20, 20))
	_cocoon(Vector2(122 * TILE, FLOOR - 4), "sys_cocoon", "a test villager")
	_level_end(140 * TILE, FLOOR, 48, 72)
	_label("thorns", Vector2(8 * TILE, FLOOR - 40))
	_label("pit", Vector2(30 * TILE, FLOOR - 40))
	_label("hound", Vector2(50 * TILE, FLOOR - 60))
	_label("bonus room", Vector2(79 * TILE, 15 * TILE - 4))
	_level_finish()
	quit()
