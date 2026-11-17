extends "res://tools/level_builder.gd"
## Builds level 1-2, The Gate Road, and saves it as an ordinary scene.
## A BLOCKOUT (`blockout = true`): the black box, labels, real or stand-in
## sprites for everything that acts. No art until the layout is approved.
##
##   godot --headless --path game --script res://tools/build_l1_2.gd
##
## Spec: design/levels/1-2_gate_road.md. The level's one idea is **hopping
## over water**: small stone islands standing in it, then the big floating
## islands above it (Lost Keep's IB-04, its pool with six islands and the high
## path, made long and horizontal; the creative lead's flooded_ruins/ and
## bright_day/ mockups).
##
## The level is 440 x 40 tiles (about 11 screens by 1.8); its two bonus areas
## lie beside it, x 452-536, out of its view. The walking line is row 30
## (y 480); still water runs under everything two tiles below it. Four beats:
## TEACH (x 0-112), TEST (112-220), TWIST (220-322), FINISH (322-440).

const ROOM_PATH := "res://scenes/levels/l1_2_gate_road.tscn"
const G := 480.0  # the ground's walking line (row 30)
const WATER_Y := 512.0  # the water's surface, two tiles under the walking line

const ROOM := Rect2i(0, 0, 540, 40)
const MAIN := Rect2i(0, 0, 440, 40)
const BONUS_COURSE := Rect2i(452, 16, 40, 24)  # bonus 1: the pillars
const BONUS_GATHER := Rect2i(496, 16, 40, 24)
const ROCK := [
	[0, 30, 440, 10, 0],     # the road (under the water from row 32 down)
	# TEACH: the road's broken wall stubs (hops over dry ground), two banks
	[16, 28, 3, 2, 0],       # stub 1 (2 up)
	[23, 28, 3, 2, 0],       # stub 2 (4 across)
	[30, 27, 3, 3, 0],       # stub 3 (4 across, 1 up)
	[86, 27, 4, 3, 0],       # a bank (3 up)
	[90, 25, 4, 5, 0],       # a higher bank (2 up): the first floating island is 4 across, 2 up
	# TEST: the old rampart across the road: up three terraces, down three
	[118, 27, 4, 3, 0],      # 3 up
	[122, 24, 4, 6, 0],      # 3 up
	[126, 21, 6, 9, 0],      # the tower's top (3 up): the high path leaves from here
	[132, 25, 4, 5, 0],      # 4 down, then 5 down to the road and the long pool
	[210, 27, 6, 3, 0],      # a block on the far bank (3 up): the high path's way down lands on it
	# TWIST: the road ends; terraces up to the floating islands
	[224, 27, 4, 3, 0],      # 3 up
	[228, 24, 4, 6, 0],      # 3 up; then only islands over open water
	# FINISH: the gatehouse
	[404, 27, 36, 3, 0],     # the end terrace (3 up); a false wall in its face
	[414, 24, 26, 3, 0],     # the gate's ledge (3 up): the arched gateway
	# Beside the level, out of its view: rock between it and the bonus areas.
	[440, 0, 12, 40, 0],
	# Bonus 1, "course" (x 452-492): stone pillars over a drop, at different heights.
	[452, 30, 6, 10, 0],     # the start ledge
	[462, 28, 3, 12, 0],     # 4 across, 2 up
	[469, 29, 3, 11, 0],     # 4 across, 1 down
	[476, 27, 3, 13, 0],     # 4 across, 2 up
	[483, 29, 3, 11, 0],     # 4 across, 2 down
	[489, 27, 3, 13, 0],     # 3 across, 2 up: the token
	[492, 0, 4, 40, 0],
	# Bonus 2, "gather" (x 496-536): raised ground, beads along and over it.
	[496, 30, 40, 10, 0],
	[502, 28, 4, 2, 0],
	[510, 26, 5, 4, 0],
	[519, 28, 4, 2, 0],
	[527, 26, 9, 4, 0],
	[536, 0, 4, 40, 0],
]
const SPACES := [
	[60, 30, 21, 10],        # the first water: two wide islands
	[140, 30, 60, 10],       # the long pool: seven small islands, the high path above
	[232, 30, 84, 10],       # open water: floating islands only
	[344, 30, 52, 10],       # the last water: stones, then floating islands, then a pillar
	[404, 28, 5, 2],         # the false wall's hollow in the end terrace (letter E)
]
## The islands. Stone islands stand on the water bed (down to row 40);
## floating islands are 3 thick.
const STONES := [
	[64, 29, 5], [73, 28, 4],                                  # the first water
	# The long pool, low path: a chain that changes at every hop (wide and
	# near, then narrower, higher, a drop, a rest, a small one, and out).
	[143, 29, 5], [152, 28, 4], [160, 26, 3], [167, 29, 4],
	[175, 28, 6], [185, 27, 3], [192, 29, 4],
	[171, 31, 3],                                              # a low stone off the safe line: risky Resin
	[348, 29, 4], [356, 27, 4], [388, 26, 4],                  # the last water
]
const FLOATING := [
	[98, 23, 12],                                              # TEACH: the first, over dry ground
	[136, 19, 12], [152, 17, 8], [164, 18, 24], [192, 16, 6], [202, 20, 8],   # TEST: the high path
	[236, 22, 10], [250, 24, 6], [260, 22, 26], [290, 24, 5], [299, 22, 8], [311, 25, 5],  # TWIST: the road
	[364, 25, 10], [378, 23, 6],                               # FINISH
]


