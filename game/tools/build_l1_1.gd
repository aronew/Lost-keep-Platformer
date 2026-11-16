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
## the treetops, and a crate thrown through a cracked wall into a bonus game.
##
## 440 x 36 tiles (about 11 screens by 1.6). The walking line is row 30
## (y 480) unless a beat lifts it. Four beats, each opened by a checkpoint:
## TEACH (x 0-94), TEST (94-200), TWIST (200-340), FINISH (340-440).

const ROOM_PATH := "res://scenes/levels/l1_1_overgrown_ruins.tscn"
const G := 480.0  # the ground's walking line (row 30)

const ROOM := Rect2i(0, 0, 440, 36)
const ROCK := [
	[0, 30, 440, 6, 0],      # the ground
	# TEACH: up the stone terraces onto the stall's arches
	[14, 28, 4, 2, 0],       # terrace 1 (2 up)
	[18, 26, 4, 4, 0],       # terrace 2 (2 up)
	[22, 24, 18, 2, 0],      # the stall's floor, on arches (2 up)
	[22, 26, 2, 4, 0],       # its piers: the arches between them open onto a nook
	[30, 26, 2, 4, 0],
	[38, 26, 2, 4, 0],
	[82, 25, 8, 5, 0],       # the ruin block with the chest on top (5 up: a ledge catch)
	# TEST: wall terraces up to the plateau, the log, the banks, down again
	[100, 27, 6, 3, 0],      # terrace (3 up)
	[106, 24, 26, 6, 0],     # the plateau (3 up): the first Thornhound
	[144, 25, 16, 5, 0],     # the east bank, past the log (1 down)
	[164, 23, 12, 7, 0],     # the ruin mass (4 across, 2 up)
	[176, 26, 6, 4, 0],      # a step down (3 down): the false wall's face is its east side
	# TWIST: the hill (the cracked wall in its foot, the bonus room under it)
	[236, 27, 56, 3, 0],     # the hill (3 up)
	# FINISH: the last stretch and the way out
	[384, 28, 10, 2, 0],     # a block past the second pit (2 up)
	[400, 27, 40, 3, 0],     # the end terrace (3 up)
	[412, 24, 28, 3, 0],     # the end ledge (3 up): the arched doorway
]
const SPACES := [
	[64, 30, 14, 6],         # the water pit (the mockup's)
	[132, 30, 12, 6],        # the ravine under the log
	[160, 30, 4, 6],         # the gap between the bank and the ruin mass
	[177, 27, 5, 3],         # the false wall's hollow (cocoon 1)
	[236, 28, 6, 2],         # the tunnel behind the cracked wall
	[242, 28, 18, 6],        # the bonus room, under the hill
	[297, 30, 39, 6],        # the second water: islands at different heights
	[362, 30, 4, 6],         # a pit
	[380, 30, 4, 6],         # a pit, with a step up beyond it
]
const MASSES := [
	[68, 29, 6, 7, 0],       # the mushroom island (1 up)
	[246, 31, 3, 3, 0],      # the bonus room's two stone blocks (3 up from its floor)
	[253, 31, 3, 3, 0],
	[301, 28, 5, 8, 0],      # the islands: 2 up, 2 up, 3 down, 2 up, then 3 down to the bank
	[310, 26, 5, 10, 0],
	[319, 29, 5, 7, 0],
	[328, 27, 4, 9, 0],
]


func _initialize() -> void:
	room = ROOM
	rock = ROCK
	spaces = SPACES
	masses = MASSES
	skip = []
	spawn = Vector2(5 * TILE, G)
	room_path = ROOM_PATH
	blockout = false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://scenes/levels"))
	_level_begin("L1_1_OvergrownRuins", "1-1 The Overgrown Ruins")
	_teach()
	_test()
	_twist()
	_finish_beat()
	if not blockout:
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
	_crate(_t(33), _t(24), CRATE_B)
	_breakable(CRATES, POT, _t(28), _t(24), CLAY)
	# The nook under the arches, reached from the east: a pot and a little cache.
	_breakable(CRATES, POT_BIG, _t(26), G, CLAY)
	_resin_cache(_root, _t(33), _t(36), G, 3, "l11_nook")
	_label("nook", Vector2(_t(32), G - 36))
	# The Mossback: seven hits, or one thrown crate.
	_mossback(_t(52), G, _t(44), _t(60))
	_label("MOSSBACK", Vector2(_t(49), G - 44))
	# The water pit and the mushroom island (gaps of 4).
	_water("WaterPit", Vector2(_t(64), G + 8), Vector2(_t(14), _t(6) - 8), Vector2(60, 30))
	_bead_arc(Vector2(_t(63.5), G), Vector2(_t(69), _t(29)), 30.0, 3, "l11_pit1a")
	_bead_arc(Vector2(_t(73), _t(29)), Vector2(_t(78.5), G), 30.0, 3, "l11_pit1b")
	_label("WATER PIT + MUSHROOM ISLAND", Vector2(_t(63), _t(25)))
	# The ruin block: a ledge catch up to the chest.
	_chest(_t(86), _t(25), 8, "l11_chest1")
	_label("CHEST ON A HIGH LEDGE\n(ledge catch)", Vector2(_t(80), _t(20)))


