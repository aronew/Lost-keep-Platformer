extends "res://tools/level_builder.gd"
## Builds level 2-2, Millers' Row, and saves it as an ordinary scene.
## A BLOCKOUT (`blockout = true`): the black box, labels, real or stand-in
## sprites for everything that acts. No art until the layout is approved.
##
##   godot --headless --path game --script res://tools/build_l2_2.gd
##
## Spec: design/levels/2-2_millers_row.md. Region 2's machine level
## (design/rulebook.md §4.1, stop 2). The level's one idea is **the turning
## mill**: a windmill's sails carry hoist cradles round, and she rides them
## over the gorges of the Hearth-Plains. Taught over the road, tested over
## the gorge, then turned: mills that sleep until a bell wakes them, a mill
## that turns the wrong way until a vane is struck, and a chain of three
## that hand her on without a wait.
##
## The level is 530 x 46 tiles (about 13 screens by 2); its two bonus areas
## lie beside it, x 542-634, out of its view. The road is row 30 (y 480);
## the ground is given as stretches with a top row, and a gorge is where
## there is none. Four beats: TEACH (x 0-80), TEST (80-264), the banner
## (272), TWIST (290-446), FINISH (446-530).

const ROOM_PATH := "res://scenes/levels/l2_2_millers_row.tscn"
const H := 46
const G := 30  # the road's row

const ROOM := Rect2i(0, 0, 638, H)
const MAIN := Rect2i(0, 0, 530, H)
const BONUS_WHEEL := Rect2i(542, 20, 44, 26)   # bonus 1: the great wheel
const BONUS_SAILS := Rect2i(590, 20, 44, 26)   # bonus 2: two small mills

## The ground: [from x, to x, top row]. Where no stretch stands is a gorge.
const GROUND := [
	# TEACH
	[0, 18, 30], [18, 23, 32], [23, 47, 30],   # the road; a dry cart rut (5 across, nothing to lose)
	[47, 69, 24],                              # the first mill's yard (6 up: only its cradles reach it)
	[69, 73, 27], [73, 80, 30],                # a step down to the road
	# TEST
	[80, 87, 27],                              # a bank (3 up): the first gorge's landing
	[102, 112, 27], [112, 118, 24],            # its far bank; a step up
	[135, 137, 29], [137, 150, 24],            # the foot of the far cliff juts out; the cliff
	[150, 154, 27], [154, 176, 30],            # down to the threshing road
	[176, 200, 22],                            # the granary (8 up: the hoist)
	[230, 246, 22],                            # the upper field
	[264, 290, 18],                            # the midway terrace (4 up from the great wheel's side)
	# TWIST
	[305, 327, 18],                            # the hoods' terrace
	[327, 344, 25],                            # the bramble lane under the wrong-way mill
	[344, 360, 18], [360, 370, 21],            # a step down to the crate's ledge
	[386, 404, 21],                            # between the far bell's mill and the last plain one
	[420, 446, 21],                            # the old mill's yard
	# FINISH
	[486, 500, 23], [500, 530, 20],            # the Great Mill's steps
	[530, 542, 0],
	# Bonus 1 (x 542-586): a floor, a great wheel over it.
	[542, 586, 40], [586, 590, 0],
	# Bonus 2 (x 590-634): two ledges and a pillar over a drop.
	[590, 598, 36], [610, 613, 36], [625, 634, 36], [634, 638, 0],
]
const SPACES := [
	[47, 28, 5, 2],     # the false wall's hollow under the yard (letter E)
	[137, 26, 8, 3],    # the cave under the far cliff (bonus 2's entrance)
]

var _m := {}  # the mills, by name