func _initialize() -> void:
	room = ROOM
	rock = ROCK
	spaces = SPACES
	var m := []
	for s in STONES:
		m.append([s[0], s[1], s[2], 40 - s[1], 0])
	for f in FLOATING:
		m.append([f[0], f[1], f[2], 3, 0])
	# The old landing under the bank's edge (secret): a step in the bank's
	# face (4 down from the terrace) and a low stone shelf by the water.
	m.append([232, 31, 7, 9, 0])
	m.append([232, 27, 2, 4, 0])
	# The thorn knot's island (the great secret): behind and above the way she
	# came, reached only by jumping back west from the tower's top.
	m.append([119, 18, 4, 2, 0])
	masses = m
	skip = []
	spawn = Vector2(5 * TILE, G)
	room_path = ROOM_PATH
	# The art pass begins: the Flooded Sanctuary kit (Book 5). Set blockout
	# true to see the plan and its labels again.
	blockout = false
	kit = "sanctuary"
	main_floor = G
	_level_begin("L1_2_GateRoad", "1-2 The Gate Road")
	_root.set("main_area", MAIN)
	_water_foreground(WATER_Y, [[0.0, _t(440)]])
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


## Beads over each hop of a chain: [edge x, its row, landing x, its row] in tiles.
func _hops(hops: Array, flag: String, count := 2) -> void:
	for k in hops.size():
		var h: Array = hops[k]
		_bead_arc(Vector2(_t(h[0]), _t(h[1])), Vector2(_t(h[2]), _t(h[3])), 30.0, count, "%s%d" % [flag, k])


## Three beads along a real jump's arc, from a take-off just short of the
## edge at `edge` (tiles) on `row`, going right: she takes them in the air.
func _arc_pts(edge: float, row: float) -> Array:
	var t0 := Vector2(_t(edge) - 8.0, _t(row))
	return [t0 + Vector2(24, -52), t0 + Vector2(47, -66), t0 + Vector2(70, -54)]


# --- TEACH: hops with nothing to lose, the first water, the first floating island -----------------

func _teach() -> void:
	_label("TEACH", Vector2(_t(2), _t(16)))
	_label("START", Vector2(_t(3), G - 40))
	_beads([Vector2(_t(10), G - 12), Vector2(_t(12.5), G - 12)], "l12_a")
	# The road's broken wall stubs: the level's hops, first over dry ground.
	_hops([[15.5, 30, 16.5, 28], [18.5, 28, 23.5, 28], [25.5, 28, 30.5, 27]], "l12_stub")
	_label("WALL STUBS\n(hops over dry ground:\nnothing to lose)", Vector2(_t(15), _t(21)))
	_sanct_breakable("barrel", _t(38), G, WOOD)
	_mossback(_t(48), G, _t(42), _t(56))
	_label("MOSSBACK", Vector2(_t(45), G - 44))
	# The first water: two wide islands (gaps of 4).
	_hops([[59.5, 30, 64.5, 29], [68.5, 29, 73.5, 28], [76.5, 28, 81.5, 30]], "l12_w1", 3)
	_letter(Vector2(_t(71), _t(28) - 56), "K", "l12_letter_k")
	_label("K", Vector2(_t(70.6), _t(28) - 84))
	_label("THE FIRST WATER\n(two wide stone islands)", Vector2(_t(62), _t(22)))
	# The first floating island, over dry ground: a chest on it.
	_beads([Vector2(_t(88), _t(27) - 12), Vector2(_t(92), _t(25) - 12)], "l12_bank")
	_hops([[93.5, 25, 98.5, 23]], "l12_f0", 3)
	_chest(_t(105), _t(23), 8, "l12_chest1")
	_label("THE FIRST FLOATING ISLAND\n(over dry ground; a chest)", Vector2(_t(96), _t(17)))
	_backdrop_tree(_t(104), _t(23), _t(14), 30.0, 150.0)


