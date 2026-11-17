extends "res://tools/level_builder.gd"
## Builds level 1-4, The Aqueduct. A BLOCKOUT.
##
##   godot --headless --path game --script res://tools/build_l1_4.gd
##
## Spec: design/levels/1-4_aqueduct.md. The level's one idea is **things that
## really move**: timber rafts and counterweighted lifts. Each waits for her to
## step on, makes its run, and goes back for her. TEACH: a raft over a dry
## channel and a lift beside a wall, where a miss costs nothing. TEST: a raft
## over the gorge, a lift up to the aqueduct's deck. TWIST: a raft high over
## open water that hands her to a lift going down. FINISH: a fast raft, the gate.
##
## 360 x 40 tiles; the bonus areas lie beside it (x 372-456).

const ROOM_PATH := "res://scenes/levels/l1_4_aqueduct.tscn"
const ROOM := Rect2i(0, 0, 460, 40)
const MAIN := Rect2i(0, 0, 360, 40)
const G := 30
const WATER_Y := 512.0


func _t(x: float) -> float:
	return x * TILE


func _raft(x: float, row: float, run: Vector2, speed := 56.0) -> AnimatableBody2D:
	return _mover(Vector2(_t(x), _t(row)), 48.0, [Vector2.ZERO, run * TILE], speed, 0.6, true)


