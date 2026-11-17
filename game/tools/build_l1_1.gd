extends "res://tools/level_builder.gd"
## Builds level 1-1, The Overgrown Ruins, and saves it as an ordinary scene.
## The blockout was approved by the creative lead; this is the art pass
## (`blockout = false`; set it true to see the black box and the labels
## again). Dressed from the Ironbark surface kit; what the kit lacks is asked
## for in Book 3 (docs/art-production/platformer-region1-prompt-book.html).
##
##   godot --headless --path game --script res://tools/build_l1_1.gd
##
## Spec: design/levels/1-1_overgrown_ruins.md. After the creative lead's
## mockups: docs/mockups/platformer/outdoor_level_1_mockup.webp (the stall on
## stone arches, the water pit and its mushroom island, the chest on a high
## ledge, the arched doorway out) and natural_traversal/ (log and root bridges
## over water, stepped stone terraces, crates, islands at different heights);
## and Donkey Kong Country's way with land, wall terraces, a secret route over
## the treetops, letters to find (K-L-E-O) and hidden ways into bonus areas.
##
## The level is 440 x 40 tiles (about 11 screens by 1.8); its two bonus areas
## lie beside it, x 452-536, out of its view (the room is 540 wide; the camera
## holds to MAIN while she is in the level). The walking line is row 30
## (y 480) unless a beat lifts it; still water runs under everything two tiles
## below it (WATER_Y, the creative lead's mockups), and the hill rises from
## the water bed with the bonus cave inside it. Four beats, each opened by a checkpoint:
## TEACH (x 0-94), TEST (94-200), TWIST (200-340), FINISH (340-440).

const ROOM_PATH := "res://scenes/levels/l1_1_overgrown_ruins.tscn"
const G := 480.0  # the ground's walking line (row 30)
const WATER_Y := 512.0  # the water's surface, two tiles under the ground's walking line

const ROOM := Rect2i(0, 0, 540, 40)
const MAIN := Rect2i(0, 0, 440, 40)
## The bonus areas (BonusZone), beside the level and out of its view.
const BONUS_GATHER := Rect2i(452, 16, 40, 24)
const BONUS_COURSE := Rect2i(496, 16, 40, 24)
const ROCK := [
	[0, 30, 440, 10, 0],     # the ground (under the water from row 32 down)
	# TEACH: up the stone terraces onto the stall's arches
	[14, 28, 4, 2, 0],       # terrace 1 (2 up)
	[18, 26, 4, 4, 0],       # terrace 2 (2 up)
	[22, 24, 18, 2, 0],      # the stall's floor, on arches (2 up); its piers are the
	                         # stall painting's own (STALL_PIERS), not tiles
	[82, 25, 8, 5, 0],       # the ruin block with the chest on top (5 up: a ledge catch)
	# TEST: wall terraces up to the plateau, the log, the banks, down again
	[100, 27, 6, 3, 0],      # terrace (3 up)
	[106, 24, 29, 6, 0],     # the plateau (3 up): the first enemy that fights; it meets the log
	[144, 25, 16, 5, 0],     # the east bank, past the log (1 down)
	[164, 23, 12, 7, 0],     # the ruin mass (4 across, 2 up)
	[176, 26, 6, 4, 0],      # a step down (3 down): the false wall's face is its east side
	# TWIST: the hill (a false wall in its foot, a hidden cave under it)
	[236, 27, 56, 3, 0],     # the hill (3 up)
	[239, 24, 8, 3, 0],      # a raised root bank on the hill (3 up): crates on it lead to the treetops
	# FINISH: the last stretch and the way out
	[384, 28, 10, 2, 0],     # a block past the second pit (2 up)
	[400, 27, 40, 3, 0],     # the end terrace (3 up)
	[412, 24, 28, 3, 0],     # the end ledge (3 up): the arched doorway
	# Beside the level, out of its view: rock between it and the bonus areas.
	[440, 0, 12, 40, 0],
	# Bonus 1, "gather" (x 452-492): raised ground, 2 and 3 up, gaps of 4.
	[452, 30, 40, 10, 0],
	[457, 27, 4, 3, 0],
	[465, 25, 5, 5, 0],
	[474, 27, 4, 3, 0],
	[482, 25, 10, 5, 0],
	[492, 0, 4, 40, 0],
	# Bonus 2, "course" (x 496-536): small stone pillars over a drop.
	[496, 30, 6, 10, 0],     # the start ledge
	[505, 29, 3, 11, 0],     # 3 across, 1 up
	[512, 27, 3, 13, 0],     # 4 across, 2 up
	[519, 29, 3, 11, 0],     # 4 across, 2 down
	[526, 27, 3, 13, 0],     # 4 across, 2 up
	[532, 27, 4, 13, 0],     # 3 across: the token
	[536, 0, 4, 40, 0],
]
const SPACES := [
	[64, 30, 13, 10],         # the water pit (the mockup's)
	[135, 30, 9, 10],         # the ravine under the fallen trunk
	[160, 30, 4, 10],         # the gap between the bank and the ruin mass
	[177, 27, 5, 3],         # the false wall's hollow (letter L)
	[236, 28, 6, 2],         # the tunnel behind the hill's false wall
	[242, 28, 18, 6],        # the hidden cave under the hill: bonus 1's entrance
	[297, 30, 35, 10],        # the second water: islands at different heights
	[362, 30, 4, 10],         # a pit
	[380, 30, 4, 10],         # a pit, with a step up beyond it
]
const MASSES := [
	# The islands float over the water (Book 4's D5): each mass is the top of
	# its painting, as wide as its walking line.
	[68, 29, 6, 2, 0],        # the mushroom island (1 up): island C, 96 wide
	[246, 31, 3, 3, 0],      # the cave's two stone blocks (3 up from its floor)
	[253, 31, 3, 3, 0],
	[301, 28, 4, 2, 0],       # the islands: 2 up, 2 up, 3 down, 2 up, then 3 down to the bank
	[309, 26, 4, 2, 0],       # (islands B, 64 wide, and A, 48; gaps of 4)
	[317, 29, 4, 2, 0],
	[325, 27, 3, 2, 0],
]