# --- TEST: the long pool: seven small islands; the big floating islands above ---------------------

func _test() -> void:
	_label("TEST", Vector2(_t(114), _t(8)))
	_beads([Vector2(_t(120), _t(27) - 12), Vector2(_t(124), _t(24) - 12), Vector2(_t(129), _t(21) - 12)], "l12_ramp")
	_label("THE OLD RAMPART\n(terraces up and down)", Vector2(_t(119), _t(15)))
	# The low path (the main line): seven small islands, each at its own height.
	# Every level goes right: the knot is the one thing that asks her to turn
	# back. She sees it from the terraces, out of reach (6 up); the way is a
	# jump west from the tower's top (3 across, 3 up).
	_knot(Vector2(_t(120.5), _t(18) - 16), "l12_knot")
	# A chain, each hop a step on from the last (Super Mario World's way):
	# near and wide; farther; narrower and higher; a drop; a wide stone to
	# rest on (a pot); a small high one; down and out.
	_hops([[139.5, 30, 143.5, 29], [147.5, 29, 152.5, 28], [155.5, 28, 160.5, 26], [162.5, 26, 167.5, 29],
		[170.5, 29, 175.5, 28], [180.5, 28, 185.5, 27], [187.5, 27, 192.5, 29], [195.5, 29, 200.5, 30]], "l12_low")
	_sanct_breakable("barrel", _t(178.5), _t(28), WOOD)
	# Risky Resin beside the safe line: a low stone two tiles wide, a drop
	# onto it, a step back up. Beads never lie: where they hang, there is ground.
	_beads([Vector2(_t(171.7), _t(31) - 12), Vector2(_t(172.7), _t(31) - 12), Vector2(_t(173.4), _t(31) - 12)], "l12_risk")
	_label("risky Resin", Vector2(_t(170.6), _t(33) + 16))
	_label("THE LONG POOL: a chain of stones, no two hops alike (the main line)", Vector2(_t(146), _t(33) + 4))
	# The high path (secret): from the tower's top, over the big floating islands.
	_hops([[131.5, 21, 136.5, 19], [147.5, 19, 152.5, 17], [159.5, 17, 164.5, 18], [187.5, 18, 192.5, 16], [197.5, 16, 202.5, 20]], "l12_high")
	_chest(_t(156), _t(17), 6, "l12_chest2")
	_lunger(_t(176), _t(18), _t(168), _t(184), "rat")
	_label("RAT\n(on the great island)", Vector2(_t(170), _t(18) - 56))
	_letter(Vector2(_t(195), _t(16) - 16), "L", "l12_letter_l")
	_label("HIGH PATH (secret): the big floating islands, from the tower's top; a chest, letter L", Vector2(_t(138), _t(11)))
	# At the high path's end, a glowing hollow: bonus 1, a course of pillars.
	# (Both bonus areas are Resin rushes, the creative lead's: a ton of Resin
	# along the jumps; get every bead in time and the token is hers.)
	var rush: Array = [Vector2(_t(456.5), G - 10)]
	for h in [[458, 30], [465, 28], [472, 29], [479, 27], [486, 29]]:
		rush.append_array(_arc_pts(h[0], h[1]))
	for q in [[463.5, 28], [470.5, 29], [477.5, 27], [484.5, 29]]:
		rush.append(Vector2(_t(q[0]), _t(q[1]) - 12))
	var course := _bonus_zone("gather", BONUS_COURSE, Vector2(_t(454), G), Vector2(_t(490.5), _t(27) - 40),
		"l12_token1", 12.0, "Get all the Resin!", rush)
	_bonus_door(_t(208.5), _t(20), course, Vector2(_t(205.5), _t(20)), -1, "ruin-hollow")
	_label("BONUS 1 ENTRANCE", Vector2(_t(203), _t(15)))
	_sanct_breakable("barrel", _t(204), G, WOOD)


# --- TWIST: the road ends: the floating islands are the only way, an enemy on the great one -------

