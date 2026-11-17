extends "res://tools/level_builder.gd"
## Builds level 1-B, The Keep Gate: region 1's boss level. A BLOCKOUT.
##
##   godot --headless --path game --script res://tools/build_l1_b.gd
##
## Spec: design/levels/1-B_keep_gate.md. A short approach (a terrace, two
## stones over water, a rat), the midway banner, then the arena: the Keep's
## outer courtyard, 40 tiles of flat ground with a raised ledge at each end.
## **The boss, the Keep's fallen warden, is not built**: the arena is empty
## and the way out is open. 160 x 40 tiles.

const ROOM_PATH := "res://scenes/levels/l1_b_keep_gate.tscn"
const ROOM := Rect2i(0, 0, 160, 40)
const G := 30
const WATER_Y := 512.0


func _t(x: float) -> float:
	return x * TILE


func _initialize() -> void:
	room = ROOM
	rock = [
		[0, G, 160, 10, 0],        # the road, the courtyard
		[14, 27, 8, 3, 0],         # a terrace (3 up)
		[100, 27, 6, 3, 0],        # the arena's west ledge (3 up)
		[134, 27, 6, 3, 0],        # and its east ledge
	]
	spaces = [[36, G, 20, 10]]     # the moat
	masses = []
	skip = []
	spawn = Vector2(5 * TILE, G * TILE)
	room_path = ROOM_PATH
	blockout = true
	main_floor = G * TILE

	tour.append_array([["walk", 10], ["rise", 14, 22, 27], ["off", 22, G, 1], ["walk", 33]])
	plan_leg(36, G, 1, [[4, 4, 1, "stone"], [4, 4, 1, "stone"], [4, 10, -2, "none"]])
	tour.append_array([["walk", 95], ["banner"], ["rise", 100, 106, 27], ["off", 106, G, 1], ["walk", 131],
		["rise", 134, 140, 27], ["off", 140, G, 1], ["end", 1]])

	_level_begin("L1_B_KeepGate", "1-B The Keep Gate")
	_water_foreground(WATER_Y, [[0.0, _t(160)]])
	_place_arcs("l1b_arc")
	_label("START", Vector2(_t(3), _t(G) - 40))
	_label("THE APPROACH", Vector2(_t(30), _t(18)))
	_lunger(_t(74), _t(G), _t(64), _t(84), "rat")
	_checkpoint(_t(90), _t(G), "l1b_mid")
	_label("MIDWAY BANNER", Vector2(_t(88), _t(G) - 84))
	_label("THE ARENA: the Keep's outer courtyard\nTHE KEEP'S FALLEN WARDEN (the boss is not built yet)", Vector2(_t(104), _t(16)))
	_level_end(_t(150), _t(G), 48, 72)
	shots = [["01_approach", 30, G, 1], ["02_banner_arena", 104, 27, 1], ["03_arena_way_out", 136, 27, 1]]
	_level_finish()
	quit()