## The canopy route: [x0, x1, row, tree, flip] of each treetop (8 rows over
## the hill at its lowest, so only the crates reach it): each walkway is the
## flat top of one of Book 3's three trees (W7), centred on its crown.
const TREETOPS := [[244, 251, 18, 1, false], [255, 263, 17, 0, false], [267, 273, 19, 2, false], [277, 284, 17, 1, true]]
## The stall's piers, from its painting (art x, width; the painting's left
## edge stands at the slab's left end, x 352).
const STALL_PIERS := [[9, 31], [123, 32], [243, 33]]
## By day the stall is gone (the creative lead: it "looks out of place with
## the new tile set"): its slab is an earth terrace on three earth piers,
## drawn by the ground's own skin, where the painted piers stood.
const DAY_PIERS := [[22, 26, 3, 4, 0], [30, 26, 2, 4, 0], [37, 26, 3, 4, 0]]
## The islands' paintings (Book 4's D5) for each mass: [x, row, piece].
const ISLAND_ART := [[68, 29, "island-c"], [301, 28, "island-b"], [309, 26, "island-b"], [317, 29, "island-b"], [325, 27, "island-a"]]


func _initialize() -> void:
	room = ROOM
	rock = ROCK + (DAY_PIERS if daylight else [])
	spaces = SPACES
	masses = MASSES
	skip = [] if blockout else ([] if daylight else [[22, 24, 18, 2]]) + MASSES.filter(func(m): return m[0] != 246 and m[0] != 253).map(func(m): return [m[0], m[1], m[2], m[3]])
	spawn = Vector2(5 * TILE, G)
	room_path = ROOM_PATH
	blockout = false
	main_floor = G
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://scenes/levels"))
	_level_begin("L1_1_OvergrownRuins", "1-1 The Overgrown Ruins")
	_root.set("main_area", MAIN)
	# The water under everything, but for the hill, which stands on the water
	# bed with the bonus cave inside it.
	_water_foreground(WATER_Y, [[0.0, _t(236)], [_t(292), _t(440)]])
	if not blockout:
		_face_under_water(_t(236), -1)
		_face_under_water(_t(292), 1)
	_teach()
	_test()
	_twist()
	_finish_beat()
	if not blockout:
		if daylight:
			_dress_day()
		else:
			_dress()
	_level_finish()
	quit()


func _t(x: float) -> float:
	return x * TILE


# --- TEACH: run, jump, the combo, a crate, water, a ledge catch, a chest -------------------------

func _teach() -> void:
	_label("TEACH", Vector2(_t(2), _t(16)))
	_label("START", Vector2(_t(3), G - 40))
	# Beads up the terraces: they show the jumps.
	_beads([Vector2(_t(11), G - 12), Vector2(_t(13), G - 12), Vector2(_t(16), _t(28) - 12),
		Vector2(_t(20), _t(26) - 12), Vector2(_t(25), _t(24) - 12), Vector2(_t(27), _t(24) - 12)], "l11_a")
	_label("stone terraces", Vector2(_t(14), _t(25) - 4))
	_label("THE STALL ON ARCHES\n(a crate to carry)", Vector2(_t(26), _t(20)))
	for p in ([] if daylight and not blockout else STALL_PIERS):
		var b := _body("StallPier", 1)
		_node(_rect_shape(Vector2(p[1], 64), Vector2(_t(22) + p[0] + p[1] * 0.5, _t(26) + 32)), "Shape", b)
		if blockout:
			_shape(_blockout_node, _box(Rect2(_t(22) + p[0], _t(26), p[1], 64)), Color("#0b0812"), "Pier")
	_crate(_t(33), _t(24), CRATE_B)
	_day_breakable("clay-pot", _t(28), _t(24), CLAY)
	# The nook under the arches, reached from the east: a pot and a little cache.
	_day_breakable("clay-pot", _t(26), G, CLAY)
	_resin_cache(_root, _t(33), _t(36), G, 3, "l11_nook")
	_label("nook", Vector2(_t(32), G - 36))
	# The Mossback: seven hits, or one thrown crate.
	_mossback(_t(52), G, _t(44), _t(60))
	_label("MOSSBACK", Vector2(_t(49), G - 44))
	# The water pit and the mushroom island (gaps of 4).
	_bead_arc(Vector2(_t(63.5), G), Vector2(_t(69), _t(29)), 30.0, 3, "l11_pit1a")
	_bead_arc(Vector2(_t(72), _t(29)), Vector2(_t(77.5), G), 30.0, 3, "l11_pit1b")
	_letter(Vector2(_t(69.5), _t(29) - 22), "K", "l11_letter_k")
	_label("K", Vector2(_t(70), _t(29) - 60))
	_label("WATER PIT + MUSHROOM ISLAND", Vector2(_t(63), _t(25)))
	# The ruin block: a ledge catch up to the chest.
	_chest(_t(86), _t(25), 8, "l11_chest1")
	_label("CHEST ON A HIGH LEDGE\n(ledge catch)", Vector2(_t(80), _t(20)))