func _initialize() -> void:
	room = ROOM
	rock = [
		[0, G, 360, 10, 0],        # the road
		[16, 27, 8, 3, 0],         # TEACH: the dry channel's west bank (3 up)
		[36, 27, 8, 3, 0],         # and its east bank
		[58, 24, 20, 6, 0],        # the wall the first lift climbs (6 up: no jump reaches it)
		[143, 22, 45, 18, 0],      # TEST: the aqueduct, walked on (8 up)
		[300, 27, 60, 3, 0],       # FINISH: the gate's terrace
		[310, 24, 50, 3, 0],       # the gate's ledge
		[360, 0, 12, 40, 0],       # beside the level, out of its view
	]
	spaces = [
		[100, G, 24, 10],          # the gorge
		[140, G, 3, 10],           # the lift's shaft, at the aqueduct's foot
		[188, G, 40, 10],          # open water past the aqueduct
		[256, G, 20, 10],          # the last water
		[74, 28, 4, 2],            # the hollow in the wall's east face (a false wall: bonus 2)
		[143, 27, 10, 3],          # the cave under the aqueduct (the thorn knot)
	]
	masses = [
		[211, 28, 5, 12, 0],       # the stone the lift sets her down beside
	]
	skip = []
	spawn = Vector2(5 * TILE, G * TILE)
	room_path = ROOM_PATH
	blockout = true
	main_floor = G * TILE

	# The main line.
	tour.append_array([["walk", 12], ["rise", 16, 24, 27], ["ride", 0, 1], ["walk", 40],
		["floor", 27, "the raft sets her on the far bank (over a dry channel: nothing to lose)"],
		["off", 44, G, 1], ["walk", 51], ["hop", 54, 55, 58, 29], ["ride", 1, 1], ["walk", 62],
		["floor", 24, "the lift sets her on top of the wall"], ["off", 78, G, 1],
		["ride", 2, 1], ["walk", 130], ["floor", G, "the raft carries her over the gorge"],
		["ride", 3, 1], ["walk", 152], ["floor", 22, "the lift takes her up to the aqueduct"], ["banner"],
		["ride", 4, 1], ["ride", 5, 1], ["walk", 213.5], ["floor", 28, "raft to lift: down to the stone"]])
	plan_leg(216, 28, 1, [[4, 4, 1, "stone"], [4, 10, -3, "none"]])
	tour.append_array([["jump", 237.75, 243.5, 248, G, 238.75], ["ride", 6, 1], ["walk", 282], ["floor", G, "the fast raft over the last water"],
		["rise", 300, 310, 27], ["rise", 310, 330, 24], ["end", 1]])
	var rush_a := plan_rush(372, 16, "pillars", [[4, 3, 1], [4, 3, 2], [3, 3, -2], [4, 3, 2], [3, 3, 1]])
	var rush_b := plan_rush(416, 16, "blocks", [[3, 5, 3], [4, 4, 5], [4, 5, 3], [3, 7, 5]])

	_level_begin("L1_4_Aqueduct", "1-4 The Aqueduct")
	_root.set("main_area", MAIN)
	_water_foreground(WATER_Y, [[0.0, _t(360)]])
	_place_arcs("l14_arc")
	_label("TEACH", Vector2(_t(2), _t(16)))
	_label("START", Vector2(_t(3), _t(G) - 40))
	_beads([Vector2(_t(9), _t(G) - 12), Vector2(_t(12), _t(G) - 12), Vector2(_t(20), _t(27) - 12)], "l14_a")
	# TEACH: a raft over a dry channel; a lift beside a wall.
	_raft(24, 27, Vector2(9, 0))
	_label("A RAFT over a dry channel\n(it waits for her; a miss costs nothing)", Vector2(_t(22), _t(20)))
	_letter(Vector2(_t(30), _t(27) - 30), "K", "l14_letter_k")
	_raft(55, 29, Vector2(0, -5))
	_label("A LIFT up a wall no jump reaches", Vector2(_t(50), _t(18)))
	_chest(_t(70), _t(24), 8, "l14_chest1")
	_mossback(_t(88), _t(G), _t(83), _t(95))
	# TEST: a raft over the gorge; a lift over water up to the aqueduct.
	_label("TEST", Vector2(_t(98), _t(12)))
	_raft(100, G, Vector2(21, 0), 64.0)
	_label("A RAFT OVER THE GORGE", Vector2(_t(104), _t(24)))
	_raft(140, G, Vector2(0, -8))
	_label("A LIFT up to the aqueduct", Vector2(_t(132), _t(18)))
	_checkpoint(_t(148), _t(22), "l14_mid")
	_label("MIDWAY BANNER", Vector2(_t(146), _t(22) - 84))
	_lunger(_t(168), _t(22), _t(156), _t(180), "rat")
	_label("THE AQUEDUCT (walked on): a rat", Vector2(_t(158), _t(15)))
	# TWIST: a raft high over open water hands her to a lift going down.
	_label("TWIST", Vector2(_t(190), _t(12)))
	_raft(188, 22, Vector2(17, 0), 64.0)
	_raft(208, 22, Vector2(0, 6))
	_label("RAFT TO LIFT: across, then down", Vector2(_t(192), _t(16)))
	# FINISH: thorns, a fast raft, the gate.
	_label("FINISH", Vector2(_t(232), _t(16)))
	_thorns(_t(240), _t(243), _t(G))
	_raft(256, G, Vector2(17, 0), 96.0)
	_letter(Vector2(_t(266), _t(G) - 30), "O", "l14_letter_o")
	_label("A FAST RAFT", Vector2(_t(260), _t(24)))
	_chest(_t(318), _t(24), 8, "l14_chest2")
	_level_end(_t(332), _t(24), 48, 72)
	_label("THE GATE", Vector2(_t(326), _t(17)))

	# --- The secrets -----------------------------------------------------------------------------
	# Letter K rides with her on the first raft.
	extras.append_array([["place", 20, 27, 1], ["ride", 0, 1], ["letter", "K", "over the first raft's run"]])
	# The dry channel under that raft: letter E, and bonus 1's hollow in its west face.
	_letter(Vector2(_t(33), _t(G) - 14), "E", "l14_letter_e")
	var a := _place_rush(rush_a, "l14_token1", 12.0)
	_bonus_door(_t(25.2), _t(G), a["zone"], Vector2(_t(27.6), _t(G)), 1)
	_label("under the raft (secret):\nE, BONUS 1", Vector2(_t(26), _t(G) + 6))
	extras.append_array([["walk", 40], ["off", 36, G, -1], ["walk", 33], ["letter", "E", "in the channel under the raft"],
		["into_zone", "l14_token1", -1]])
	extras.append_array(a["moves"])
	extras.append(["rise", 36, 44, 27])
	# Letter L hangs over the first lift's top stop: a jump from the lift.
	_letter(Vector2(_t(56.5), _t(24) - 50), "L", "l14_letter_l")
	extras.append_array([["place", 51, G, 1], ["hop", 54, 55, 58, 29], ["ride", 1, 1], ["hopup", 24],
		["letter", "L", "a jump from the lift at the top of its run"], ["place", 68, 24, 1], ["chest", 0]])
	# The wall's east face is a false wall, behind her as she steps down: bonus 2.
	_false_wall("WallFace", Rect2i(74, 28, 4, 2), 78, Vector2i(28, 2), 1, "l14_secret1")
	_draught("WallDraught", Rect2(_t(79), _t(28), _t(3), _t(2)), Vector2(-1, 0))
	var b := _place_rush(rush_b, "l14_token2", 16.0)
	_bonus_door(_t(75.3), _t(G), b["zone"], Vector2(_t(77.2), _t(G)), -1)
	_label("FALSE WALL\n(BONUS 2)", Vector2(_t(79), _t(G) - 50))
	extras.append_array([["place", 82, G, -1], ["into_zone", "l14_token2", -1]])
	extras.append_array(b["moves"])
	# The great secret: the lift at the aqueduct's foot is a bridge to whoever
	# doesn't stop on it. Walk straight across before it rises: the cave under
	# the aqueduct, and the knot.
	_knot(Vector2(_t(150), _t(G) - 14), "l14_knot")
	_label("THE CAVE UNDER THE AQUEDUCT\n(cross the lift before it rises)", Vector2(_t(144), _t(G) + 6))
	extras.append_array([["place", 137, G, 1], ["walk", 150],
		["floor", G, "straight across the lift before it rises, into the cave under the aqueduct"], ["knot"],
		["wait", 480], ["ride", 3, -1], ["walk", 147], ["floor", 22, "and the lift takes her up from the cave's side"]])
	# Letter O over the fast raft's run; the gate's chest.
	extras.append_array([["place", 253, G, 1], ["ride", 6, 1], ["letter", "O", "over the fast raft's run"],
		["place", 316, 24, 1], ["chest", 1]])

	shots = [["01_start_raft_dry_channel", 20, 27, 1], ["02_first_lift_wall", 52, G, 1], ["03_gorge_raft", 98, G, 1],
		["04_lift_to_aqueduct_cave", 137, G, 1], ["05_aqueduct_banner_rat", 160, 22, 1], ["06_raft_to_lift", 190, 22, 1],
		["07_stone_thorns", 228, G, 1], ["08_fast_raft", 254, G, 1], ["09_gate", 320, 24, 1],
		["10_bonus_pillars", 390, G, 1, Rect2i(372, 16, 40, 24)], ["11_bonus_blocks", 434, G, 1, Rect2i(416, 16, 40, 24)]]
	_level_finish()
	quit()
