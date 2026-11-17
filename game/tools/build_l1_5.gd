extends "res://tools/level_builder.gd"
## Builds level 1-5, The Lantern Clearing: the region's gauntlet. A BLOCKOUT.
##
##   godot --headless --path game --script res://tools/build_l1_5.gd
##
## Spec: design/levels/1-5_lantern_clearing.md. Its idea is **everything the
## region taught, mixed**: stones over water (1-2), a raft and a lift (1-4),
## a crate to carry and a choice of what to throw it at, thorns to jump, a
## wall no jump reaches, a raft that hands her to a lift, floating islands at
## a run. 380 x 40 tiles; the bonus areas lie beside it (x 392-476).

const ROOM_PATH := "res://scenes/levels/l1_5_lantern_clearing.tscn"
const ROOM := Rect2i(0, 0, 480, 40)
const MAIN := Rect2i(0, 0, 380, 40)
const G := 30
const WATER_Y := 512.0


func _t(x: float) -> float:
	return x * TILE


## A raft runs back and forth on its own, two tiles short of each bank (as in
## 1-4): she times a jump on and a jump off. A lift runs up and down on its own
## too, resting beside each floor it serves.
func _raft(x: float, row: float, run: float, speed := 64.0, rest := 1.0) -> AnimatableBody2D:
	return _mover(Vector2(_t(x), _t(row)), 48.0, [Vector2.ZERO, Vector2(run * TILE, 0)], speed, rest, false)


func _run_lift(x: float, row: float, rise: float, speed := 56.0, phase := 0.0, rest := 1.0) -> AnimatableBody2D:
	return _mover(Vector2(_t(x), _t(row)), 48.0, [Vector2.ZERO, Vector2(0, -rise * TILE)], speed, rest, false, phase)