# --- TEST: the first enemy that fights (the rat), the log, the gaps, the false wall ------------------------------

func _test() -> void:
	_label("TEST", Vector2(_t(96), _t(16)))
	_beads([Vector2(_t(101), _t(27) - 12), Vector2(_t(104), _t(27) - 12), Vector2(_t(107), _t(24) - 12)], "l11_t")
	_lunger(_t(122), _t(24), _t(108), _t(130), "rat")
	_label("RAT\n(notices, winds up, lunges)", Vector2(_t(112), _t(18)))
	# The fallen trunk over the ravine (one-way): Book 3's W5 in the art pass.
	if blockout:
		_log(_root, _t(135), _t(144), _t(24))
	else:
		_canopy(_t(135), _t(144), _t(24), false)
	_beads([Vector2(_t(137), _t(24) - 12), Vector2(_t(139.5), _t(24) - 12), Vector2(_t(142), _t(24) - 12)], "l11_log")
	_label("FALLEN LOG", Vector2(_t(134), _t(21)))
	# The gap up to the ruin mass (4 across, 2 up), and its water.
	_bead_arc(Vector2(_t(159.5), _t(25)), Vector2(_t(165), _t(23)), 34.0, 3, "l11_gap")
	# The false wall: the step's east face hides a hollow (letter L). Its tell:
	# motes drifting into the stone.
	_false_wall("FalseWall", Rect2i(177, 27, 5, 3), 182, Vector2i(27, 3), 1, "l11_secret1")
	_draught("FalseWallDraught", Rect2(_t(183), _t(27), _t(3), _t(3)), Vector2(-1, 0))
	_letter(Vector2(_t(179), G - 14), "L", "l11_letter_l")
	_resin_cache(_root, _t(180), _t(181.5), G, 2, "l11_secret1_cache")
	_label("FALSE WALL\n(letter L)", Vector2(_t(176), _t(23) - 30))
	_day_breakable("barrel", _t(188), G, WOOD)


# --- TWIST: the hill's hidden cave, the treetops, the islands --------------------------------------