# --- TEST: the first Thornhound, the log, the gaps, the false wall ------------------------------

func _test() -> void:
	_checkpoint(_t(94), G, "l11_cp1")
	_label("CHECKPOINT 1", Vector2(_t(92), G - 76))
	_label("TEST", Vector2(_t(96), _t(16)))
	_beads([Vector2(_t(101), _t(27) - 12), Vector2(_t(104), _t(27) - 12), Vector2(_t(107), _t(24) - 12)], "l11_t")
	_thornhound(_t(122), _t(24), _t(108), _t(130))
	_label("THORNHOUND\n(notices, winds up, lunges)", Vector2(_t(112), _t(18)))
	# The fallen log over the ravine (one-way).
	_log(_root, _t(132), _t(144), _t(24))
	_water("Ravine", Vector2(_t(132), G + 8), Vector2(_t(12), _t(6) - 8), Vector2(40, 30))
	_beads([Vector2(_t(135), _t(24) - 12), Vector2(_t(138), _t(24) - 12), Vector2(_t(141), _t(24) - 12)], "l11_log")
	_label("FALLEN LOG", Vector2(_t(134), _t(21)))
	# The gap up to the ruin mass (4 across, 2 up), and its water.
	_water("Gap", Vector2(_t(160), G + 8), Vector2(_t(4), _t(6) - 8), Vector2(20, 30))
	_bead_arc(Vector2(_t(159.5), _t(25)), Vector2(_t(165), _t(23)), 34.0, 3, "l11_gap")
	# The false wall: the step's east face hides a hollow (cocoon 1). Its tell:
	# motes drifting into the stone.
	_false_wall("FalseWall", Rect2i(177, 27, 5, 3), 182, Vector2i(27, 3), 1, "l11_secret1")
	_draught("FalseWallDraught", Rect2(_t(183), _t(27), _t(3), _t(3)), Vector2(-1, 0))
	_cocoon(Vector2(_t(179), G - 2), "l11_cocoon1", "Wren, a Rootling baker", 36.0)
	_resin_cache(_root, _t(180), _t(181.5), G, 2, "l11_secret1_cache")
	_label("FALSE WALL\n(cocoon 1)", Vector2(_t(176), _t(23) - 30))
	_breakable(CRATES, BARREL, _t(188), G, WOOD)


# --- TWIST: crates and the cracked wall, the treetops, the islands ----------------------------------