func _initialize() -> void:
	room = ROOM
	rock = [
		[0, G, 380, 10, 0],        # the road
		[14, 27, 8, 3, 0],         # a first terrace (3 up)
		[100, 27, 8, 3, 0],        # a ruin block on the road, hollow, its mouth sealed by cracked stone
		[180, 24, 40, 6, 0],       # the wall no jump reaches (a lift), a road along its top
		[330, 27, 50, 3, 0],       # the gate's terrace
		[340, 24, 40, 3, 0],       # the gate's ledge
		[380, 0, 12, 40, 0],       # beside the level, out of its view
	]
	spaces = [
		[40, G, 27, 10],           # the first water: stones (1-2's idea)
		[110, G, 52, 10],          # the second: a raft, then floating islands
		[220, G, 39, 10],          # under the high raft
		[284, G, 34, 10],          # the last water
		[100, 28, 7, 2],           # the hollow in the ruin block (the thorn knot)
		[180, 28, 4, 2],           # the hollow in the wall's foot, behind the lift (a false wall)
	]
	masses = [
		[127, G, 4, 10, 0],        # the stone the raft sets her beside
		[243, 28, 5, 12, 0],       # the stone the lift sets her beside
		[300, 31, 3, 9, 0],        # a low stone under the last islands (a drop: bonus 2)
	]
	skip = []
	spawn = Vector2(5 * TILE, G * TILE)
	room_path = ROOM_PATH
	blockout = true
	main_floor = G * TILE

	# The main line.
	tour.append_array([["walk", 10], ["rise", 14, 22, 27], ["off", 22, G, 1], ["walk", 36]])
	plan_leg(40, G, 1, [[3, 5, 1, "stone"], [4, 3, 2, "stone"], [4, 4, -2, "stone"], [4, 10, -1, "none"]])
	tour.append_array([["walk", 97], ["rise", 100, 108, 27], ["off", 108, G, 1], ["board", 0, 0, 110], ["ride_end", 0, 1], ["leap", 125, 127, 131, G], ["walk", 129],
		["floor", G, "the raft sets her on the stone"]])
	plan_leg(131, G, 1, [[4, 6, 2, "float"], [4, 5, 2, "float"], [4, 4, -2, "stone"], [4, 10, -2, "none"]])
	tour.append_array([["walk", 170], ["banner"], ["board", 1, 0, 176], ["ride_end", 1, 1], ["walk", 184],
		["floor", 24, "the lift sets her on top of the wall"], ["jump", 189.75, 195.5, 199, 24, 190.75],
		["board", 2, 0, 220], ["ride_end", 2, 1], ["leap", 238, 240, 243, 24], ["ride_end", 3, 1], ["walk", 245.5], ["floor", 28, "raft to lift: down to the stone"]])
	plan_leg(248, 28, 1, [[4, 3, 1, "stone"], [4, 10, -3, "none"]])
	tour.append(["jump", 265.75, 271.5, 276, G, 266.75])
	plan_leg(284, G, 1, [[4, 4, 1, "stone"], [4, 3, 2, "float"], [4, 3, 2, "float"], [4, 4, -2, "stone"], [4, 10, -3, "none"]])
	tour.append_array([["rise", 330, 340, 27], ["rise", 340, 360, 24], ["end", 1]])
	var rush_a := plan_rush(392, 16, "pillars", [[3, 3, 2], [4, 3, 2], [4, 3, -1], [4, 3, -2], [4, 3, 2]])
	var rush_b := plan_rush(436, 16, "blocks", [[4, 4, 3], [4, 4, 5], [3, 4, 3], [4, 6, 5]])

	_level_begin("L1_5_LanternClearing", "1-5 The Lantern Clearing")
	_root.set("main_area", MAIN)
	_water_foreground(WATER_Y, [[0.0, _t(380)]])
	_place_arcs("l15_arc")
	_label("START", Vector2(_t(3), _t(G) - 40))
	_label("THE GAUNTLET: everything the region taught, mixed", Vector2(_t(4), _t(14)))
	_beads([Vector2(_t(9), _t(G) - 12), Vector2(_t(12), _t(G) - 12), Vector2(_t(18), _t(27) - 12)], "l15_a")
	_letter(Vector2(_t(50), _t(29) - 58), "K", "l15_letter_k")
	_label("STONES (1-2)", Vector2(_t(44), _t(22)))
	# A crate, a rat, and a ruin block whose mouth is cracked stone: one
	# crate, two things to throw it at.
	_crate(_t(78), _t(G), CRATE_B)
	_lunger(_t(88), _t(G), _t(82), _t(95), "rat")
	_cracked_wall(Rect2i(100, 28, 2, 2), "l15_crack")
	_label("ONE CRATE: the rat, or the cracked stone?", Vector2(_t(78), _t(G) - 70))
	_raft(112, G, 10)
	_label("A RAFT (1-4), then FLOATING ISLANDS", Vector2(_t(114), _t(20)))
	_checkpoint(_t(166), _t(G), "l15_mid")
	_label("MIDWAY BANNER", Vector2(_t(164), _t(G) - 84))
	_run_lift(177, 29, 5)
	_label("A LIFT up the wall", Vector2(_t(172), _t(18)))
	_thorns(_t(192), _t(195), _t(24))
	_lunger(_t(208), _t(24), _t(200), _t(215), "rat")
	_chest(_t(217.5), _t(24), 8, "l15_chest1")
	# The high raft and the lift keep one time (218 ticks a run, 1.4 s of rest):
	# the lift is at the top whenever the raft is at its east end.
	_raft(222, 24, 13, 80.0, 1.4)
	_run_lift(240, 24, -4, 80.0 * 4.0 / 13.0, 302.5 / 60.0, 1.4)
	_label("RAFT TO LIFT", Vector2(_t(224), _t(18)))
	_thorns(_t(268), _t(271), _t(G))
	_letter(Vector2(_t(301), _t(27) - 58), "O", "l15_letter_o")
	_label("STONES AND ISLANDS, AT A RUN", Vector2(_t(286), _t(18)))
	_chest(_t(350), _t(24), 8, "l15_chest2")
	_level_end(_t(360), _t(24), 48, 72)
	_label("THE WAY TO THE KEEP", Vector2(_t(352), _t(17)))

	# --- The secrets -----------------------------------------------------------------------------
	extras.append_array([["place", 38, G, 1], ["hop", 40, 43, 48, 29], ["hop", 48, 52, 55, 27], ["letter", "K", "over the first stones"]])
	# The great secret: the crate is there for the rat. Carried past it and
	# thrown at the ruin block's cracked mouth, it opens the hollow: the knot.
	_knot(Vector2(_t(105), _t(G) - 14), "l15_knot")
	extras.append_array([["place", 75, G, 1], ["walk", 76.6], ["interact"], ["held"], ["walk", 93], ["attack"], ["cracked", 0],
		["walk", 105], ["knot"], ["walk", 97]])
	# Letter E: over the second floating island, a jump on the spot.
	_letter(Vector2(_t(147.5), _t(26) - 58), "E", "l15_letter_e")
	extras.append_array([["place", 147.5, 26, 1], ["hopup", 26], ["letter", "E", "a jump on the spot, on the second island"]])
	# The wall's foot, behind the lift, is a false wall: letter L and bonus 1.
	_false_wall("WallFoot", Rect2i(180, 28, 4, 2), 180, Vector2i(28, 2), -1, "l15_secret1")
	_draught("WallDraught", Rect2(_t(173), _t(28), _t(3), _t(2)), Vector2(1, 0))
	_letter(Vector2(_t(181.2), _t(G) - 14), "L", "l15_letter_l")
	var a := _place_rush(rush_a, "l15_token1", 12.0)
	_bonus_door(_t(183.2), _t(G), a["zone"], Vector2(_t(181.4), _t(G)), -1)
	_label("FALSE WALL behind the lift\n(letter L, BONUS 1)", Vector2(_t(170), _t(G) + 6))
	extras.append_array([["place", 172, G, 1], ["walk", 181.2], ["letter", "L", "under the lift, behind the wall's foot"],
		["into_zone", "l15_token1", 1]])
	extras.append_array(a["moves"])
	extras.append_array([["place", 215.5, 24, 1], ["chest", 0]])
	# Bonus 2, a drop: a low stone under the last islands. The way back is a ledge catch.
	var b := _place_rush(rush_b, "l15_token2", 16.0)
	_bonus_door(_t(302.3), _t(31), b["zone"], Vector2(_t(300.7), _t(31)), 1)
	_beads([Vector2(_t(300.6), _t(31) - 12)], "l15_drop")
	_label("a drop (secret): BONUS 2", Vector2(_t(294), _t(33) + 6))
	extras.append_array([["place", 297.5, 27, 1], ["hop", 299, 303, 306, 25], ["letter", "O", "over the last islands"],
		["place", 297.5, 27, 1], ["off", 299, 31, 1], ["into_zone", "l15_token2", 1]])
	extras.append_array(b["moves"])
	extras.append_array([["rise", 300, 296, 27], ["place", 348, 24, 1], ["chest", 1]])

	shots = [["01_start_stones", 36, G, 1], ["02_crate_rat_cracked_block", 88, G, 1], ["03_raft_islands", 126, G, 1],
		["04_banner_lift_wall", 170, G, 1], ["05_wall_top_thorns_rat", 196, 24, 1], ["06_raft_to_lift", 226, 24, 1],
		["07_last_water", 296, 27, 1], ["08_gate", 350, 24, 1],
		["09_bonus_pillars", 410, G, 1, Rect2i(392, 16, 40, 24)], ["10_bonus_blocks", 454, G, 1, Rect2i(436, 16, 40, 24)]]
	_level_finish()
	quit()