func _twist() -> void:
	# The level's one checkpoint, at its middle: the Guard's banner.
	_checkpoint(_t(196), G, "l11_mid")
	_label("MIDWAY BANNER\n(the checkpoint)", Vector2(_t(194), G - 84))
	_label("TWIST", Vector2(_t(198), _t(8)))
	_crate(_t(202.5), G, CRATE_B)
	_label("A CRATE\n(throw it at the rat)", Vector2(_t(200), G - 40))
	# The hill's foot is a false wall: a tunnel behind it drops into a hidden
	# cave under the hill, and at the cave's end a hollow glows: the way into
	# bonus 1. Its tell: motes drifting into the stone.
	_false_wall("HillWall", Rect2i(236, 28, 6, 2), 236, Vector2i(28, 2), -1, "l11_secret2")
	_draught("HillDraught", Rect2(_t(232), _t(28), _t(3), _t(2)), Vector2(1, 0))
	_label("FALSE WALL\n(a hidden cave)", Vector2(_t(228), G - 50))
	_resin_cache(_root, _t(249.5), _t(251.5), _t(34), 3, "l11_cave_cache")
	var floor_b := _t(34)
	var gather := _bonus_zone("gather", BONUS_GATHER, Vector2(_t(453.5), G), Vector2(_t(486.5), _t(25) - 36),
		"l11_token1", 12.0, "Gather every bead!", [
		Vector2(_t(455), G - 10), Vector2(_t(458), _t(27) - 12), Vector2(_t(460), _t(27) - 12),
		Vector2(_t(463), _t(25) - 30), Vector2(_t(466), _t(25) - 12), Vector2(_t(468), _t(25) - 12),
		Vector2(_t(471.5), _t(25) - 52), Vector2(_t(475.5), _t(27) - 12), Vector2(_t(480), _t(25) - 30),
		Vector2(_t(484), _t(25) - 12), Vector2(_t(487), _t(25) - 12), Vector2(_t(490), _t(25) - 12)])
	_bonus_door(_t(258.5), floor_b, gather, Vector2(_t(256), floor_b), -1, "ruin-hollow")
	_label("BONUS 1 ENTRANCE\n(in the hidden cave)", Vector2(_t(250), _t(28) + 2))
	# The level's great secret, a secret within a secret: Morvath's thorn knot
	# sleeps in the dark behind the glowing hollow. The hollow takes her to the
	# bonus every time she walks in; only once it is won does it let her by.
	_knot(Vector2(_t(259.4), floor_b - 14), "l11_knot")
	# The great tree by the crates (backdrop only), and the trees whose crowns
	# carry the canopy route.
	_backdrop_tree(_t(214), G, _t(12), 64.0, 200.0)
	for c in TREETOPS:
		_backdrop_tree(_t((c[0] + c[1]) * 0.5), _t(27), _t(c[2]) - 4, 22.0, 190.0)
	_backdrop(_box(Rect2(_t(23), _t(18), _t(16), 6)))  # the stall's roof
	_backdrop(_box(Rect2(_t(24), _t(18), 4, _t(6))))
	_backdrop(_box(Rect2(_t(37), _t(18), 4, _t(6))))
	# The way up to the treetops is the environment, not platforms (the
	# creative lead, after Donkey Kong Country): the root bank on the hill,
	# a crate on it, a stack of two beside it, then the first treetop.
	_box_stack(_t(243.6), _t(24), 1)   # top on row 22
	_box_stack(_t(246), _t(24), 2)     # top on row 20, flush with the bank's east end
	_beads([Vector2(_t(240.5), _t(24) - 12), Vector2(_t(243.6), _t(22) - 12), Vector2(_t(246), _t(20) - 12)], "l11_boxes")
	_label("ROOT BANK + STACKED CRATES\n(the way up)", Vector2(_t(236), _t(21)))
	# The canopy: treetops at different heights, gaps of 4, beads all the way.
	var i := 0
	for c in TREETOPS:
		_canopy(_t(c[0]), _t(c[1]), _t(c[2]), false)
		if i == 2:
			# The third treetop holds letter E in place of its middle bead.
			_beads([Vector2(_t(c[0] + 2), _t(c[2]) - 12), Vector2(_t(c[1] - 2), _t(c[2]) - 12)], "l11_canopy%d" % i)
			_letter(Vector2(_t((c[0] + c[1]) * 0.5), _t(c[2]) - 16), "E", "l11_letter_e")
		else:
			_beads([Vector2(_t(c[0] + 2), _t(c[2]) - 12), Vector2(_t((c[0] + c[1]) * 0.5), _t(c[2]) - 12), Vector2(_t(c[1] - 2), _t(c[2]) - 12)], "l11_canopy%d" % i)
		i += 1
	# At the treetops' end, a hollow in the last crown: the way into bonus 2.
	var course := _bonus_zone("course", BONUS_COURSE, Vector2(_t(498), G), Vector2(_t(534), _t(27) - 14),
		"l11_token2", 10.0, "Reach the token!")
	_beads([Vector2(_t(503.5), _t(29) - 22), Vector2(_t(510), _t(27) - 26), Vector2(_t(517), _t(27) - 22), Vector2(_t(524), _t(27) - 26),
		Vector2(_t(530.5), _t(27) - 22)], "l11_course")
	_bonus_door(_t(283.5), _t(17), course, Vector2(_t(280.5), _t(17)), -1, "root-hollow")
	_label("CANOPY ROUTE (secret, over the treetops; letter E)", Vector2(_t(252), _t(11)))
	_label("BONUS 2 ENTRANCE", Vector2(_t(281), _t(11)))
	# The hill: a second rat.
	_lunger(_t(272), _t(27), _t(248), _t(289), "rat")
	_label("RAT", Vector2(_t(262), _t(27) - 40))
	# The second water: islands at different heights, gaps of 4.
	# [from x, its row, to x, its row]: each jump, edge to edge.
	var hops := [[296.5, 30, 301.5, 28], [304.5, 28, 309.5, 26], [312.5, 26, 317.5, 29], [320.5, 29, 325.5, 27], [327.5, 27, 332.5, 30]]
	for k in hops.size():
		var h: Array = hops[k]
		_bead_arc(Vector2(_t(h[0]), _t(h[1])), Vector2(_t(h[2]), _t(h[3])), 30.0, 2, "l11_isl%d" % k)
	_label("ISLANDS AT DIFFERENT HEIGHTS", Vector2(_t(303), _t(22)))


# --- FINISH: a run to the doorway: pits, thorns, a last chest -------------------------------------

func _finish_beat() -> void:
	_label("FINISH", Vector2(_t(342), _t(16)))
	_mossback(_t(352), G, _t(344), _t(359))
	_bead_arc(Vector2(_t(361), G), Vector2(_t(367), G), 26.0, 3, "l11_pit2")
	_label("PIT", Vector2(_t(362), G - 30))
	_thorns(_t(371), _t(374), G)
	_label("THORNS", Vector2(_t(370), G - 30))
	_bead_arc(Vector2(_t(379), G), Vector2(_t(385), _t(28)), 30.0, 3, "l11_pit3")
	_label("PIT, STEP UP", Vector2(_t(378), G - 46))
	_letter(Vector2(_t(382), G - 62), "O", "l11_letter_o")
	_day_breakable("clay-pot", _t(397), G, CLAY)
	_beads([Vector2(_t(402), _t(27) - 12), Vector2(_t(406), _t(27) - 12), Vector2(_t(413), _t(24) - 12)], "l11_end")
	_chest(_t(419), _t(24), 8, "l11_chest2")
	_level_end(_t(428), _t(24), 48, 72)


# --- The art pass: dressing from the Ironbark surface kit ------------------------------------------