func _twist() -> void:
	# The level's one checkpoint, at its middle: the Guard's banner.
	_checkpoint(_t(220), G, "l12_mid")
	_label("MIDWAY BANNER\n(the checkpoint)", Vector2(_t(218), G - 84))
	_label("TWIST", Vector2(_t(222), _t(8)))
	_beads([Vector2(_t(226), _t(27) - 12), Vector2(_t(230), _t(24) - 12)], "l12_up")
	_hops([[231.5, 24, 236.5, 22], [245.5, 22, 250.5, 24], [255.5, 24, 260.5, 22], [285.5, 22, 290.5, 24],
		[294.5, 24, 299.5, 22], [306.5, 22, 311.5, 25]], "l12_isl")
	_lunger(_t(273), _t(22), _t(265), _t(281), "rat")
	_label("RAT\n(on the great island: room to fight)", Vector2(_t(266), _t(22) - 58))
	_label("THE ROAD ENDS: floating islands over open water (the main line)", Vector2(_t(238), _t(15)))
	# Off the bank's edge, under the first island: the old landing (a step down
	# its face, a stone shelf by the water) and, in the island's shadow, a
	# glowing hollow: bonus 2. Its tell: beads stepping down, the glow below.
	_beads([Vector2(_t(233), _t(27) - 12), Vector2(_t(235), _t(31) - 12), Vector2(_t(236.5), _t(31) - 12)], "l12_under")
	var pile: Array = [Vector2(_t(500), G - 10), Vector2(_t(501), G - 10)]
	# Along every block's top, a column over three of them (a jump on the
	# spot), and an arc over every hop.
	for q in [[503, 28], [504.5, 28], [511, 26], [512.5, 26], [514, 26], [520, 28], [521.5, 28],
			[528.5, 26], [530, 26], [531.5, 26], [533, 26], [534.5, 26]]:
		pile.append(Vector2(_t(q[0]), _t(q[1]) - 12))
	for q in [[512.5, 26], [521, 28], [533, 26]]:
		for up in [30, 46, 62]:
			pile.append(Vector2(_t(q[0]), _t(q[1]) - up))
	for h in [[506, 28], [515, 26], [523, 28]]:
		pile.append_array(_arc_pts(h[0], h[1]))
	var gather := _bonus_zone("gather", BONUS_GATHER, Vector2(_t(497.5), G), Vector2(_t(531.5), _t(26) - 36),
		"l12_token2", 16.0, "Get all the Resin!", pile)
	_bonus_door(_t(238.3), _t(31), gather, Vector2(_t(236.2), _t(31)), -1, "ruin-hollow")
	_label("THE OLD LANDING under the island (secret):\nBONUS 2 ENTRANCE", Vector2(_t(240), _t(29)))


# --- FINISH: thorns, stones up to the last islands, the gatehouse ---------------------------------

func _finish_beat() -> void:
	_label("FINISH", Vector2(_t(324), _t(16)))
	_thorns(_t(332), _t(335), G)
	_label("THORNS", Vector2(_t(331), G - 30))
	# Stones climbing out of the water onto two floating islands, then down a pillar.
	_hops([[343.5, 30, 348.5, 29], [351.5, 29, 356.5, 27], [359.5, 27, 364.5, 25], [373.5, 25, 378.5, 23],
		[383.5, 23, 388.5, 26], [391.5, 26, 396.5, 30]], "l12_fin")
	_letter(Vector2(_t(362), _t(25) - 46), "O", "l12_letter_o")
	_label("O", Vector2(_t(361.6), _t(25) - 74))
	_label("STONES, THEN ISLANDS, AT A RUN", Vector2(_t(352), _t(18)))
	# The end terrace's face is a false wall (motes drift into it): letter E.
	_false_wall("GateWall", Rect2i(404, 28, 5, 2), 404, Vector2i(28, 2), -1, "l12_secret1")
	_draught("GateDraught", Rect2(_t(400), _t(28), _t(3), _t(2)), Vector2(1, 0))
	_letter(Vector2(_t(407), G - 14), "E", "l12_letter_e")
	_label("FALSE WALL\n(letter E)", Vector2(_t(398), G - 62))
	_beads([Vector2(_t(410), _t(27) - 12), Vector2(_t(416), _t(24) - 12)], "l12_end")
	_chest(_t(421), _t(24), 8, "l12_chest3")
	_level_end(_t(428), _t(24), 48, 72)
	_label("THE GATEHOUSE", Vector2(_t(418), _t(17)))


# --- The art pass: Book 5's Flooded Sanctuary kit, after the creative lead's mockups ---------------

