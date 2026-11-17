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
	[0, 20, 9, 8, 0],
	# The mound: block steps up its west side, its top, a steep east side.
	[9, 19, 2, 9, 0], [11, 18, 2, 10, 0], [13, 17, 5, 11, 0],
	# Low rocky ground under the log, just above the water.
	[18, 21, 5, 7, 0],
	# The great block: a step up its west foot, its top, a ledge east of it.
	[22, 20, 1, 8, 0], [23, 17, 5, 11, 0], [28, 19, 2, 9, 0],
	# The low ground east of it, the waterfall's gap, and on to the pillar.
	[30, 20, 5, 8, 0], [36, 20, 2, 8, 0],
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
	_canopy(17.6 * TILE, 23.0 * TILE, 19.0 * TILE, false)
	for p in [["flowers", 6.5, 20], ["fern", 8.2, 20], ["mushrooms", 15.0, 17], ["flowers_b", 16.6, 17],
			["mushroom_big", 25.6, 17], ["mushroom_b", 27.0, 17], ["flowers", 24.2, 17], ["grass", 29.0, 19],
			["fern_tall", 32.0, 20], ["flowers_b", 33.8, 20], ["flowers", 39.0, 15]]:
		_sanct_plant(behind, p[0], p[1], p[2])
	_lunger(32.5 * TILE, G, 30.5 * TILE, 34.5 * TILE, "rat")
	# Under the water: drowned stone and weeds, lily pads on it.
	var k := 0
	for sx in [60.0, 250.0, 330.0, 470.0, 560.0]:
		var sd := _sanct(["sunk_a", "sunk_c", "sunk_b", "sunk_d"][k % 4])
		_underwater(sd["tex"], sd["rect"], Vector2(sx, WATER_Y + 34.0 + float((k * 11) % 14)), k % 2 == 1)
		var wd := _sanct(["weed_a", "weed_c", "weed_b"][k % 3])
		_underwater(wd["tex"], wd["rect"], Vector2(sx + 60.0, WATER_Y + 40.0))
		k += 1
	_sanct_midground(G, WATER_Y, 40.0 * TILE)
	_level_finish()
	quit()