# Flora (props_flora.png): no red mushrooms (red is the Blight's).
const FERN := Rect2(6, 6, 73, 42)
const FERN_LOW := Rect2(11, 55, 48, 30)
const GRASS := Rect2(91, 24, 49, 24)
const GRASS_FLOWERS := Rect2(80, 52, 66, 32)
const BUSH_LOW := Rect2(161, 67, 83, 20)
const FLOWERS_A := Rect2(18, 134, 24, 14)
const FLOWERS_B := Rect2(63, 129, 33, 19)
const FLOWERS_C := Rect2(117, 129, 29, 19)
const DRAPE_LONG := Rect2(9, 162, 66, 50)
const DRAPE := Rect2(89, 162, 70, 37)
const REED_TALL := Rect2(124, 204, 37, 41)
const REED := Rect2(177, 214, 30, 31)
const LILY_A := Rect2(15, 227, 48, 17)
const LILY_B := Rect2(77, 231, 35, 13)
# Book 3's kit (game/assets/environment/wilds, made by tools/make_wilds.py).
const WILDS := "res://assets/environment/wilds/"
const TREE_PIECES := [[3, 39, 146, 198], [151, 39, 119, 198], [275, 41, 106, 196]]
## water_islands.png pieces: [x, y, w, h, walking line row].
const ISLAND_PIECES := [[5, 12, 78, 108, 43], [166, 3, 69, 117, 16], [323, 23, 55, 97, 35], [91, 32, 65, 88, 46], [245, 52, 68, 68, 67]]
const MUSHROOMS := [[9, 28, 35, 32], [51, 28, 32, 32], [90, 28, 35, 32], [131, 33, 33, 27], [171, 30, 35, 31], [211, 26, 36, 35]]
const FLOWERS := [[8, 84, 34, 31], [51, 84, 31, 31], [91, 83, 32, 32], [130, 83, 35, 32], [173, 87, 32, 28], [213, 82, 34, 33]]


## An island's painting (W4) on its mass: its walking line on the mass's top
## row, centred on the mass `tiles` wide at `tile_x`.
func _island_art(parent: Node, tile_x: int, row: int, piece: int, tiles: int) -> void:
	var r: Array = ISLAND_PIECES[piece]
	var cx := _t(tile_x + tiles * 0.5)
	var s := _sprite(parent, WILDS + "water_islands.png", Rect2(r[0], r[1], r[2], r[3]), Vector2(cx - r[2] * 0.5, _t(row) - (r[4] - r[1])))
	s.name = "Island"


## A clump from W4's flora sheet standing on `floor_y`, centred on `x`.
func _flora(parent: Node, r: Array, x: float, floor_y: float, flip := false) -> void:
	var s := _sprite(parent, WILDS + "flora.png", Rect2(r[0], r[1], r[2], r[3]), Vector2(x - r[2] * 0.5, floor_y - r[3] + 2))
	s.name = "Flora"
	s.flip_h = flip


# SF9 and SF11.
const TRUNK := Rect2(0, 1, 95, 118)
const FALLS := Rect2(274, 6, 93, 55)       # a ruined aqueduct arch with two falls
const AQUEDUCT := Rect2(3, 1, 219, 61)     # the arched bridge


func _plant(parent: Node, region: Rect2, x: float, floor_y: float, flip := false) -> Sprite2D:
	var s := _ground(parent, FLORA, region, x, floor_y + 1.0, 1.0, "Plant")
	s.flip_h = flip
	return s


func _drape(parent: Node, region: Rect2, x: float, under_y: float) -> void:
	var d := _sprite(parent, FLORA, region, Vector2(x, under_y - 3.0))
	d.name = "Drape"


func _lilies(parent: Node, x0: float, x1: float, water_y: float) -> void:
	var x := x0
	var i := 0
	while x < x1 - 40.0:
		var r: Rect2 = LILY_A if i % 2 == 0 else LILY_B
		var l := _sprite(parent, FLORA, r, Vector2(x, water_y - r.size.y + 6.0))
		l.name = "Lilies"
		l.z_index = 11
		x += 70.0 + 23.0 * (i % 3)
		i += 1


# --- The art pass by day: Book 4's Sunlit Woodland kit (D1 to D19) ---------------------------------

## The day kit's crowns by the width of the walkway each carries.
func _crown_for(tiles: int) -> String:
	return "tree-crown-b" if tiles <= 6 else "tree-crown-c"


## A day island (D5) on its mass: its walking line on the mass's top row,
## its walking span centred on the mass `tiles` wide at `tile_x`.
func _day_island(parent: Node, tile_x: int, row: int, piece: String, tiles: int) -> void:
	var d := _day(piece)
	var r: Rect2 = d["rect"]
	var span: Array = d["walking_span"]
	var span_w := float(span[1]) - float(span[0])
	var x := _t(tile_x) - (float(span[0]) - r.position.x) - (span_w - tiles * TILE) * 0.5
	var y := _t(row) - (float(d["walking_y"]) - r.position.y)
	_day_sprite(parent, piece, Vector2(x, y))


