extends "res://tools/level_builder.gd"
## Builds level 1-3, The Ruin Gardens: the region's vertical level. A BLOCKOUT.
##
##   godot --headless --path game --script res://tools/build_l1_3.gd
##
## Spec: design/levels/1-3_ruin_gardens.md. The level's one idea is **the
## climb**: 80 tiles wide and 100 high (4 screens of climbing), in three legs
## that zigzag up the hill: the hill's own terraces (solid ground, going
## right), then hanging gardens (floating terraces, going back left), then a
## third leg right to the cliff's arch. A fall never kills here: she lands on
## the leg below and climbs again. It hides the region's secret exit.
##
## Planned from pieces (level_builder.gd's plan_leg): the same lists make the
## collision and the scripted tour.

const ROOM_PATH := "res://scenes/levels/l1_3_ruin_gardens.tscn"
const ROOM := Rect2i(0, 0, 180, 100)
const MAIN := Rect2i(0, 0, 80, 100)
const G := 94  # the ground's row


func _t(x: float) -> float:
	return x * TILE


func _initialize() -> void:
	room = ROOM
	rock = [
		[0, G, 80, 6, 0],          # the ground
		[0, 0, 2, 100, 0],         # the hill's west face
		[78, 0, 2, 100, 0],        # the cliff
		[80, 0, 12, 100, 0],       # beside the level, out of its view
		[74, 69, 4, 3, 0],         # the first turn's step, against the cliff
	]
	spaces = [
		[14, 92, 6, 2],            # the tunnel behind the first terrace's face (a false wall)
		[20, 90, 8, 4],            # the hidden cave under the hill: the thorn knot
		[32, 89, 4, 2],            # the hollow in the sunken bed's far face (letter L)
	]
	masses = []
	skip = []
	spawn = Vector2(6 * TILE, G * TILE)
	room_path = ROOM_PATH
	blockout = true
	main_floor = G * TILE

	# Leg 1, TEACH and TEST: the hill's terraces, going right. Steps of 3
	# beside her, two sunken beds to hop (4 across, 2 up).
	tour.append(["walk", 11])
	var at := plan_leg(14, G, 1, [[0, 6, 3], [0, 8, 3], [4, 5, 2], [0, 7, 3], [4, 6, 2], [0, 6, 3], [0, 6, 3], [0, 12, 3]], "solid")
	tour.append(["banner"])
	# The first turn, against the cliff: a step, then back west over a small island.
	tour.append(["rise", 74, 78, 69])
	at = plan_leg(74, 69, -1, [[4, 4, 2]], "float2")
	# Leg 2, TWIST: hanging gardens, going left: the same climb with nothing under it but the hill.
	at = plan_leg(at[0], at[1], -1, [[4, 6, 2], [0, 8, 3], [4, 5, 2], [0, 7, 3], [4, 6, 2], [0, 8, 3], [0, 12, 3]], "float")
	# The second turn, against the hill's west face.
	plan_leg(6, at[1], -1, [[0, 4, 3]], "float")
	at = plan_leg(6, at[1] - 3, 1, [[4, 4, 2]], "float2")
	# Leg 3, FINISH: the last gardens, going right to the cliff's arch.
	at = plan_leg(at[0], at[1], 1, [[4, 6, 2], [0, 8, 3], [4, 5, 2], [0, 7, 3], [4, 6, 2], [0, 8, 3], [0, 12, 3]], "float")
	var top: int = at[1]
	tour.append(["end", 1])

	# At the top, back west from the arch (the secret way): an island with a
	# bonus hollow on it, and past it the secret exit.
	var to_hollow: Array = []
	var to_exit: Array = []
	at = plan_leg(66, top, -1, [[3, 6, 2]], "float2", to_hollow)
	at = plan_leg(at[0], at[1], -1, [[4, 5, 2]], "float2", to_exit)
	var exit_row: int = at[1]
	var rush_a := plan_rush(92, 60, "pillars", [[4, 3, 2], [4, 3, -1], [4, 3, 2], [4, 3, -2], [3, 3, 2]])
	var rush_b := plan_rush(136, 60, "blocks", [[3, 4, 2], [4, 5, 4], [4, 4, 2], [4, 8, 4]])

	_level_begin("L1_3_RuinGardens", "1-3 The Ruin Gardens")
	_root.set("main_area", MAIN)
	_place_arcs("l13_arc")
	_label("START", Vector2(_t(4), _t(G) - 40))
	_label("LEG 1 (teach, test): THE HILL'S TERRACES\nsteps of 3, two sunken beds to hop", Vector2(_t(34), _t(70)))
	_label("LEG 2 (twist): HANGING GARDENS, back west\na fall lands her on the hill below", Vector2(_t(24), _t(44)))
	_label("LEG 3 (finish): to the cliff's arch", Vector2(_t(30), _t(22)))
	_beads([Vector2(_t(9), _t(G) - 12), Vector2(_t(11), _t(G) - 12), Vector2(_t(17), _t(91) - 12), Vector2(_t(24), _t(88) - 12)], "l13_a")
	_mossback(_t(24), _t(88), _t(21.5), _t(26.5))
	_letter(Vector2(_t(30), _t(88) - 60), "K", "l13_letter_k")
	_thorns(_t(45), _t(47), _t(86))
	_label("thorns in the bed", Vector2(_t(43), _t(86) + 6))
	_checkpoint(_t(67), _t(72), "l13_mid")
	_label("MIDWAY BANNER", Vector2(_t(65), _t(72) - 84))
	_chest(_t(76.6), _t(69), 8, "l13_chest1")
	_lunger(_t(52), _t(62), _t(49.5), _t(54.5), "rat")
	_letter(Vector2(_t(50), _t(34) - 60), "O", "l13_letter_o")
	_chest(_t(76), _t(top), 8, "l13_chest2")
	_level_end(_t(71), _t(top), 48, 72)
	_label("THE CLIFF'S ARCH", Vector2(_t(68), _t(top) - 100))

	# --- The secrets -----------------------------------------------------------------------------
	# The great secret: the first terrace's face is a false wall. Every player
	# jumps onto that terrace; the knot is for the one who walks into it.
	_false_wall("HillFace", Rect2i(14, 92, 6, 2), 14, Vector2i(92, 2), -1, "l13_secret_knot")
	_pickup(_root, Vector2(_t(12.8), _t(G) - 10), 1, "l13_tell")
	_knot(Vector2(_t(25.5), _t(G) - 14), "l13_knot")
	extras.append_array([["place", 9, G, 1], ["knot_asleep", "the knot sleeps behind the first terrace's face"],
		["walk", 25.5], ["knot"], ["walk", 11]])
	# Bonus 1: left at the start, against the hill's west face.
	var a := _place_rush(rush_a, "l13_token1", 12.0)
	_bonus_door(_t(3.2), _t(G), a["zone"], Vector2(_t(5.6), _t(G)), 1)
	extras.append(["into_zone", "l13_token1", -1])
	extras.append_array(a["moves"])
	# Letter L: in the first sunken bed, its far face is a false wall.
	_false_wall("BedFace", Rect2i(32, 89, 4, 2), 32, Vector2i(89, 2), -1, "l13_secret_l")
	_draught("BedDraught", Rect2(_t(29), _t(89), _t(3), _t(2)), Vector2(1, 0))
	_letter(Vector2(_t(34), _t(91) - 14), "L", "l13_letter_l")
	_label("FALSE WALL (letter L)", Vector2(_t(27), _t(91) + 4))
	extras.append_array([["place", 26, 88, 1], ["off", 28, 91, 1], ["walk", 34], ["letter", "L", "behind the bed's false wall"],
		["walk", 30], ["rise", 28, 20, 88]])
	# Letter E, a dare: it hangs in a gap of the hanging gardens. Dropping
	# for it lands her on the hill below, beside the false wall.
	_letter(Vector2(_t(30), _t(62)), "E", "l13_letter_e")
	_label("E (a dare: drop for it)", Vector2(_t(25), _t(64)))
	extras.append_array([["place", 34, 57, -1], ["off", 32, 91, -1], ["letter", "E", "the dare: a drop from the hanging gardens"]])
	# Letters K and O, on the main line's hops.
	extras.append_array([["place", 26, 88, 1], ["hop", 28, 32, 37, 86], ["letter", "K", "over the first sunken bed"],
		["place", 46, 34, 1], ["hop", 48, 52, 58, 32], ["letter", "O", "over a hop of the last leg"]])
	# The chests.
	extras.append_array([["place", 75.2, 69, 1], ["chest", 0], ["place", 74.6, top, 1], ["chest", 1]])
	# The top: back west from the arch to bonus 2, and past it the secret exit.
	var b := _place_rush(rush_b, "l13_token2", 16.0)
	_bonus_door(_t(58.4), _t(top - 2), b["zone"], Vector2(_t(61.4), _t(top - 2)), -1)
	_level_end(_t(48.1), _t(exit_row), 24, 48, "", "l13_secret_exit")
	_label("BONUS 2, then THE SECRET EXIT\n(back west from the arch)", Vector2(_t(46), _t(exit_row) - 86))
	extras.append(["place", 69, top, -1])
	extras.append_array(to_hollow)
	extras.append(["into_zone", "l13_token2", -1])
	extras.append_array(b["moves"])
	extras.append(["walk", 57.7])
	extras.append_array(to_exit)
	extras.append(["end", -1, "SecretExit"])
	extras.append(["flag", "l13_secret_exit", "the secret exit opens the grotto on the map"])

	shots = [["01_start_hill_face", 9, G, 1], ["02_terraces_first_bed", 28, 88, 1], ["03_banner_first_turn", 70, 72, 1],
		["04_hanging_gardens", 50, 62, -1], ["05_second_turn", 8, 49, 1], ["06_last_leg", 40, 37, 1],
		["07_arch_and_secret_way", 64, 29, 1], ["08_hidden_cave", 24, G, 1],
		["09_bonus_pillars", 110, 74, 1, Rect2i(92, 60, 40, 24)], ["10_bonus_blocks", 152, 74, 1, Rect2i(136, 60, 40, 24)]]
	_level_finish()
	quit()