func _initialize() -> void:
	room = ROOM
	var r := []
	for g in GROUND:
		r.append([g[0], g[2], g[1] - g[0], H - g[2], 0])
	rock = r
	spaces = SPACES
	masses = []
	skip = []
	spawn = Vector2(5 * TILE, G * TILE)
	room_path = ROOM_PATH
	blockout = true
	main_floor = G * TILE
	_level_begin("L2_2_MillersRow", "2-2 Millers' Row")
	_root.set("main_area", MAIN)
	_teach()
	_test()
	_twist()
	_finish_beat()
	_bonus()
	_level_finish()
	quit()


func _t(x: float) -> float:
	return x * TILE


## A mill, in tiles: the cradles' centre (cx, cy), radius, arms, seconds a
## turn, turn (1 clockwise), where arm 0 starts, the cradles' width.
func _mill(mill_name: String, cx: float, cy: float, radius: float, arms: int, period: float, turn: int, start: float,
		w := 3.0, running := true, foot := -1.0) -> Node2D:
	var c := Vector2(_t(cx), _t(cy))
	_mill_tower(c, _t(foot) if foot >= 0.0 else float(H * TILE))
	var m := _windmill(c, _t(radius), arms, period, turn, start, _t(w), running, mill_name)
	_m[mill_name] = m
	return m


## Beads along a mill's ride: on the cradles' circle from `a0` to `a1`
## degrees (0 east, 90 the bottom, 180 west, 270 the top), where a rider's
## body passes.
func _ride_beads(cx: float, cy: float, radius: float, a0: float, a1: float, count: int, flag: String, lift := 14.0) -> void:
	var pts := []
	for i in count:
		var a := deg_to_rad(lerpf(a0, a1, float(i) / maxf(count - 1, 1)))
		pts.append(Vector2(_t(cx), _t(cy)) + Vector2(cos(a), sin(a)) * _t(radius) + Vector2(0, -lift))
	_beads(pts, flag)


func _ring_points(cx: float, cy: float, radius: float, count: int, lift := 14.0) -> Array:
	var pts := []
	for i in count:
		var a := TAU * i / count
		pts.append(Vector2(_t(cx), _t(cy)) + Vector2(cos(a), sin(a)) * _t(radius) + Vector2(0, -lift))
	return pts


## A one-way walkway (a branch, a roof ridge) with a tree behind it.
func _branch(x0: float, x1: float, y: float, trunk := true) -> void:
	_canopy(_t(x0), _t(x1), y)
	if trunk:
		_backdrop_tree(_t((x0 + x1) * 0.5), float(H * TILE), y - 30.0, 22.0, _t(x1 - x0) + 50.0)


# --- TEACH: the cart rut, the first mill over the road ----------------------------------------------

func _teach() -> void:
	_label("TEACH", Vector2(_t(2), _t(14)))
	_label("START", Vector2(_t(3), _t(G) - 40))
	_beads([Vector2(_t(9), _t(G) - 12), Vector2(_t(11.5), _t(G) - 12), Vector2(_t(14), _t(G) - 12)], "l22_a")
	# The region's wider gap, first where a miss costs nothing: a dry rut.
	_bead_arc(Vector2(_t(17.5), _t(G)), Vector2(_t(23.5), _t(G)), 34.0, 3, "l22_rut")
	_beads([Vector2(_t(19.5), _t(32) - 12), Vector2(_t(21.5), _t(32) - 12)], "l22_rutlow")
	_label("THE CART RUT\n(5 across, 2 deep:\nregion 2's gap, nothing to lose)", Vector2(_t(15), _t(22)))
	_breakable(CRATES, POT, _t(29), _t(G), CLAY)
	# The first mill, over the road. It turns counter-clockwise: a cradle
	# comes along the bottom toward the yard and lifts her up its east side.
	_mill("Mill1", 40.5, 24, 5, 4, 10.0, -1, 90.0, 3.0, true, G)
	_ride_beads(40.5, 24, 5, 70.0, 10.0, 4, "l22_m1")
	_ride_beads(40.5, 24, 5, 290.0, 250.0, 3, "l22_m1top")
	_label("THE FIRST MILL (over the road: nothing to lose)\nhop on a cradle: it lifts her to the yard.\nStay on and it brings her round again.", Vector2(_t(31), _t(13)))
	# The road runs on under the mill to the yard's wall: a dead end, and a
	# false wall (motes drift into it): letter E.
	_false_wall("YardWall", Rect2i(47, 28, 5, 2), 47, Vector2i(28, 2), -1, "l22_secret1")
	_draught("YardDraught", Rect2(_t(43), _t(28), _t(3), _t(2)), Vector2(1, 0))
	_letter(Vector2(_t(50), _t(G) - 14), "E", "l22_letter_e")
	_label("FALSE WALL\n(letter E)", Vector2(_t(47.5), _t(G) + 6))
	# The yard.
	_chest(_t(52), _t(24), 8, "l22_chest1")
	_mossback(_t(60), _t(24), _t(56), _t(66))
	_label("THE YARD\n(a chest, a Mossback)", Vector2(_t(53), _t(18)))
	_beads([Vector2(_t(71), _t(27) - 12), Vector2(_t(76), _t(G) - 12)], "l22_down")