## Lily pads on the water surface `y` across [x0, x1).
func _day_lilies(x0: float, x1: float, y: float) -> void:
	var holder := _root.get_node_or_null("Lilies")
	if holder == null:
		holder = _node(Node2D.new(), "Lilies", _root)
		(holder as Node2D).z_index = 13
	var names := ["lily-pads-a", "lily-pads-b", "lily-pads-flower", "lily-pads-a"]
	var x := x0 + 14.0
	var k := int(x0) % 4
	while x < x1 - 20.0:
		_day_ground(holder, names[k % names.size()], x, y + 3.0, k % 2 == 1)
		x += 46.0 + float((k * 29) % 40)
		k += 1


func _dress_day() -> void:
	var behind: Node = _root.get_node("Behind")
	var placed: Node = _root.get_node("PlacedArt")
	var w := WATER_Y
	# TEACH. A ruined wall where she starts; grass and flowers up the terraces.
	_day_sprite(behind, "ruined-wall", Vector2(-24, G - 64))
	_day_ground(behind, "bank-grass-a", 150, G)
	_day_ground(behind, "flower-cluster", 232, _t(28))
	_day_ground(behind, "bank-grass-b", 300, _t(26), true)
	# The terrace where the stall stood: a ruined wall and a banner on it.
	_day_ground(behind, "ruined-wall", _t(34), _t(24))
	_day_ground(behind, "red-banner-pole", _t(24), _t(24))
	_day_ground(behind, "red-mushrooms", 640, G)
	_day_ground(behind, "wooden-bench", 880, G)
	_day_ground(behind, "flower-cluster", 1010, G, true)
	# The water pit and the mushroom island.
	_day_lilies(_t(64), _t(77), w)
	_day_ground(behind, "cattails-a", _t(64) - 10, G)
	_day_ground(behind, "reeds-a", _t(77) + 8, G)
	for isl in ISLAND_ART:
		var m: Array = MASSES.filter(func(mm): return mm[0] == isl[0])[0]
		_day_island(placed, isl[0], isl[1], isl[2], m[2])
	_day_ground(placed, "red-mushrooms", _t(73), _t(29))
	# The ruin block and its chest.
	_day_ground(behind, "broken-pillar", _t(83), _t(25))
	_day_ground(behind, "flower-cluster", _t(88), _t(25))
	# TEST. The wall terraces and the plateau's ruins.
	_day_ground(behind, "bank-grass-a", _t(101), _t(27))
	_day_ground(behind, "ruined-wall", _t(112), _t(24))
	_day_ground(behind, "broken-pillar", _t(127), _t(24))
	_day_ground(behind, "bank-grass-b", _t(119), _t(24), true)
	# The ravine and the fallen log (D6): its walking line (6 below its top)
	# on row 24, centred over the ravine, its ends on the banks.
	_day_lilies(_t(135), _t(144), w)
	_day_sprite(placed, "fallen-log", Vector2(_t(139.5) - 80.0, _t(24) - 6.0))
	_day_ground(behind, "cattails-b", _t(145), _t(25), true)
	_day_ground(behind, "flower-cluster", _t(151), _t(25))
	_day_lilies(_t(160), _t(164), w)
	_day_ground(behind, "ruined-wall", _t(170), _t(23))
	# The false wall's tell: ivy over its face, and the draught.
	for v in [[VINES[0], _t(181) + 4], [VINES[2], _t(181) - 10]]:
		var vine := _sprite(placed, FLORA, v[0], Vector2(v[1], _t(26) - 2))
		vine.name = "WallIvy"
		vine.z_index = 18  # over the false wall's cover: the tell must show
	# TWIST. A signpost by the crate; a great tree (D8) by the checkpoint.
	_day_ground(behind, "blank-signpost", _t(192), G)
	var gt := _day_ground(behind, "great-tree-1", _t(214), G + 2.0)
	gt.z_index = -1
	# The treetop route: each walkway a crown (D9), standing over a great tree
	# rooted on the hill behind it, so the crowns grow from real trunks.
	var k := 0
	for c in TREETOPS:
		var tiles: int = c[1] - c[0]
		var cx := _t((c[0] + c[1]) * 0.5)
		var trunk := _day_ground(behind, "great-tree-2" if k % 2 == 0 else "great-tree-1", cx, _t(27) + 2.0, k % 2 == 1)
		trunk.z_index = -2
		var piece := _crown_for(tiles)
		var d := _day(piece)
		var r: Rect2 = d["rect"]
		var span: Array = d["walking_span"]
		var span_mid := (float(span[0]) + float(span[1])) * 0.5 - r.position.x
		var crown := _day_sprite(behind, piece, Vector2(cx - span_mid, _t(c[2]) - (float(d["walking_y"]) - r.position.y)), c[4])
		crown.z_index = -1
		k += 1
	_day_ground(behind, "flower-cluster", _t(232), G)
	# The hill: grass, a ruin; the hidden cave's lamps.
	_day_ground(behind, "bank-grass-a", _t(244), _t(27))
	_day_ground(behind, "broken-pillar", _t(262), _t(27))
	_hanging_lamp(behind, _t(247), _t(28), 22.0)
	_hanging_lamp(behind, _t(255), _t(28), 22.0)
	_day_ground(behind, "red-banner-pole", _t(290), _t(27))
	# The islands across the second water.
	_day_lilies(_t(297), _t(332), w)
	_day_ground(behind, "cattails-a", _t(296), G)
	_day_ground(behind, "reeds-a", _t(333), G, true)
	# The water in front of the ground, all along: lily pads here and there.
	_day_lilies(_t(80), _t(130), w)
	_day_lilies(_t(185), _t(232), w)
	_day_lilies(_t(336), _t(360), w)
	# FINISH. The last run.
	_day_ground(behind, "bank-grass-b", _t(346), G)
	_day_ground(behind, "flower-cluster", _t(366), G)
	_day_lilies(_t(362), _t(366), w)
	_day_lilies(_t(380), _t(384), w)
	_day_ground(behind, "broken-pillar", _t(389), _t(28))
	_day_ground(behind, "lit-lantern-post", _t(404), _t(27))
	_day_ground(behind, "red-mushrooms", _t(410), _t(27))
	_day_ground(behind, "wooden-bench", _t(415), _t(24))
	_day_ground(behind, "red-banner-pole", _t(436), _t(24))