func _twist() -> void:
	_checkpoint(_t(196), G, "l11_cp2")
	_label("CHECKPOINT 2", Vector2(_t(194), G - 76))
	_label("TWIST", Vector2(_t(198), _t(8)))
	_crate(_t(202.5), G, CRATE_B)
	_crate(_t(205.5), G, CRATE_C)
	_label("CRATES", Vector2(_t(201), G - 40))
	# The cracked wall in the hill's foot; the tunnel; the bonus room under the hill.
	_cracked_wall(Rect2i(236, 28, 2, 2), "l11_crack")
	_label("CRACKED WALL\n(throw a crate)", Vector2(_t(226), G - 50))
	var floor_b := _t(34)
	_bonus_room(Rect2(_t(242), _t(28), _t(18), _t(6)), [
		Vector2(_t(243.5), floor_b - 12), Vector2(_t(245), floor_b - 12), Vector2(_t(250.5), floor_b - 12),
		Vector2(_t(252), floor_b - 12), Vector2(_t(257), floor_b - 12), Vector2(_t(258.5), floor_b - 12),
		Vector2(_t(247), _t(31) - 12), Vector2(_t(248), _t(31) - 24), Vector2(_t(254), _t(31) - 12),
		Vector2(_t(255), _t(31) - 24), Vector2(_t(251), _t(29) + 4), Vector2(_t(244), _t(29) + 4)],
		Vector2(_t(257.5), floor_b - 4), "l11_bonus", "l11_cocoon2", "Oren, an Ironbark scout", 14.0)
	_label("BONUS ROOM: gather 12 beads\nin 14 s (cocoon 2)", Vector2(_t(243), _t(34) + 4))
	# The great tree whose branches she climbs, and the trees whose crowns
	# carry the canopy route (backdrop only: no collision).
	_backdrop_tree(_t(214), G, _t(12), 64.0, 200.0)
	for c in [[225, 15], [241, 14], [256, 16], [271, 14], [285, 15]]:
		_backdrop_tree(_t(c[0]), _t(27), _t(c[1]) - 4, 22.0, 190.0)
	_backdrop(_box(Rect2(_t(23), _t(18), _t(16), 6)))  # the stall's roof
	_backdrop(_box(Rect2(_t(24), _t(18), 4, _t(6))))
	_backdrop(_box(Rect2(_t(37), _t(18), 4, _t(6))))
	# The branch ladder up the great tree, to the canopy route over the hill.
	for b in [[208, 216, 27], [213, 221, 24], [207, 215, 21], [212, 220, 18]]:
		_log(_root, _t(b[0]), _t(b[1]), _t(b[2]))
	_beads([Vector2(_t(212), _t(27) - 12), Vector2(_t(217), _t(24) - 12), Vector2(_t(211), _t(21) - 12), Vector2(_t(216), _t(18) - 12)], "l11_ladder")
	_label("BRANCHES UP THE GREAT TREE", Vector2(_t(222), _t(22)))
	# The canopy: leaf tops at different heights, gaps of 4, beads all the way.
	var canopy := [[218, 232, 15], [236, 246, 14], [250, 262, 16], [266, 276, 14], [280, 290, 15]]
	var i := 0
	for c in canopy:
		_canopy(_t(c[0]), _t(c[1]), _t(c[2]))
		_beads([Vector2(_t(c[0] + 3), _t(c[2]) - 12), Vector2(_t((c[0] + c[1]) * 0.5), _t(c[2]) - 12), Vector2(_t(c[1] - 3), _t(c[2]) - 12)], "l11_canopy%d" % i)
		i += 1
	_cocoon(Vector2(_t(288), _t(15) - 2), "l11_cocoon3", "Ysolde, a Hearth-Plains weaver")
	_label("CANOPY ROUTE (secret, over the treetops)", Vector2(_t(236), _t(10)))
	_label("cocoon 3", Vector2(_t(285), _t(9)))
	# The hill: the second Thornhound.
	_thornhound(_t(272), _t(27), _t(246), _t(289))
	_label("THORNHOUND", Vector2(_t(262), _t(27) - 40))
	# The second water: islands at different heights, gaps of 4.
	_water("IslandWater", Vector2(_t(297), G + 8), Vector2(_t(39), _t(6) - 8), Vector2(200, 30))
	var tops := [[296.5, 30], [303, 28], [312, 26], [321, 29], [330, 27], [337, 30]]
	for k in tops.size() - 1:
		var a: Array = tops[k]
		var b: Array = tops[k + 1]
		_bead_arc(Vector2(_t(a[0] + 1.5), _t(a[1])), Vector2(_t(b[0] - 1.5), _t(b[1])), 30.0, 2, "l11_isl%d" % k)
	_label("ISLANDS AT DIFFERENT HEIGHTS", Vector2(_t(303), _t(22)))


# --- FINISH: a run to the doorway: pits, thorns, a last chest -------------------------------------

func _finish_beat() -> void:
	_checkpoint(_t(340), G, "l11_cp3")
	_label("CHECKPOINT 3", Vector2(_t(338), G - 76))
	_label("FINISH", Vector2(_t(342), _t(16)))
	_mossback(_t(352), G, _t(344), _t(359))
	_bead_arc(Vector2(_t(361), G), Vector2(_t(367), G), 26.0, 3, "l11_pit2")
	_label("PIT", Vector2(_t(362), G - 30))
	_thorns(_t(371), _t(374), G)
	_label("THORNS", Vector2(_t(370), G - 30))
	_bead_arc(Vector2(_t(379), G), Vector2(_t(385), _t(28)), 30.0, 3, "l11_pit3")
	_label("PIT, STEP UP", Vector2(_t(378), G - 46))
	_breakable(CRATES, POT, _t(397), G, CLAY)
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