# --- TEST: mills over the gorge, each a step on from the last --------------------------------------

func _test() -> void:
	_label("TEST", Vector2(_t(82), _t(14)))
	# 1. Over the top, four cradles: the plain crossing.
	_mill("Mill2", 94.5, 27, 5, 4, 10.0, 1, 0.0)
	_ride_beads(94.5, 27, 5, 200.0, 250.0, 3, "l22_m2")
	_ride_beads(94.5, 27, 5, 290.0, 340.0, 3, "l22_m2b")
	_letter(Vector2(_t(94.5), _t(22) - 46), "K", "l22_letter_k")
	_label("K", Vector2(_t(94.1), _t(22) - 74))
	# Risky Resin: round the bottom, under the hub, over the gorge.
	_ride_beads(94.5, 27, 5, 50.0, 130.0, 5, "l22_m2low")
	_label("THE FIRST GORGE: up and over (4 cradles).\nK over the top; risky Resin round the bottom", Vector2(_t(86), _t(15)))
	_beads([Vector2(_t(106), _t(27) - 12), Vector2(_t(114), _t(24) - 12)], "l22_b1")
	# 2. A greater wheel with three cradles: a longer wait, a longer ride.
	_mill("Mill3", 127.5, 24, 7, 3, 9.0, 1, 0.0)
	_ride_beads(127.5, 24, 7, 195.0, 255.0, 4, "l22_m3")
	# Stay on past the landing: beads go on down the arc to the cliff's foot.
	_ride_beads(127.5, 24, 7, 14.0, 44.0, 3, "l22_m3on")
	_beads([Vector2(_t(136), _t(29) - 12)], "l22_m3lip")
	_label("THE GREAT WHEEL (3 cradles: wait for it)", Vector2(_t(120), _t(12)))
	_label("STAY ON past the landing (secret):\nthe ride goes down to the cliff's foot,\na cave: BONUS 2 ENTRANCE", Vector2(_t(137.5), _t(29) + 8))
	# The threshing road: the first pair.
	_breakable(CRATES, POT, _t(145), _t(24), CLAY)
	_lunger(_t(160), _t(G), _t(157), _t(170), "rat")
	_lunger(_t(167), _t(G), _t(157), _t(170), "rat")
	_label("THE THRESHING ROAD\n(a pair of rats: they take turns,\nnever two lunges at once)", Vector2(_t(157), _t(G) - 62))
	# 3. The rest: the granary's sack hoist (it waits for her).
	_mover(Vector2(_t(173), _t(29)), 48.0, [Vector2(0, 0), Vector2(0, -112)], 44.0, 0.8, true)
	_label("THE SACK HOIST\n(waits for her: the rest)", Vector2(_t(166), _t(20)))
	_chest(_t(184), _t(22), 6, "l22_chest2")
	_breakable(CRATES, BARREL, _t(190), _t(22), WOOD)
	_label("THE GRANARY", Vector2(_t(180), _t(16)))
	# 4. Twin mills: from cradle to cradle, no ground between.
	_mill("Mill4a", 207.5, 22, 5, 4, 10.0, 1, 0.0)
	_mill("Mill4b", 222.5, 22, 5, 4, 10.0, 1, 0.0)
	_ride_beads(207.5, 22, 5, 200.0, 250.0, 3, "l22_m4a")
	_bead_arc(Vector2(_t(213.5), _t(22)), Vector2(_t(216.5), _t(22)), 20.0, 2, "l22_m4x")
	_ride_beads(222.5, 22, 5, 290.0, 340.0, 3, "l22_m4b")
	_label("THE TWIN MILLS: cradle to cradle\n(they turn in step: both are at the middle together)", Vector2(_t(203), _t(27) + 4))
	# The roof road (secret): straight up from the top of the second twin,
	# through a branch, and over the roofs to the midway terrace.
	_branch(219.5, 225.5, 228.0)
	_beads([Vector2(_t(222.5), _t(17) - 30), Vector2(_t(222.5), _t(17) - 44), Vector2(_t(222.5), _t(17) - 58)], "l22_roofup")
	_branch(229, 239, 212.0)
	_branch(243, 248, 192.0)
	_branch(252, 261, 164.0)
	# The last roof stands clear of the great wheel's landing: a jump onto the
	# terrace from a cradle never reaches it (it caught the main line's jump).
	_branch(265, 271, 208.0, false)
	_beads([Vector2(_t(231), 200.0), Vector2(_t(233.5), 200.0), Vector2(_t(236), 200.0), Vector2(_t(254), 152.0), Vector2(_t(256.5), 152.0), Vector2(_t(259), 152.0)], "l22_roof")
	_letter(Vector2(_t(245.5), 192.0 - 16.0), "L", "l22_letter_l")
	_label("THE ROOF ROAD (secret): up through the branch from the top of the wheel; letter L; BONUS 1 at its end", Vector2(_t(218), _t(7)))
	# 5. The great wheel, narrow cradles, and the way out is high: she steps
	# off early, 4 above its hub.
	_mill("Mill5", 255, 22, 7, 3, 9.0, 1, 0.0, 2.0)
	_ride_beads(255, 22, 7, 195.0, 250.0, 4, "l22_m5")
	_ride_beads(255, 22, 7, 300.0, 325.0, 2, "l22_m5b")
	_label("NARROW CRADLES (2 wide);\nthe landing is high: step off early", Vector2(_t(247), _t(30)))