## The dusk art pass (Book 3 and Book 1), kept for `daylight = false`.
func _dress() -> void:
	var behind: Node = _root.get_node("Behind")
	var placed: Node = _root.get_node("PlacedArt")
	var w := WATER_Y  # the water's surface
	# TEACH. The arch she came through; the terraces; the stall on its arches.
	_arch_door(behind, -40, G, false)
	_plant(behind, FERN_LOW, 150, G)
	_plant(behind, GRASS, 232, _t(28))
	_plant(behind, FLOWERS_B, 300, _t(26))
	# The stall on its arches: Book 3's W3, its slab's walking line (art row
	# 101) on the slab's row 24, its piers where STALL_PIERS has them.
	var stall := _sprite(placed, WILDS + "stall_on_arches.png", Rect2(0, 0, 288, 192), Vector2(_t(22), _t(24) - 101))
	stall.name = "Stall"
	_light(behind, Vector2(_t(22) + 82, _t(24) + 40), LAMP, 0.95, 0.85, "StallArchLight")
	_light(behind, Vector2(_t(22) + 200, _t(24) + 40), LAMP, 0.95, 0.85, "StallArchLight")
	_light(behind, Vector2(_t(22) + 169, _t(24) - 54), LAMP, 0.8, 0.8, "StallLampLight")
	_plant(behind, FERN, 690, G)
	_flora(behind, MUSHROOMS[0], 300, _t(26))
	_flora(behind, MUSHROOMS[3], 640, G)
	_flora(behind, FLOWERS[3], 1010, G)
	_flora(behind, MUSHROOMS[1], _t(88) + 8, _t(25))
	_flora(behind, MUSHROOMS[5], _t(127), _t(24), true)
	_flora(behind, MUSHROOMS[4], _t(150), _t(25))
	_flora(behind, FLOWERS[0], _t(169), _t(23))
	_flora(behind, MUSHROOMS[2], _t(186), G)
	_flora(behind, FLOWERS[4], _t(228), G)
	_flora(behind, MUSHROOMS[0], _t(257), _t(27))
	_flora(behind, FLOWERS[2], _t(288), _t(27))
	_flora(behind, MUSHROOMS[3], _t(348), G, true)
	_flora(behind, FLOWERS[5], _t(392), _t(28))
	_flora(behind, MUSHROOMS[1], _t(409), _t(27))
	_flora(behind, FLOWERS[1], _t(430), _t(24))
	_plant(behind, GRASS_FLOWERS, 880, G, true)
	_plant(behind, BUSH_LOW, 960, G)
	# The water pit and the mushroom island (flowers, not red caps).
	_lilies(behind, _t(64) + 6, _t(78), w)
	_plant(behind, REED_TALL, _t(64) - 22, G)
	_plant(behind, REED, _t(78) - 6, G)
	_island_art(placed, 68, 29, 0, 5)
	# The ruin block and its chest, under a small arch.
	_ground(behind, IS, SMALL_ARCH, _t(84) - 2, _t(25) + 1, 0.95, "BlockArch")
	_drape(placed, DRAPE_LONG, _t(82) - 4, _t(25) + 8)
	_plant(behind, FLOWERS_A, _t(88), _t(25))
	# TEST. The wall terraces and the plateau's ruins.
	_plant(behind, GRASS, _t(101), _t(27))
	_ground(behind, IS, ARCADE, _t(109), _t(24) + 1, 0.95, "PlateauArcade")
	_tracery(behind, _t(124), _t(24))
	_plant(behind, FERN, _t(117), _t(24), true)
	# The ravine: a broken aqueduct arch spilling into it, the log across.
	var falls := _sprite(behind, PL, FALLS, Vector2(_t(135), w - FALLS.size.y + 2.0))
	falls.name = "AqueductFalls"
	_lilies(behind, _t(135) + 4, _t(144), w)
	# The fallen trunk (W5): its walking line (art row 55, 24 below its piece's
	# top) on row 24, centred over the ravine, its ends on the banks.
	var trunk_art := _sprite(placed, WILDS + "trunk_and_root_arch.png", Rect2(6, 31, 181, 74), Vector2(_t(139.5) - 90.0, _t(24) - 24.0))
	trunk_art.name = "FallenTrunk"
	_plant(behind, REED_TALL, _t(144) + 2, _t(25), true)
	_plant(behind, GRASS_FLOWERS, _t(150), _t(25))
	_plant(behind, FERN_LOW, _t(156), _t(25))
	_lilies(behind, _t(160), _t(164) + 40, w)
	_piece(behind, DOOR_RUINED, _t(166), _t(23), "MassRuin").modulate = Color(0.9, 0.9, 0.95)
	# The false wall's tell: ivy over its face, and the draught.
	for v in [[VINES[0], _t(181) + 4], [VINES[2], _t(181) - 10]]:
		var vine := _sprite(placed, FLORA, v[0], Vector2(v[1], _t(26) - 2))
		vine.name = "WallIvy"
		vine.z_index = 18  # over the false wall's cover: the tell must show
	# TWIST. The crates by the checkpoint; the great tree and its branches.
	_plant(behind, GRASS, _t(199), G)
	var tree := _sprite(behind, ENV + "landmark_great_ironbark.png", Rect2(1, 1, 255, 252), Vector2(_t(214) - 128, G - 248))
	tree.name = "GreatIronbark"
	tree.modulate = Color(0.86, 0.86, 0.92)
	# The canopy route's trees (W7): each crown's flat top (art row 46) on its
	# walkway, centred; the trunks run down behind the hill.
	for c in TREETOPS:
		var r: Array = TREE_PIECES[c[3]]
		var cx := _t((c[0] + c[1]) * 0.5)
		var tree_art := _sprite(behind, WILDS + "treetops.png", Rect2(r[0], r[1], r[2], r[3]), Vector2(cx - r[2] * 0.5, _t(c[2]) - (46 - r[1])))
		tree_art.name = "Treetop"
		tree_art.flip_h = c[4]
	_plant(behind, FERN_LOW, _t(230), G)
	_drape(placed, DRAPE, _t(236), _t(28) + 2)
	# The hill: grass, a ruin; the bonus room's lamps.
	_plant(behind, GRASS_FLOWERS, _t(244), _t(27))
	_ground(behind, IS, SMALL_ARCH, _t(262), _t(27) + 1, 0.9, "HillArch")
	_plant(behind, FERN, _t(280), _t(27), true)
	_hanging_lamp(behind, _t(247), _t(28), 22.0)
	_hanging_lamp(behind, _t(255), _t(28), 22.0)
	# The islands across the second water.
	_lilies(behind, _t(297) + 4, _t(332), w)
	for isl in ISLAND_ART.slice(1):
		var m: Array = MASSES.filter(func(mm): return mm[0] == isl[0])[0]
		_island_art(placed, isl[0], isl[1], isl[2], m[2])
	_plant(behind, REED_TALL, _t(297) - 30, G)
	_plant(behind, REED, _t(332) + 2, G, true)
	# Under the water, all along: sunken ruin stone, rubble and reeds (the
	# mockups' drowned courses and water plants), seen through the surface.
	_sunken()
	# FINISH. The last run: grass, a ruin by the pits, a lantern up the terraces.
	_plant(behind, GRASS, _t(346), G)
	_plant(behind, BUSH_LOW, _t(366), G)
	_piece(behind, DOOR_RUINED, _t(386), _t(28), "PitRuin").modulate = Color(0.9, 0.9, 0.95)
	_lantern_post(behind, _t(404), _t(27))
	_plant(behind, FERN_LOW, _t(414), _t(24))
	_plant(behind, GRASS_FLOWERS, _t(434), _t(24), true)