## Plants, by hand: [piece, tile x (its centre), floor row, flipped]. Each
## stands on flat ground well inside its ledge (`_sanct_plant` checks it).
const PLANTS := [
	# TEACH
	["fern", 9.5, 30, false], ["flowers", 13.5, 30, false], ["mushroom", 24.5, 28, false],
	["mushroom_big", 35, 30, false], ["grass", 41.5, 30, false], ["flowers_b", 52, 30, true], ["fern_tall", 57, 30, true],
	["mushrooms", 83.5, 30, false], ["grass", 92, 25, false],
	["fern", 100.5, 23, false], ["mushroom_big", 108, 23, true],
	["flowers", 96.5, 30, false], ["fern_tall", 113, 30, false], ["mushroom_b", 116, 30, false],
	# TEST
	["flowers_b", 128, 21, false], ["grass", 134, 25, true],
	["mushroom", 145.5, 29, false], ["fern", 176.6, 28, false],
	["fern_tall", 139, 19, false], ["flowers", 145, 19, false], ["mushroom_big", 166.6, 18, false], ["grass", 186, 18, false],
	["mushroom_b", 203.6, 20, false], ["fern", 207.5, 30, true], ["flowers", 213, 27, false], ["mushrooms", 217.4, 30, false],
	# TWIST
	["grass", 230, 24, false], ["flowers_b", 241, 22, false], ["fern_tall", 262, 22, false], ["mushroom_big", 283.5, 22, true],
	["mushroom", 303, 22, false],
	# FINISH
	["fern", 319.5, 30, false], ["flowers", 324, 30, false], ["mushroom_big", 339.5, 30, false],
	["flowers_b", 369.5, 25, false], ["mushroom_b", 381, 23, false], ["grass", 399, 30, false],
	["fern_tall", 411.5, 27, true], ["mushrooms", 417, 24, false], ["flowers", 436, 24, false],
]


func _dress() -> void:
	var behind: Node = _root.get_node("Behind")
	# The lantern hut where she starts (F10), and the ruins along the way
	# (F4): an arch holding the first floating island up, as the mockups'
	# ledges stand on arches; an archway on the rampart's top; pillars.
	_sanct_ground(behind, "hut", _t(3.5), G)
	_sanct_ground(behind, "arch", _t(104), G)
	_sanct_ground(behind, "archway", _t(129), _t(21))
	_sanct_ground(behind, "archway", _t(327.5), G, true)
	for p in [[45, 30], [111, 30], [201.5, 30], [317.5, 30], [342, 30], [406, 27]]:
		_sanct_ground(behind, "pillar", _t(p[0]), _t(p[1]))
	for p in PLANTS:
		_sanct_plant(behind, p[0], p[1], p[2], p[3])
	# The cavern's roof (F7) along the top of the level: seen from the high path.
	var cw: float = (_sanct("ceiling")["rect"] as Rect2).size.x
	var cx := 0.0
	while cx < _t(440):
		var c := _sprite(behind, _sanct("ceiling")["tex"], _sanct("ceiling")["rect"], Vector2(cx, 0))
		c.name = "Ceiling"
		cx += cw
	# Under the water (F9): drowned stone and water plants on the bed, seen
	# through the surface; lily pads on it where the water lies open.
	var stones := ["sunk_a", "sunk_c", "sunk_b", "sunk_d"]
	var weeds := ["weed_a", "weed_c", "weed_b"]
	var x := 30.0
	var k := 0
	while x < _t(440):
		var sd := _sanct(stones[k % stones.size()])
		_underwater(sd["tex"], sd["rect"], Vector2(x, WATER_Y + 30.0 + float((k * 13) % 18)), k % 2 == 1)
		var wd := _sanct(weeds[k % weeds.size()])
		_underwater(wd["tex"], wd["rect"], Vector2(x + 84.0, WATER_Y + 34.0 + float((k * 7) % 12)), k % 2 == 0)
		x += 170.0 + float((k * 37) % 80)
		k += 1
	var lilies := ["lily_a", "lily_b", "lily_c"]
	var holder := _node(Node2D.new(), "Lilies", _root) as Node2D
	holder.z_index = 13
	for span in [[60, 81], [140, 200], [232, 316], [344, 396]]:
		var lx := _t(span[0]) + 22.0
		var n := 0
		while lx < _t(span[1]) - 22.0:
			var ld := _sanct(lilies[n % 3])
			var lw: float = (ld["rect"] as Rect2).size.x
			# Only on open water: no stone island standing in it there.
			var open := true
			for c in range(int((lx - lw * 0.5 - 6.0) / TILE), int((lx + lw * 0.5 + 6.0) / TILE) + 1):
				if _is_solid_cell(Vector2i(c, 32)):
					open = false
			if open:
				var l := _sprite(holder, ld["tex"], ld["rect"], Vector2(lx - lw * 0.5, WATER_Y - 3.0).round())
				l.name = "Lily"
			lx += 58.0 + float((n * 31) % 44)
			n += 1