# --- TWIST: mills that must be set: a bell, a vane, a far bell ------------------------------------

func _twist() -> void:
	# The level's one checkpoint, at its middle.
	_checkpoint(_t(272), _t(18), "l22_mid")
	_label("MIDWAY BANNER\n(the checkpoint)", Vector2(_t(270), _t(18) - 84))
	_label("TWIST", Vector2(_t(278), _t(8)))
	# 1. A mill asleep, and its bell beside the path.
	var w1 := _mill("Sleeper", 297.5, 18, 5, 4, 10.0, 1, 0.0, 3.0, false)
	_mill_bell(Vector2(_t(286.5), _t(18) - 30), [w1], "bell", 30.0)
	_ride_beads(297.5, 18, 5, 200.0, 340.0, 5, "l22_w1")
	_label("A MILL ASLEEP (sails furled).\nStrike the BELL: it wakes.", Vector2(_t(281), _t(18) - 76))
	# The hood: region 2's own creature (met alone in 2-1; pairs of it start
	# in 2-4: rulebook P3), with room to fight: 22 tiles, its stretch ending
	# 4 short of each edge.
	_lunger(_t(316), _t(18), _t(309), _t(323), "hood_knife")
	_label("A HOOD\n(room to fight)", Vector2(_t(312), _t(18) - 62))
	# 2. A mill that turns the wrong way: its cradles go down into the
	# brambles. A vane turns the wind. Under it, a lane she can fall into
	# without losing a second flame, with a chest and a vane of its own.
	var w2 := _mill("WrongWay", 335.5, 18, 6, 4, 10.0, -1, 0.0, 3.0, true, 25)
	_mill_bell(Vector2(_t(325), _t(18) - 30), [w2], "vane")
	_mill_bell(Vector2(_t(328.5), _t(25) - 30), [w2], "vane")
	var th := _thorns(_t(338), _t(344), _t(25), 64.0)
	th.set("push_dir", -1)
	_chest(_t(331.5), _t(25), 6, "l22_chest3")
	_ride_beads(335.5, 18, 6, 215.0, 325.0, 5, "l22_w2")
	_label("THE WRONG-WAY MILL: its cradles go down\ninto the brambles. Strike the VANE:\nthe wind turns, and it goes up and over.", Vector2(_t(322), _t(18) - 108))
	_label("THE BRAMBLE LANE\n(a fall costs no flame: a chest,\na vane, a cradle back up)", Vector2(_t(327.5), _t(25) + 8))
	_label("BRAMBLES", Vector2(_t(339), _t(25) - 78))
	# 3. A mill asleep whose bell hangs at its hub, over the gorge, out of
	# the sword's reach: a crate, thrown.
	_beads([Vector2(_t(350), _t(18) - 12), Vector2(_t(362), _t(21) - 12)], "l22_b3")
	var crate := _crate(_t(364), _t(21))
	crate.set("returns", 2.5)
	var w3 := _mill("FarBell", 378, 21, 6, 3, 9.0, 1, 270.0, 2.0, false)
	_mill_bell(Vector2(_t(377), _t(21) - 24), [w3], "bell")
	_ride_beads(378, 21, 6, 205.0, 335.0, 5, "l22_w3")
	_label("THE FAR BELL: at the mill's hub, over the gorge.\nThe sword can't reach. A CRATE can.", Vector2(_t(362), _t(21) - 96))
	# 4. A plain mill, and beside its landing an old mill asleep, with the
	# level's great secret above it. The old mill's bell hangs high in the
	# air beyond the plain mill's top: a crate thrown from the top of the
	# ride rings it (or a leap and a slash).
	var crate2 := _crate(_t(391), _t(21))
	crate2.set("returns", 2.5)
	_mill("Mill6", 412, 21, 6, 4, 9.0, 1, 0.0, 2.0)
	_ride_beads(412, 21, 6, 205.0, 335.0, 5, "l22_m6")
	var old := _mill("OldMill", 431.5, 16, 4, 3, 8.0, 1, 90.0, 3.0, false, 21)
	_mill_bell(Vector2(_t(421), 218.0), [old], "bell")
	_backdrop(_box(Rect2(_t(421) - 2.0, 184.0, _t(10.5), 5.0)))
	_branch(428.5, 434.5, 148.0, false)
	_knot(Vector2(_t(431.5), 148.0 - 16.0), "l22_knot")
	_label("THE OLD MILL (asleep). Its bell hangs high,\nbeyond the top of the last ride:\nCARRY THE CRATE ONTO THE WHEEL, throw from the top.", Vector2(_t(418), _t(21) + 8))