## Pier stone (SF11) and rubble (T2) sunk under the water, reeds and ferns
## growing up from the bed toward the surface: seen through the water, never
## crowding the surface itself.
const SUNK_PIERS := [Rect2(1, 79, 30, 54), Rect2(81, 80, 31, 44), Rect2(42, 141, 29, 44), Rect2(120, 140, 29, 46), Rect2(41, 80, 29, 35), Rect2(2, 141, 28, 37)]
const RUBBLE := [Rect2(13, 90, 11, 10), Rect2(40, 87, 18, 14), Rect2(74, 90, 12, 9), Rect2(69, 108, 17, 14), Rect2(40, 112, 13, 8)]

func _sunken() -> void:
	var bed := float(ROOM.end.y * TILE)
	var x := 40.0
	var k := 0
	while x < _t(440):
		var t := _t(1) * 0.0 + x
		var on_hill := t >= _t(236) and t < _t(292)
		if not on_hill:
			var r: Rect2 = SUNK_PIERS[k % SUNK_PIERS.size()]
			# A drowned course of stone, its top a tile or two under the surface.
			_underwater(PL, r, Vector2(x, WATER_Y + 26.0 + float((k * 13) % 22)), k % 2 == 1)
			var rb: Rect2 = RUBBLE[(k * 3) % RUBBLE.size()]
			_underwater(ENV_WILDS + "cracked_wall.png", rb, Vector2(x + 40.0, bed - 34.0 - float((k * 7) % 14)))
			var reed: Rect2 = REED_TALL if k % 3 == 0 else REED
			_underwater(FLORA, reed, Vector2(x + 70.0, WATER_Y + 40.0 + float((k * 11) % 16)), k % 2 == 0)
		x += 150.0 + float((k * 37) % 70)
		k += 1
