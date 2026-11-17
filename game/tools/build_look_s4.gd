extends "res://tools/level_builder.gd"
## A look test, not a level: the creative lead's mockup S4 ("log and
## pillars", docs/mockups/platformer/flooded_sanctuary/) rebuilt shape for
## shape as one screen, to get the Flooded Sanctuary look right before any
## level is dressed in it. The mockup is 1939 px wide for this 640: one tile
## is 48.5 mockup px; its low ground (mockup y 480) is row 20, its water
## (y 525) row 21.
##
##   godot --headless --path game --script res://tools/build_look_s4.gd

const ROOM_PATH := "res://scenes/levels/look_s4.tscn"
const G := 320.0       # the low ground's walking line (row 20)
const WATER_Y := 338.0 # the water, about a tile under it

const ROOM := Rect2i(0, 0, 40, 28)
const ROCK := [
	# The cavern's roof: real rock, thick at the left, broken toward the right.
	[0, 0, 9, 6, 0], [9, 0, 6, 5, 0], [15, 0, 4, 4, 0], [26, 0, 5, 4, 0], [31, 0, 6, 5, 0], [37, 0, 3, 4, 0],
	# The low ground at the left, the hut on it.
	[0, 20, 10, 8, 0],
	# The mound: a pile, one block up at a time on its west side, a steep
	# crumbling east side.
	[10, 19, 9, 9, 0], [11, 18, 7, 10, 0], [12, 17, 5, 11, 0],
	# Low rocky ground under the log, just above the water.
	[19, 21, 3, 7, 0],
	# The great block: stepped up its west side, its top, ledges down its east.
	[22, 20, 9, 8, 0], [23, 19, 7, 9, 0], [24, 18, 5, 10, 0], [24, 17, 4, 11, 0],
	# The low ground east of it, the waterfall's gap, and on to the pillar.
	[31, 20, 4, 8, 0], [36, 20, 2, 8, 0],
	# The tall pillar at the right edge.
	[38, 15, 2, 13, 0],
]


func _initialize() -> void:
	room = ROOM
	rock = ROCK
	spaces = []
	masses = []
	skip = []
	spawn = Vector2(6.5 * TILE, G)
	room_path = ROOM_PATH
	blockout = false
	kit = "sanctuary"
	main_floor = G
	_level_begin("LookS4", "Look test: S4")
	_water_foreground(WATER_Y, [[0.0, 40.0 * TILE]])
	var behind: Node = _root.get_node("Behind")
	# The hut, its lantern's glow.
	_sanct_ground(behind, "hut", 3.2 * TILE, G)
	_sanct_glow(Vector2(3.2 * TILE + 22.0, G - 44.0))
	# The fallen log from the mound to the great block: a one-way walkway.
	var ld := _sanct("log")
	var lr: Rect2 = ld["rect"]
	var log_art := _sprite(_root.get_node("PlacedArt"), ld["tex"], Rect2(lr.position.x + lr.size.x - 150.0, lr.position.y, 150.0, lr.size.y),
		Vector2(16.4 * TILE, 19.0 * TILE - 12.0))
	log_art.name = "Log"
	_canopy(18.0 * TILE, 23.0 * TILE, 19.0 * TILE, false)
	# Rubble and ferns at the foot of each pile, as in the mockup.
	_sanct_ground(behind, "rubble_steps", 20.2 * TILE, 21.0 * TILE, true).z_index = 2
	_sanct_ground(behind, "rubble_block", 21.3 * TILE, 21.0 * TILE)
	_sanct_ground(behind, "fern_tall", 19.6 * TILE, 21.0 * TILE)
	for p in [["flowers", 6.5, 20], ["mushrooms", 14.5, 17],
			["mushroom_big", 26.2, 17], ["fern_tall", 33.0, 20]]:
		_sanct_plant(behind, p[0], p[1], p[2])
	_lunger(32.5 * TILE, G, 30.5 * TILE, 34.5 * TILE, "rat")
	# Under the water: drowned stone and weeds, lily pads on it.
	_sanct_bed(G, [70.0, 250.0, 440.0, 560.0])
	_sanct_midground(G, WATER_Y, 40.0 * TILE)
	_level_finish()
	quit()