# --- FINISH: three mills in step, over, over and under ---------------------------------------------

func _finish_beat() -> void:
	_label("FINISH", Vector2(_t(446), _t(8)))
	_mill("Flow1", 453, 21, 5, 4, 8.0, 1, 0.0, 2.0)
	_mill("Flow2", 466, 23, 4, 4, 8.0, 1, 0.0, 2.0)
	_mill("Flow3", 479, 23, 5, 4, 8.0, -1, 0.0, 2.0)
	_ride_beads(453, 21, 5, 205.0, 335.0, 5, "l22_f1")
	_ride_beads(466, 23, 4, 205.0, 335.0, 4, "l22_f2")
	_ride_beads(479, 23, 5, 155.0, 25.0, 5, "l22_f3")
	_letter(Vector2(_t(472), _t(23) - 44), "O", "l22_letter_o")
	_label("O", Vector2(_t(471.6), _t(23) - 72))
	_label("THREE MILLS IN STEP: over, over, and under.\nKeep moving and each cradle is there as she arrives.", Vector2(_t(448), _t(12)))
	_beads([Vector2(_t(490), _t(23) - 12), Vector2(_t(495), _t(23) - 12), Vector2(_t(502), _t(20) - 12)], "l22_end")
	_chest(_t(508), _t(20), 8, "l22_chest4")
	_level_end(_t(516), _t(20), 48, 72)
	_label("THE GREAT MILL'S DOOR", Vector2(_t(511), _t(13)))