func _dress() -> void:
	var behind: Node = _root.get_node("Behind")
	var placed: Node = _root.get_node("PlacedArt")
	var w := G + 8.0  # the water's surface
	# TEACH. The arch she came through; the terraces; the stall on its arches.
	_arch_door(behind, -40, G, false)
	_plant(behind, FERN_LOW, 150, G)
	_plant(behind, GRASS, 232, _t(28))
	_plant(behind, FLOWERS_B, 300, _t(26))
	_piece(behind, TIMBER_GATE, 372, _t(24), "StallFrame")
	_ground(behind, CRATES, BARREL, 462, _t(24) + 1, 1.0, "Barrel")
	_ground(behind, CRATES, KEG, 488, _t(24) + 1, 1.0, "Keg")
	_lantern_post(behind, 580, _t(24))
	_hanging_lamp(behind, 432, _t(26), 30.0)
	_hanging_lamp(behind, 560, _t(26), 30.0)
	_drape(placed, DRAPE, 364, _t(26))
	_drape(placed, DRAPE_LONG, 470, _t(26))
	_drape(placed, DRAPE, 590, _t(26))
	_plant(behind, FERN, 690, G)
	_plant(behind, GRASS_FLOWERS, 880, G, true)
	_plant(behind, BUSH_LOW, 960, G)
	# The water pit and the mushroom island (flowers, not red caps).
	_lilies(behind, _t(64) + 6, _t(78), w)
	_plant(behind, REED_TALL, _t(64) - 22, G)
	_plant(behind, REED, _t(78) - 6, G)
	_plant(behind, FLOWERS_B, _t(68) + 6, _t(29))
	_plant(behind, FERN_LOW, _t(70) + 4, _t(29), true)
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
	var falls := _sprite(behind, PL, FALLS, Vector2(_t(134), w - FALLS.size.y + 2.0))
	falls.name = "AqueductFalls"
	_lilies(behind, _t(132) + 4, _t(144), w)
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
	# The canopy route's trees: trunks rising out of the hill into the crowns.
	for c in [[225, 15], [241, 14], [256, 16], [271, 14], [285, 15]]:
		var trunk := _sprite(behind, GT, TRUNK, Vector2(_t(c[0]) - TRUNK.size.x * 0.5, _t(27) + 8.0 - TRUNK.size.y))
		trunk.name = "CanopyTrunk"
		trunk.set_meta("no_tint", true)
		trunk.flip_h = c[0] % 2 == 0
	_plant(behind, FERN_LOW, _t(230), G)
	_drape(placed, DRAPE, _t(236), _t(28) + 2)
	# The hill: grass, a ruin; the bonus room's lamps.
	_plant(behind, GRASS_FLOWERS, _t(244), _t(27))
	_ground(behind, IS, SMALL_ARCH, _t(262), _t(27) + 1, 0.9, "HillArch")
	_plant(behind, FERN, _t(280), _t(27), true)
	_hanging_lamp(behind, _t(247), _t(28), 22.0)
	_hanging_lamp(behind, _t(255), _t(28), 22.0)
	# The islands across the second water.
	_lilies(behind, _t(297) + 4, _t(336), w)
	for isl in [[301, 28], [310, 26], [319, 29], [328, 27]]:
		_plant(behind, FLOWERS_C if isl[0] % 2 == 0 else FLOWERS_B, _t(isl[0]) + 10, _t(isl[1]))
	_plant(behind, REED_TALL, _t(297) - 30, G)
	_plant(behind, REED, _t(336) + 2, G, true)
	# FINISH. The last run: grass, a ruin by the pits, a lantern up the terraces.
	_plant(behind, GRASS, _t(346), G)
	_plant(behind, BUSH_LOW, _t(366), G)
	_piece(behind, DOOR_RUINED, _t(386), _t(28), "PitRuin").modulate = Color(0.9, 0.9, 0.95)
	_lantern_post(behind, _t(404), _t(27))
	_plant(behind, FERN_LOW, _t(414), _t(24))
	_plant(behind, GRASS_FLOWERS, _t(434), _t(24), true)
