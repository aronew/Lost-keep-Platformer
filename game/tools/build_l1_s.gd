extends "res://tools/level_builder.gd"
## Builds level 1-S, The Hollow Oak: region 1's secret level. A BLOCKOUT.
##
##   godot --headless --path game --script res://tools/build_l1_s.gd
##
## Spec: design/levels/1-S_hollow_oak.md. Reached by 1-3's secret exit (the
## map's grotto). A short, harder climb inside the Great Ironbark: 60 tiles
## wide and 70 high, two legs. Harder than the region's rule on purpose:
## gaps of 5, landings of 3, and two ledge catches (4 up). A fall never
## kills: she lands on the wood below. At the top, the reward.

const ROOM_PATH := "res://scenes/levels/l1_s_hollow_oak.tscn"
const ROOM := Rect2i(0, 0, 60, 70)
const G := 64


func _t(x: float) -> float:
	return x * TILE


func _initialize() -> void:
	room = ROOM
	rock = [
		[0, G, 60, 6, 0],          # the oak's floor
		[0, 0, 2, 70, 0],          # its walls
		[58, 0, 2, 70, 0],
	]
	spaces = []
	masses = [[54, 41, 4, 3, 0]]   # the turn's step, against the east wall
	skip = []
	spawn = Vector2(5 * TILE, G * TILE)
	room_path = ROOM_PATH
	blockout = true
	main_floor = G * TILE

	# Leg 1, going right: a root, then shelves of bark and fungus.
	var at := plan_leg(8, G, 1, [[0, 5, 3, "solid"], [5, 3, 2], [4, 3, 2], [0, 4, 4], [5, 3, 1], [4, 3, 2], [0, 5, 3], [0, 6, 3]], "float")
	tour.append(["banner"])
	tour.append(["rise", 54, 58, 41])
	at = plan_leg(54, 41, -1, [[4, 4, 2]], "float2")
	# Leg 2, going back left, to the hollow at the top.
	at = plan_leg(at[0], at[1], -1, [[5, 3, 2], [0, 4, 4], [5, 3, 1], [4, 3, 2], [5, 3, 2], [0, 9, 3]], "float")
	var top: int = at[1]
	tour.append(["end", -1])

	_level_begin("L1_S_HollowOak", "1-S The Hollow Oak")
	_place_arcs("l1s_arc")
	_label("START", Vector2(_t(3), _t(G) - 40))
	_label("THE SECRET LEVEL: a harder climb\n(gaps of 5, landings of 3, ledge catches)", Vector2(_t(16), _t(G) - 120))
	_label("LEG 1", Vector2(_t(30), _t(46)))
	_label("LEG 2", Vector2(_t(24), _t(22)))
	_checkpoint(_t(48), _t(47), "l1s_mid")
	_chest(_t(8), _t(top), 25, "l1s_chest")
	_label("THE REWARD\n(a great chest; the extra flame isn't built)", Vector2(_t(4), _t(top) - 96))
	_level_end(_t(2.2), _t(top), 32, 56)
	# The great secret: everyone climbs. The knot sleeps in the far corner of
	# the floor, past the first root, where nothing leads.
	_knot(Vector2(_t(55), _t(G) - 14), "l1s_knot")
	extras.append_array([["place", 5, G, 1], ["rise", 8, 13, 61], ["off", 13, G, 1], ["walk", 55], ["knot"],
		["place", 10.2, top, -1], ["chest", 0]])
	shots = [["01_start_root", 8, G, 1], ["02_leg_1", 30, 53, 1], ["03_turn_banner", 50, 44, 1], ["04_leg_2", 30, 32, -1],
		["05_reward", 8, top, -1], ["06_far_corner_knot", 50, G, 1]]
	_level_finish()
	quit()