# --- The bonus areas: Resin rushes on the mills ----------------------------------------------------

func _bonus() -> void:
	# Bonus 1 (the roof road's end): one great wheel over a floor. A ring of
	# Resin along its ride, three over its top, a row along the floor.
	_mill("BonusWheel", 564, 33, 6, 4, 8.0, 1, 0.0, 2.0, true, 40)
	var rush: Array = [Vector2(_t(549), _t(40) - 12), Vector2(_t(552), _t(40) - 12), Vector2(_t(555), _t(40) - 12), Vector2(_t(558), _t(40) - 12)]
	# The ring, but for the beads at the top and just past it (she is in the
	# air there, taking the three above).
	var ring := _ring_points(564, 33, 6, 16)
	ring.remove_at(13)
	ring.remove_at(12)
	rush.append_array(ring)
	for up in [38.0, 52.0, 66.0]:
		rush.append(Vector2(_t(564), _t(27) - up))
	var wheel := _bonus_zone("gather", BONUS_WHEEL, Vector2(_t(546), _t(40)), Vector2(_t(555), _t(40) - 14),
		"l22_token1", 18.0, "Get all the Resin!", rush)
	_bonus_door(_t(269.5), 208.0, wheel, Vector2(_t(267), 208.0), -1)
	# Bonus 2 (the cave): two small mills between ledges over a drop: up and
	# over the first, down and under the second.
	_mill("BonusSailA", 604, 36, 4, 4, 8.0, 1, 0.0, 2.0)
	_mill("BonusSailB", 619, 36, 4, 4, 8.0, -1, 0.0, 2.0)
	var pile: Array = [Vector2(_t(594.5), _t(36) - 12), Vector2(_t(596.5), _t(36) - 12)]
	for i in 7:
		var a := deg_to_rad(lerpf(195.0, 325.0, i / 6.0))
		pile.append(Vector2(_t(604), _t(36)) + Vector2(cos(a), sin(a)) * _t(4) + Vector2(0, -14))
	pile.append(Vector2(_t(610.7), _t(36) - 12))
	pile.append(Vector2(_t(612.3), _t(36) - 12))
	for i in 7:
		var a := deg_to_rad(lerpf(145.0, 25.0, i / 6.0))
		pile.append(Vector2(_t(619), _t(36)) + Vector2(cos(a), sin(a)) * _t(4) + Vector2(0, -14))
	pile.append(Vector2(_t(627), _t(36) - 12))
	pile.append(Vector2(_t(629.5), _t(36) - 12))
	var sails := _bonus_zone("gather", BONUS_SAILS, Vector2(_t(592.5), _t(36)), Vector2(_t(631), _t(36) - 36),
		"l22_token2", 20.0, "Get all the Resin!", pile)
	_bonus_door(_t(143), _t(29), sails, Vector2(_t(139.5), _t(29)), -1)
