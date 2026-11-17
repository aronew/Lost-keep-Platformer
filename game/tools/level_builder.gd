extends "res://tools/surface_builder.gd"
## Shared tools for the platformer's levels, on top of surface_builder.gd: the
## level's systems (checkpoints, hazards, the lunging enemy, chests, crates to
## carry and throw, cracked walls, moving platforms, letters, bonus areas, the
## level's end) and the blockout look.
##
## A level's own builder sets its plan (as a room's: rock, spaces, masses) and
## calls:
##
##   var t := _level_begin("NodeName", "1-1 The Overgrown Ruins")
##   ... systems and pieces ...
##   _level_finish()
##
## **Blockout first** (`blockout = true`): no terrain art, no backdrops. The
## collision shows as the black box on a flat pale sky, the interactive pieces
## wear their real or stand-in sprites, and labels name each beat, so a
## screenshot reads as a plan. Art comes after the blockout is approved.

## True: the level is shown as its black box (the creative lead reviews this first).
var blockout := true

const BLOCK_SKY_TOP := Color("#5d6f96")
const BLOCK_SKY_BOTTOM := Color("#8696b4")
const LABEL_INK := Color(0.93, 0.94, 0.97)
const LANTERN_SHEET := ENV + "props_lanterns.png"
const POST_DARK := Rect2(26, 65, 45, 61)
const POST_LIT := Rect2(26, 1, 45, 61)
const POST_LAMP := Vector2(34, 40)   # the lamp, from the post's top left
const ENV_WILDS := "res://assets/environment/wilds/"
const CRATES := ENV + "props_guard_belongings.png"

var _blockout_node: Node2D


func _level_begin(node_name: String, title: String) -> Dictionary:
	_unlit = CanvasItemMaterial.new()
	_unlit.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	_add_mat = CanvasItemMaterial.new()
	_add_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_add_mat.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	var tileset := _shared()
	_begin(node_name)
	_root.set("is_level", true)
	_root.set("level_name", title)
	if blockout:
		_blockout_sky()
	elif daylight:
		_build_backdrops()
		_day_backdrops()
	else:
		_build_backdrops()
		# Book 3's B2: the Triad sky with smaller moons (opaque, 256 tall; its
		# base colour runs on below it).
		var sky := _root.get_node("Sky") as Parallax2D
		var sky_art := sky.get_node("Art") as Sprite2D
		sky_art.texture = load(ENV_WILDS + "triad_sky.png")
		sky_art.position.y = 0.0
		sky_art.modulate = Color.WHITE
		sky.repeat_size = Vector2(768, 0)
		var base := sky.get_node("Base") as ColorRect
		base.position = Vector2(0, 255)
		base.size = Vector2(768, 420)
		base.color = Color("#3f7270")
		# Book 3's B1: the far aqueduct, between the far forest and the mid.
		var aq := _parallax("Aqueduct", Vector2(0.25, 0.15), ENV_WILDS + "far_aqueduct.png", 20.0)
		_root.move_child(aq, _root.get_node("Mid").get_index())
	_back_walls()
	if not blockout:
		# The levels' ground: by day the creative lead's earth and stone (Book
		# 4's D1 to D3); at dusk Book 3's ruin stone. Material 0 for every mass.
		_earth = (_sanct_material() if kit == "sanctuary" else _day_material()) if daylight else _ruin_material()
	var t := _terrain(tileset)
	if blockout:
		# The skin off: the black collision tiles show (as in box view).
		_root.get_node("TerrainSkin").set("skin_visible", false)
		vignette = false
	_blockout_node = _node(Node2D.new(), "Blockout", _root) as Node2D
	_blockout_node.z_index = 24
	return t


func _level_finish() -> void:
	if blockout:
		_edge_shades()
	elif daylight:
		_daylight()
		_level_foreground()
	else:
		_build_atmosphere()
		_level_foreground()
		_tint_surface_kit(_root)
		_edge_shades()
	_finish()


## The look: daylight (the creative lead: "make it more bright and fun like
## these mockups", docs/mockups/platformer/bright_day/). No dusk tint, no
## vignette, a blue sky, the distance pale and hazy, warm sun through the
## leaves, the lanterns barely glowing. False keeps Book 3's dusk.
## Until the bright-day kit (Book 4) arrives, the dusk kit is shown in it.
var daylight := true

## The creative lead's Sunlit Woodland kit (Book 4; tools/make_day.py): the
## native sheets and the kit's atlas (every piece's rectangle and anchors).
const ENV_DAY := "res://assets/environment/day/"
const DAY_T := ENV_DAY + "terrain/"
## The earth deep inside a mass: the fill darkens toward it over DAY_FADE tiles.
const DAY_EARTH_DEEP := Color("#6E4232")
const DAY_FADE := 10.0
## The sky-light rim on creatures and thorns (hit_flash.gdshader).
const DAY_RIM := 0.55
const DAY_RIM_SIDE := 0.25
## How much of a lantern's light is left in daylight.
const DAY_LAMP := 0.3

var _day_atlas := {}

## Which kit dresses the level: "day" (the Sunlit Woodland, Book 4; 1-1) or
## "sanctuary" (the Flooded Sanctuary, Book 5; 1-2: mossy purple stone in a
## teal-lit cavern, tools/make_sanctuary.py). Both are lit by `_daylight()`:
## no dusk tint, no vignette. The sanctuary's mood is its own teal distance.
var kit := "day"
const ENV_SANCT := "res://assets/environment/sanctuary/"
## The stone deep inside a sanctuary mass.
const SANCT_STONE_DEEP := Color("#2c2140")


## The sanctuary's stone (Book 5's F1 to F3): the mossy top band, the hanging
## underside, the wall face, and stone blocks all the way in. (Its corner
## pieces came back in other shapes than asked: not used; the bands meet.)
func _sanct_material() -> Resource:
	var m: Resource = load("res://scripts/world/terrain_material.gd").new()
	m.fill = load(ENV_SANCT + "terrain/sanct_fill.png")
	m.fade_tiles = 9.0
	m.top_band = load(ENV_SANCT + "terrain/sanct_top.png")
	m.top_line = 15
	m.top_lit = 36
	m.under_band = load(ENV_SANCT + "terrain/sanct_under.png")
	m.under_line = 16
	m.wall_band = load(ENV_SANCT + "terrain/sanct_wall.png")
	m.wall_face = 34
	m.lip_color = Color(0, 0, 0, 0)
	m.outline_color = Color(0, 0, 0, 0)
	ResourceSaver.save(m, "res://scenes/world/terrain_sanctuary.tres")
	return load("res://scenes/world/terrain_sanctuary.tres")


## A piece of the day kit by its atlas name: {"tex": path, "rect": Rect2, and
## the atlas's own fields (walking_y, baseline_y, junction ...) in sheet px}.
func _day(name: String) -> Dictionary:
	if _day_atlas.is_empty():
		var j = JSON.parse_string(FileAccess.get_file_as_string(ENV_DAY + "day_atlas.json"))
		for sh in j["sheets"]:
			for p in sh["pieces"]:
				var r: Array = p["rect_native"]
				var d: Dictionary = p.duplicate()
				d["tex"] = ENV_DAY + sh["name"] + ".png"
				d["rect"] = Rect2(r[0], r[1], r[2], r[3])
				_day_atlas[p["name"]] = d
	return _day_atlas[name]


## A pot or barrel from the day kit (D15) that breaks and drops Resin once.
func _day_breakable(name: String, x: float, floor_y: float, chips: Color) -> Node2D:
	var d := _day(name)
	return _breakable(d["tex"], d["rect"], x, floor_y, chips)


## A day kit piece with its top-left at `pos`.
func _day_sprite(parent: Node, name: String, pos: Vector2, flip := false) -> Sprite2D:
	var d := _day(name)
	var s := _sprite(parent, d["tex"], d["rect"], pos.round())
	s.name = name.capitalize().replace(" ", "")
	s.flip_h = flip
	return s


## A day kit piece standing on `floor_y` (its atlas baseline, else its
## bottom), centred on `x`.
func _day_ground(parent: Node, name: String, x: float, floor_y: float, flip := false) -> Sprite2D:
	var d := _day(name)
	var r: Rect2 = d["rect"]
	var foot: float = (float(d["baseline_y"]) - r.position.y) if d.has("baseline_y") else r.size.y
	return _day_sprite(parent, name, Vector2(x - r.size.x * 0.5, floor_y - foot), flip)


## The ground by day (Book 4's D1 to D3): the earth bands with grey stone set
## in them, the stone-faced wall, the four corners (their junctions at 32, 32),
## and the earth all the way in (never black).
func _day_material() -> Resource:
	var m: Resource = load("res://scripts/world/terrain_material.gd").new()
	m.fill = load(DAY_T + "day_fill.png")
	m.fade_tiles = DAY_FADE
	m.top_band = load(DAY_T + "day_top.png")
	m.top_line = 8        # walking_y 16 in the sheet, the band cut from y 8
	m.top_lit = 40
	m.under_band = load(DAY_T + "day_under.png")
	m.under_line = 24     # every column is solid earth down to here
	m.wall_band = load(DAY_T + "day_wall.png")
	m.wall_face = 40
	m.corner_top = load(DAY_T + "day_corner_top.png")
	m.corner_top_anchor = Vector2(32, 32)
	m.corner_under = load(DAY_T + "day_corner_under.png")
	m.corner_under_anchor = Vector2(32, 32)
	m.inner_top = load(DAY_T + "day_inner_top.png")
	m.inner_top_anchor = Vector2(32, 32)
	m.inner_under = load(DAY_T + "day_inner_under.png")
	m.inner_under_anchor = Vector2(32, 32)
	m.lip_color = Color(0, 0, 0, 0)
	m.outline_color = Color(0, 0, 0, 0)
	ResourceSaver.save(m, "res://scenes/world/terrain_day.tres")
	return load("res://scenes/world/terrain_day.tres")


## The backdrops by day (Book 4's D16 to D18): the sky, the far forest and the
## mid forest, each the height of the view, placed so they fill it when Kleo
## stands on `main_floor` (a layer's child at y shows at y - scroll.y x the
## view's top), each with its bottom colour run on below it. The fog banks and
## the dusk aqueduct go.
func _day_backdrops() -> void:
	var top := (main_floor - 58.0 - 180.0) if main_floor >= 0.0 else 0.0
	var layers := [["Sky", ENV_DAY + "17-daytime-sky.png"], ["Far", ENV_DAY + "18-far-forest.png"], ["Mid", ENV_DAY + "19-mid-forest.png"]]
	if kit == "sanctuary":
		# Book 5's F15 (the cavern's light), F13 (far ruins), F14 (nearer ruins).
		layers = [["Sky", ENV_SANCT + "F15-cavern-light.png"], ["Far", ENV_SANCT + "F13-far-ruins.png"], ["Mid", ENV_SANCT + "F14-mid-ruins.png"]]
	for layer in layers:
		var p := _root.get_node(layer[0]) as Parallax2D
		var art := p.get_node("Art") as Sprite2D
		var tex: Texture2D = load(layer[1])
		art.texture = tex
		art.modulate = Color.WHITE
		art.position.y = roundf(p.scroll_scale.y * top)
		p.repeat_size = Vector2(tex.get_width(), 0)
		var base := p.get_node_or_null("Base") as ColorRect
		if base:
			base.position = Vector2(0, art.position.y + tex.get_height() - 1)
			base.size = Vector2(tex.get_width(), 420)
			base.color = tex.get_image().get_pixel(4, tex.get_height() - 1)
	for n in ["FogFar", "FogMid"]:
		var f := _root.get_node_or_null(n)
		if f:
			_root.remove_child(f)
			f.free()


func _daylight() -> void:
	vignette = false
	var mod := _node(CanvasModulate.new(), "Daylight", _root) as CanvasModulate
	mod.color = Color(1.0, 1.0, 1.0)
	for skin_name in ["TerrainSkin", "FakeSkin"]:
		for sk in _root.find_children(skin_name + "*", "", true, false):
			if "void_color" in sk:
				sk.set("void_color", SANCT_STONE_DEEP if kit == "sanctuary" else DAY_EARTH_DEEP)
	var w := float(room.size.x * TILE)
	var h := float(room.size.y * TILE)
	# Sun falling through the canopy, warm and faint.
	var x := 300.0
	while x < w:
		var shaft := _node(Polygon2D.new(), "SunShaft", _root) as Polygon2D
		shaft.z_index = 3
		var sw := 60.0 + fmod(x, 37.0)
		shaft.polygon = PackedVector2Array([Vector2(x, 0), Vector2(x + sw, 0), Vector2(x + sw + 170, h - 60), Vector2(x + 170, h - 60)])
		var sun := Color(1.0, 0.95, 0.72)
		shaft.vertex_colors = PackedColorArray([Color(sun, 0.09), Color(sun, 0.09), Color(sun, 0.0), Color(sun, 0.0)])
		shaft.material = _add_mat
		x += 520.0
	var leaves := _particles("Leaves", load("res://assets/fx/leaf.png"), 18, 12.0, Rect2(0, 0, w, 60))
	leaves.gravity = Vector2(5, 16)
	leaves.initial_velocity_min = 4.0
	leaves.initial_velocity_max = 12.0
	leaves.angular_velocity_min = -90.0
	leaves.angular_velocity_max = 90.0
	leaves.z_index = 14
	# Pollen drifting in the light (the night's fireflies, by day).
	var motes := _particles("Pollen", load("res://assets/fx/mote.png"), 26, 9.0, Rect2(0, h * 0.25, w, h * 0.6))
	motes.color = Color(1.0, 0.98, 0.85, 0.7)
	motes.gravity = Vector2(1, -1)
	motes.initial_velocity_min = 2.0
	motes.initial_velocity_max = 6.0
	motes.spread = 180.0
	motes.scale_amount_min = 0.5
	motes.scale_amount_max = 0.8
	motes.z_index = 14
	for l in _root.find_children("*", "PointLight2D", true, false):
		(l as PointLight2D).energy *= DAY_LAMP
	# Sky light along the tops of everything that hurts: the creatures and
	# the thorns stand off the stone (they were lost in it).
	for n in _root.find_children("*", "", true, false):
		if n is CanvasItem and (n as CanvasItem).material is ShaderMaterial:
			var sm := (n as CanvasItem).material as ShaderMaterial
			if sm.shader and sm.shader.resource_path.ends_with("hit_flash.gdshader"):
				sm.set_shader_parameter("rim", DAY_RIM)
				sm.set_shader_parameter("rim_side", DAY_RIM_SIDE)


## The ruin stone (Book 3's W1 and W2, cut by tools/make_wilds.py): bands
## that fade into the dark at every edge, and blocks inside each mass that
## stay faintly visible as they darken, as in the mockups (RUIN_FADE tiles).
const RUIN := "res://assets/environment/wilds/terrain/"
const RUIN_FADE := 6.0

func _ruin_material() -> Resource:
	var m: Resource = load("res://scripts/world/terrain_material.gd").new()
	m.fill = load(RUIN + "ruin_fill.png")
	m.fade_tiles = RUIN_FADE
	m.top_band = load(RUIN + "ruin_top.png")
	m.top_line = 15
	m.top_lit = 64
	m.under_band = load(RUIN + "ruin_under.png")
	m.under_line = 25
	m.wall_band = load(RUIN + "ruin_wall.png")
	m.wall_face = 31
	m.corner_top = load(RUIN + "ruin_corner_top.png")
	m.corner_top_anchor = Vector2(67, 14)
	m.corner_under = load(RUIN + "ruin_corner_under.png")
	m.corner_under_anchor = Vector2(77, 77)
	m.inner_top = load(RUIN + "ruin_inner_top.png")
	m.inner_top_anchor = Vector2(22, 67)
	m.inner_under = load(RUIN + "ruin_inner_under.png")
	m.inner_under_anchor = Vector2(27, 29)
	m.lip_color = Color(0, 0, 0, 0)
	m.outline_color = Color(0, 0, 0, 0)
	ResourceSaver.save(m, "res://scenes/world/terrain_ruin.tres")
	return load("res://scenes/world/terrain_ruin.tres")


## The levels' foreground (the creative lead's): along the bottom of the view,
## the teal fern band and, nearest, the plum stone band with its fern
## silhouettes, in their own colours, placed in the world and sliding a little
## faster than the level; kept under every floor, never hiding where Kleo walks.
## `main_floor` (px) is the walking line Kleo spends the level on: the bands'
## feet sit on the screen's bottom edge when she stands there.
var main_floor := -1.0

func _level_foreground() -> void:
	_detail_kind = "surface"
	var view_bottom := -1.0
	if main_floor >= 0.0:
		# The camera holds her feet 58 px below the view's centre
		# (camera_rig.gd's vertical_offset); the view is 360 tall.
		view_bottom = main_floor - 58.0 + 180.0
	if daylight:
		# Book 4's D19: one leafy band.
		if kit == "sanctuary":
			_fg_bands("sanct", Color(0, 0, 0, 0), ENV_SANCT, true, 0.0, "ForegroundLeaves", view_bottom, main_floor)
			return
		_fg_bands("day", Color(0, 0, 0, 0), ENV_DAY, true, 0.0, "ForegroundLeaves", view_bottom, main_floor)
		return
	_fg_bands("ferns", Color(0, 0, 0, 0), ENV_WILDS, true, 0.0, "ForegroundFerns", view_bottom, main_floor)
	_fg_bands("stones", Color(0, 0, 0, 0), ENV_WILDS, true, 180.0, "ForegroundStones", view_bottom, main_floor)


## A flat sky, light at the bottom: the black box reads against it.
func _blockout_sky() -> void:
	var sky := _node(CanvasLayer.new(), "BlockoutSky", _root) as CanvasLayer
	sky.layer = -10
	var rect := _node(ColorRect.new(), "Sky", sky) as ColorRect
	rect.size = Vector2(640, 360)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var g := Gradient.new()
	# Flat, so whole-level pictures stitched from screens show no seams.
	g.set_color(0, BLOCK_SKY_BOTTOM)
	g.set_color(1, BLOCK_SKY_BOTTOM)
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	var tr := _node(TextureRect.new(), "Gradient", sky) as TextureRect
	tr.texture = gt
	tr.size = Vector2(640, 360)
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE


## A name for a beat of the level, in the world (blockout only).
func _label(text: String, pos: Vector2) -> void:
	if not blockout:
		return
	var l := _node(Label.new(), "Label", _blockout_node) as Label
	l.text = text
	l.position = pos.round()
	l.add_theme_font_size_override("font_size", 8)
	l.add_theme_color_override("font_color", LABEL_INK)
	l.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.07))
	l.add_theme_constant_override("outline_size", 3)


## Backdrop shapes in the blockout: what a piece of the level IS (a tree that
## holds the branches, a stall's roof), muted and behind the playfield, with no
## collision. They make the plan read as a place.
const BACKDROP_INK := Color("#6d7b9c")
const BACKDROP_LEAF := Color("#75879f")


func _backdrop(poly: PackedVector2Array, color := BACKDROP_INK) -> Polygon2D:
	if not blockout:
		return null
	var b := _root.get_node_or_null("BlockoutBackdrop") as Node2D
	if b == null:
		b = _node(Node2D.new(), "BlockoutBackdrop", _root) as Node2D
		b.z_index = -3
	return _shape(b, poly, color, "Shape")


## A tree in the blockout backdrop: a trunk from `foot_y` up to `top_y`
## centred on `x`, `w` wide, and a crown `crown` px across round its top.
func _backdrop_tree(x: float, foot_y: float, top_y: float, w: float, crown: float) -> void:
	_backdrop(PackedVector2Array([Vector2(x - w * 0.5 - 4, foot_y), Vector2(x - w * 0.5, top_y + 20),
		Vector2(x + w * 0.5, top_y + 20), Vector2(x + w * 0.5 + 4, foot_y)]))
	var pts := PackedVector2Array()
	for k in 18:
		var a := TAU * k / 18.0
		var r := 1.0 + 0.12 * sin(a * 3.0)
		pts.append(Vector2(x + cos(a) * crown * 0.5 * r, top_y + 10 + sin(a) * crown * 0.28 * r))
	_backdrop(pts, BACKDROP_LEAF)


## A false wall; in a blockout its cover is plain black rock like the rest
## (its painted copy would give the secret away).
func _false_wall(node_name: String, hide: Rect2i, face_x: int, rows: Vector2i, faces: int, flag: String) -> Node2D:
	var cover := super(node_name, hide, face_x, rows, faces, flag)
	# The hidden cells in the wall's own material (the cell above the hollow),
	# so the cover's face runs on in the same earth or stone.
	var fake := cover.get_node("FakeRock") as TileMapLayer
	var src := _root.get_node("Solid") as TileMapLayer
	var mat := src.get_cell_atlas_coords(Vector2i(hide.position.x, hide.position.y - 1))
	if mat != Vector2i(-1, -1):
		for x in range(hide.position.x, hide.end.x):
			for y in range(hide.position.y, hide.end.y):
				fake.set_cell(Vector2i(x, y), 0, mat)
	if blockout:
		fake.visible = true
		cover.get_node("Clip/FakeSkin").set("skin_visible", false)
	if water_line > 0.0:
		# The cover stops at the water: it never paints over it.
		var clip := cover.get_node("Clip") as Polygon2D
		var poly := clip.polygon
		for i in poly.size():
			poly[i].y = minf(poly[i].y, water_line)
		clip.polygon = poly
	return cover


## A flat shape in the blockout (a log, a leaf, a thorn bed).
func _shape(parent: Node, poly: PackedVector2Array, color: Color, shape_name: String) -> Polygon2D:
	var p := _node(Polygon2D.new(), shape_name, parent) as Polygon2D
	p.polygon = poly
	p.color = color
	return p


func _box(r: Rect2) -> PackedVector2Array:
	return PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])


func _rect_shape(size: Vector2, at: Vector2) -> CollisionShape2D:
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = size
	cs.shape = r
	cs.position = at
	return cs


# --- Checkpoints, hazards, the level's end ---------------------------------------------------

## The midway checkpoint: a Guard's banner on a pole standing on `floor_y` at
## `x` (its left edge), furled until she passes. One a level, at its middle.
func _checkpoint(x: float, floor_y: float, flag: String) -> Node2D:
	var c := _node(Node2D.new(), "Checkpoint", _root) as Node2D
	c.set_script(load("res://scripts/world/checkpoint.gd"))
	c.position = Vector2(x, floor_y).round()
	c.z_index = 3
	c.set("flag", flag)
	c.set("light_energy", 0.5)
	for part in [["Dark", 0], ["Lit", 1]]:
		var s := _node(Sprite2D.new(), part[0], c) as Sprite2D
		s.texture = load("res://assets/items/banner.png")
		s.hframes = 3
		s.frame = part[1]
		s.centered = false
		s.position = Vector2(0, -63)
		s.visible = part[1] == 0
	var l := _light(c, Vector2(7, -58), LAMP, 0.8, 0.8, "Light")
	l.energy = 0.0
	var trig := _node(Area2D.new(), "Trigger", c) as Area2D
	_node(_rect_shape(Vector2(28, 48), Vector2(14, -24)), "Shape", trig)
	return c


## A bed of thorns over [x0, x1] standing on `floor_y` (a hazard).
func _thorns(x0: float, x1: float, floor_y: float, height := 16.0) -> Area2D:
	var a := _node(Area2D.new(), "Thorns", _root) as Area2D
	a.set_script(load("res://scripts/world/hazard_area.gd"))
	a.position = Vector2(x0, floor_y)
	_node(_rect_shape(Vector2(x1 - x0 - 4, height - 2), Vector2((x1 - x0) * 0.5, -height * 0.5 + 1)), "Shape", a)
	# Brambles: dull plum and bark, thorny (never red: red is the Blight's).
	var poly := PackedVector2Array([Vector2(0, 0)])
	var x := 0.0
	var i := 0
	while x < x1 - x0:
		poly.append(Vector2(x + 3, -height + (i % 3) * 3))
		poly.append(Vector2(x + 6, -height * 0.45))
		x += 6.0
		i += 1
	poly.append(Vector2(x1 - x0, 0))
	if blockout:
		var art := _shape(a, poly, Color("#4a3448"), "Art")
		art.z_index = 1
	elif daylight:
		# Book 4's D14 across the whole bed: the thicket repeated to the bed's
		# width, an end at each side, in front of the plants.
		var bw := x1 - x0
		var rep: Dictionary = _day("bramble-repeat")
		var rr: Rect2 = rep["rect"]
		var parts: Array[Sprite2D] = []
		var bx := 0.0
		while bx < bw:
			var seg := minf(rr.size.x, bw - bx)
			parts.append(_sprite(a, rep["tex"], Rect2(rr.position, Vector2(seg, rr.size.y)), Vector2(bx, -rr.size.y + 2)))
			bx += seg
		parts.append(_day_sprite(a, "bramble-left-cap", Vector2(-14, -22)))
		parts.append(_day_sprite(a, "bramble-right-cap", Vector2(bw - 10, -22)))
		for b in parts:
			b.name = "Bramble"
			var m := ShaderMaterial.new()
			m.shader = load("res://shaders/hit_flash.gdshader")
			b.material = m
			b.z_index = 8
	else:
		# Book 3's T3 across the whole bed: its thicket (cut to the bed's
		# width) between its two ends, so every pixel that hurts shows thorns.
		# (It drew only the two small ends at the bed's middle: the creative
		# lead "couldn't see the spikes".)
		var bw := x1 - x0
		var mid_w := minf(185.0, maxf(bw, 12.0))
		var mid := _sprite(a, ENV_WILDS + "brambles.png", Rect2(34 + roundf((185.0 - mid_w) * 0.5), 29, mid_w, 28),
			Vector2(roundf((bw - mid_w) * 0.5), -26.0))
		mid.name = "Bramble"
		var left := _sprite(a, ENV_WILDS + "brambles.png", Rect2(4, 40, 26, 17), Vector2(-10.0, -15.0))
		left.name = "Bramble"
		var right := _sprite(a, ENV_WILDS + "brambles.png", Rect2(224, 40, 28, 17), Vector2(bw - 18.0, -15.0))
		right.name = "Bramble"
		for b in [left, mid, right]:
			var m := ShaderMaterial.new()
			m.shader = load("res://shaders/hit_flash.gdshader")
			b.material = m
			# In front of the grass and flowers (they hid the thorns), behind Kleo.
			b.z_index = 8
	return a


## The level's end: a doorway `w` x `h` px whose floor is `floor_y`, left edge `x`.
func _level_end(x: float, floor_y: float, w: float, h: float, next_scene := "") -> Area2D:
	var e := _node(Area2D.new(), "LevelEnd", _root) as Area2D
	e.set_script(load("res://scripts/world/level_end.gd"))
	e.set("next_scene", next_scene)
	e.position = Vector2(x, floor_y)
	_node(_rect_shape(Vector2(w * 0.5, h), Vector2(w * 0.5, -h * 0.5)), "Shape", e)
	if blockout:
		# An arch outline, glowing amber inside: the way out.
		var arch := PackedVector2Array()
		for k in 13:
			var a := PI + PI * k / 12.0
			arch.append(Vector2(w * 0.5 + cos(a) * w * 0.5, -h + w * 0.5 + sin(a) * w * 0.5))
		var inner := PackedVector2Array([Vector2(0, 0)])
		inner.append_array(arch)
		inner.append(Vector2(w, 0))
		_shape(_blockout_node, _offset(inner, e.position), Color(0.95, 0.69, 0.29, 0.55), "EndArch")
		_label("LEVEL END", e.position + Vector2(-6, -h - 14))
	elif daylight:
		# Book 4's arched doorway (D4): its 32-wide opening on the way out,
		# its floor (row 79 of 80) on the walking line.
		var door := _day_sprite(_root.get_node("Behind"), "arched-doorway", Vector2(x + w * 0.25 - 32.0, floor_y - 80.0))
		door.name = "EndDoor"
		door.z_index = 1
	else:
		# The arched doorway with its lantern (the mockup's way out).
		var behind := _root.get_node("Behind")
		var d := _piece(behind, DOOR_LANTERN, x - 34.0, floor_y, "EndDoor")
		d.z_index = 1
		_light(behind, Vector2(x - 34.0 + 99.0, floor_y - DOOR_LANTERN.size.y + 44.0), LAMP, 1.0, 1.0, "EndDoorLight")
	return e


func _offset(poly: PackedVector2Array, by: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(p + by)
	return out


# --- Creatures -------------------------------------------------------------------------------------

## A creature that fights by lunging (`lunger.gd`) on a flat floor, kept to
## [left_x, right_x] (world px). `sprite`: one of the creative lead's roster
## (game/assets/characters/roster/, a single pose until its sheet exists).
const ROSTER := "res://assets/characters/roster/"

func _lunger(x: float, floor_y: float, left_x: float, right_x: float, sprite := "rat") -> Node2D:
	var tex: Texture2D = load(ROSTER + sprite + ".png")
	var w := float(tex.get_width())
	var h := float(tex.get_height())
	var e := _node(CharacterBody2D.new(), "Lunger_" + sprite, _root) as CharacterBody2D
	e.set_script(load("res://scripts/world/lunger.gd"))
	e.position = Vector2(x, floor_y)
	e.z_index = 7
	e.set("left_x", left_x)
	e.set("right_x", right_x)
	_node(_rect_shape(Vector2(20, 14), Vector2(0, -7)), "Shape", e)
	var art := _node(Sprite2D.new(), "Art", e) as Sprite2D
	art.texture = tex
	# Centred on its feet, so a squash or lean pivots where it stands.
	art.centered = true
	art.offset = Vector2(0, -roundf(h * 0.5) + 1.0)
	var flash := ShaderMaterial.new()
	flash.shader = load("res://shaders/hit_flash.gdshader")
	art.material = flash
	var hb := _node(Area2D.new(), "Hurtbox", e) as Area2D
	hb.collision_layer = 4
	hb.collision_mask = 0
	hb.monitoring = false
	_node(_rect_shape(Vector2(w - 8.0, h - 6.0), Vector2(0, -h * 0.5)), "Shape", hb)
	var touch := _node(Area2D.new(), "Touch", e) as Area2D
	touch.collision_layer = 0
	touch.collision_mask = 2
	touch.monitorable = false
	_node(_rect_shape(Vector2(w * 0.55, h * 0.5), Vector2(4, -h * 0.4)), "Shape", touch)
	return e


# --- Things to find, carry and break ---------------------------------------------------------------

## A chest standing on `floor_y`, centred on `x`; it spills `resin` beads.
func _chest(x: float, floor_y: float, resin: int, flag: String) -> Node2D:
	var c := _node(Node2D.new(), "Chest", _root) as Node2D
	c.set_script(load("res://scripts/world/chest.gd"))
	c.position = Vector2(x, floor_y).round()
	c.z_index = 6
	c.set("resin", resin)
	c.set("flag", flag)
	var art := _node(Sprite2D.new(), "Art", c) as Sprite2D
	art.texture = load("res://assets/items/chest.png")
	art.hframes = 3  # shut, opening, open (Book 3's T1)
	art.centered = false
	art.position = Vector2(-20, -39)
	var hb := _node(Area2D.new(), "Hurtbox", c) as Area2D
	hb.collision_layer = 4
	hb.collision_mask = 0
	hb.monitoring = false
	_node(_rect_shape(Vector2(26, 18), Vector2(0, -9)), "Shape", hb)
	return c


## A crate (or barrel) to carry and throw, standing on `floor_y`, centred on `x`.
func _crate(x: float, floor_y: float, region := CRATE_B) -> CharacterBody2D:
	var c := _node(CharacterBody2D.new(), "Crate", _root) as CharacterBody2D
	c.set_script(load("res://scripts/world/carriable.gd"))
	c.position = Vector2(x, floor_y).round()
	c.z_index = 11
	var sheet := CRATES
	if daylight and not blockout:
		# Book 4's crate (D15): the size of the box in Kleo's carry frames.
		sheet = _day("wooden-crate")["tex"]
		region = _day("wooden-crate")["rect"]
	_node(_rect_shape(Vector2(region.size.x - 6, 6), Vector2(0, -3)), "Shape", c)
	var art := _sprite(c, sheet, region, Vector2(-roundf(region.size.x * 0.5), -region.size.y + 1))
	art.name = "Art"
	var handle := _node(Area2D.new(), "Handle", c) as Area2D
	handle.set_script(load("res://scripts/world/carry_handle.gd"))
	handle.set("prompt_offset", Vector2(0, -region.size.y - 8))
	_node(_rect_shape(Vector2(region.size.x + 6, region.size.y), Vector2(0, -region.size.y * 0.5)), "Shape", handle)
	var hit := _node(Area2D.new(), "Hit", c) as Area2D
	_node(_rect_shape(region.size, Vector2(0, -region.size.y * 0.5)), "Shape", hit)
	return c


## A stack of `count` crates standing on `floor_y`, centred on `x`: solid
## boxes left where people stacked them (Donkey Kong Country's way of raising
## the ground), climbed like steps. They can't be carried (see `_crate`).
func _box_stack(x: float, floor_y: float, count: int, region := CRATE_A) -> StaticBody2D:
	var b := _node(StaticBody2D.new(), "BoxStack", _root) as StaticBody2D
	b.position = Vector2(x, floor_y).round()
	b.z_index = 6
	b.collision_layer = 1
	b.collision_mask = 0
	var h := 32.0  # two tiles a box, so a stack's top lies on the tile grid
	for k in count:
		var art := _sprite(b, CRATES, region, Vector2(-roundf(region.size.x * 0.5), -h * (k + 1) - 1.0))
		art.name = "Box"
		art.flip_h = k % 2 == 1
	_node(_rect_shape(Vector2(32, h * count), Vector2(0, -h * count * 0.5)), "Shape", b)
	return b


## A cracked wall over the tiles `r` (x, y, w, h): solid until a thrown crate
## breaks it.
func _cracked_wall(r: Rect2i, flag: String) -> StaticBody2D:
	var w := _node(StaticBody2D.new(), "CrackedWall", _root) as StaticBody2D
	w.set_script(load("res://scripts/world/cracked_wall.gd"))
	w.set("flag", flag)
	w.position = Vector2(r.position * TILE)
	w.z_index = 6
	var size := Vector2(r.size * TILE)
	w.set_meta("rect", Rect2(Vector2.ZERO, size))
	_node(_rect_shape(size, size * 0.5), "Shape", w)
	var art := _node(Node2D.new(), "Art", w) as Node2D
	if blockout:
		# Pale cracked stone, so the mark reads against the black box.
		_shape(art, _box(Rect2(Vector2.ZERO, size)), Color("#6e6482"), "Stone")
	else:
		# Book 3's T2: the cracked stone, centred on the wall, standing on its
		# floor; it breaks into the sheet's rubble.
		var cw := _sprite(art, ENV_WILDS + "cracked_wall.png", Rect2(11, 20, 45, 46), Vector2(size.x * 0.5 - 22.0, size.y - 46.0))
		cw.name = "Stone"
		w.set_meta("rubble", [Rect2(13, 90, 11, 10), Rect2(40, 87, 18, 14), Rect2(74, 90, 12, 9), Rect2(105, 93, 6, 6),
			Rect2(13, 112, 8, 7), Rect2(40, 112, 13, 8), Rect2(69, 108, 17, 14), Rect2(102, 112, 12, 8)])
		w.set_meta("rubble_tex", ENV_WILDS + "cracked_wall.png")
	if blockout:
		_shape(art, PackedVector2Array([Vector2(size.x * 0.3, 0), Vector2(size.x * 0.55, size.y * 0.45), Vector2(size.x * 0.4, size.y * 0.6),
			Vector2(size.x * 0.7, size.y), Vector2(size.x * 0.62, size.y), Vector2(size.x * 0.33, size.y * 0.62),
			Vector2(size.x * 0.46, size.y * 0.45), Vector2(size.x * 0.22, 0)]), Color("#2a2234"), "Crack")
	var hb := _node(Area2D.new(), "Hurtbox", w) as Area2D
	hb.collision_layer = 4
	hb.collision_mask = 0
	hb.monitoring = false
	_node(_rect_shape(size + Vector2(8, 4), size * 0.5), "Shape", hb)
	return w


## A power-up hanging at `pos` (px): "spark", the Anima Spark.
func _power_up(pos: Vector2, kind := "spark") -> Area2D:
	var a := _node(Area2D.new(), "PowerUp", _root) as Area2D
	a.set_script(load("res://scripts/world/power_up.gd"))
	a.set("kind", kind)
	a.position = pos.round()
	a.z_index = 9
	var art := _node(Sprite2D.new(), "Art", a) as Sprite2D
	art.texture = load("res://assets/items/power_%s.png" % kind)
	art.hframes = 4
	var cs := CollisionShape2D.new()
	var cc := CircleShape2D.new()
	cc.radius = 10.0
	cs.shape = cc
	_node(cs, "Shape", a)
	_label("POWER-UP: " + kind, pos + Vector2(-20, -24))
	return a


## One of the level's four letters, K-L-E-O (as Donkey Kong Country's
## K-O-N-G), hanging at `pos` (px): along the main line and off it.
func _letter(pos: Vector2, letter: String, flag: String) -> Area2D:
	var a := _node(Area2D.new(), "Letter" + letter, _root) as Area2D
	a.set_script(load("res://scripts/world/letter.gd"))
	a.set("letter", letter)
	a.set("flag", flag)
	a.position = pos.round()
	a.z_index = 9
	var art := _node(Sprite2D.new(), "Art", a) as Sprite2D
	art.texture = load("res://assets/items/letters.png")
	art.hframes = 4
	art.frame = maxi("KLEO".find(letter), 0)
	# Generous, as letters are in DKC: brushing past it takes it.
	var cs := CollisionShape2D.new()
	var cc := CircleShape2D.new()
	cc.radius = 12.0
	cs.shape = cc
	_node(cs, "Shape", a)
	return a


## The level's great secret: one of Morvath's thorn knots, asleep, hanging at
## `pos` (px). One a level, hidden with real cunning (ThornKnot).
func _knot(pos: Vector2, flag: String) -> Area2D:
	var a := _node(Area2D.new(), "ThornKnot", _root) as Area2D
	a.set_script(load("res://scripts/world/thorn_knot.gd"))
	a.set("flag", flag)
	a.position = pos.round()
	a.z_index = 9
	var art := _node(Sprite2D.new(), "Art", a) as Sprite2D
	art.texture = load("res://assets/items/knot.png")
	art.hframes = 2
	var cs := CollisionShape2D.new()
	var cc := CircleShape2D.new()
	cc.radius = 9.0
	cs.shape = cc
	_node(cs, "Shape", a)
	_label("THORN KNOT\n(the great secret)", pos + Vector2(-30, -34))
	return a


## The water across the bottom of a level (the creative lead's mockups: still
## water through the lower part of every view, the terraces and islands
## standing in it, sunken stone and plants under its surface). Its surface is
## `surface_y` (px); it runs across [x0, x1) for each span (px), down to the
## level's bottom. Falling in is a hazard, as in any water. In front of the
## terrain's base, behind Kleo.
var water_line := 0.0  # set by _water_foreground: the level's water surface

func _water_foreground(surface_y: float, spans: Array) -> void:
	water_line = surface_y
	var bottom := float(room.end.y * TILE)
	var i := 0
	for sp in spans:
		var wn := _water("Water%d" % i, Vector2(sp[0], surface_y), Vector2(sp[1] - sp[0], bottom - surface_y), Vector2(40 + i * 31, 40))
		wn.z_index = 12
		var surf := wn.get_node("Surface") as ColorRect
		var m := surf.material as ShaderMaterial
		# The mockups' water: the creative lead's painted water (its own
		# ripple and streaks), with the world above reflected lightly in it.
		m.set_shader_parameter("shallow", Color("#1f5266"))
		m.set_shader_parameter("deep", Color("#0f2a3a"))
		m.set_shader_parameter("line_color", Color("#7fc4c8"))
		if not blockout:
			# By day, Book 4's D10 (the pond); at dusk, the creative lead's water.
			var paint: Texture2D = load(ENV_DAY + "11-pond-water.png" if daylight else ENV_WILDS + "water_paint.png")
			if daylight and kit == "sanctuary":
				paint = load(ENV_SANCT + "sanct_water.png")  # Book 5's F8
			m.set_shader_parameter("use_paint", true)
			m.set_shader_parameter("paint", paint)
			m.set_shader_parameter("paint_size", Vector2(paint.get_size()))
			m.set_shader_parameter("reflect_strength", 0.32)
		else:
			m.set_shader_parameter("reflect_strength", 0.55)
		i += 1


## Where the water stops against a mass that stands on the water bed (a
## hill), the mass's face runs on down under the water: the ruin stone's wall
## band, seen through the surface. `faces`: 1 for a face toward the right.
func _face_under_water(face_x: float, faces: int) -> void:
	var bottom := float(room.end.y * TILE)
	var y := water_line - 4.0
	# The wall band (its face column and width): by day Book 4's D2, else W2.
	var tex := DAY_T + "day_wall.png" if daylight else RUIN + "ruin_wall.png"
	var face := 40.0 if daylight else 31.0
	var bw := 44.0 if daylight else 41.0
	var bh := 256.0 if daylight else 252.0
	while y < bottom:
		var h := minf(bh, bottom - y)
		var x := face_x - face if faces > 0 else face_x - (bw - face - 1.0)
		var band := _underwater(tex, Rect2(0, 0, bw, h), Vector2(x, y), faces < 0)
		band.z_index = 13
		y += bh


## Something seen under the water: tinted toward the water and a little
## faded, drawn over it (z 13).
const UNDERWATER_TINT := Color(0.42, 0.62, 0.72, 0.78)

func _underwater(tex_path: String, region: Rect2, pos: Vector2, flip := false) -> Sprite2D:
	var s := _sprite(_root, tex_path, region, pos)
	s.name = "Underwater"
	s.z_index = 13
	s.modulate = UNDERWATER_TINT
	s.flip_h = flip
	return s


## A walkway along the top of a tree's crown: one-way, its leaves (SF9's
## canopy band, whose top is flat) laid with their top on the walking line.
## In a blockout it is a timber log like the rest.
const CANOPY := Rect2(112, 184, 256, 61)

func _canopy(x0: float, x1: float, y: float, leaves := true) -> void:
	if blockout:
		_log(_root, x0, x1, y)
		return
	var b := _body("Canopy", 64)
	var cs := _rect_shape(Vector2(x1 - x0, 8), Vector2((x0 + x1) * 0.5, y + 4.0))
	cs.one_way_collision = true
	_node(cs, "Shape", b)
	if not leaves:
		return  # the level paints it (a treetop, a fallen trunk)
	var placed := _root.get_node("PlacedArt")
	var x := x0 - 8.0
	var flip := false
	while x < x1 + 8.0:
		var w := minf(CANOPY.size.x, x1 + 8.0 - x)
		var leaf := _sprite(placed, GT, Rect2(CANOPY.position, Vector2(w, CANOPY.size.y)), Vector2(x, y - 1.0))
		leaf.name = "CanopyLeaves"
		leaf.set_meta("no_tint", true)  # SF9's greens are the forest's own
		leaf.flip_h = flip
		flip = not flip
		x += w
	# Vines down from the crown, over the trunk's top.
	_vines(placed, x0 + 10.0, x1 - 14.0, y + 40.0)


## A lantern hanging from a ceiling at `ceiling_y` (its chain cut to `drop` px).
func _hanging_lamp(parent: Node, x: float, ceiling_y: float, drop := 41.0) -> void:
	var cut := 60.0 - drop
	var lamp := _sprite(parent, LAN, Rect2(201, 1 + cut, 21, drop), Vector2(x - 10, ceiling_y))
	lamp.name = "HangingLantern"
	_light(parent, Vector2(x, ceiling_y + drop - 12.0), LAMP, 0.9, 0.8, "HangingLanternLight")


## Resin beads along a line of points (px), each remembered by `flag`_i.
func _beads(points: Array, flag: String) -> void:
	for i in points.size():
		_pickup(_root, points[i], 1, "%s_%d" % [flag, i])


## Beads in an arc over a jump, from `a` to `b` (px, both at Kleo's feet),
## rising `rise` px: they show the jump's line.
func _bead_arc(a: Vector2, b: Vector2, rise: float, count: int, flag: String) -> void:
	var pts := []
	for i in count:
		var t := (i + 1.0) / (count + 1.0)
		pts.append(a.lerp(b, t) + Vector2(0, -16.0 - rise * 4.0 * t * (1.0 - t)))
	_beads(pts, flag)


# --- Moving platforms ----------------------------------------------------------------------------

## A moving platform `w` px wide (a timber raft), its top at `top_left`, running
## along `path` (offsets, px). One-way: she jumps up through it.
func _mover(top_left: Vector2, w: float, path: Array, speed := 48.0, pause := 0.6, wait := false, phase := 0.0) -> AnimatableBody2D:
	var b := _node(AnimatableBody2D.new(), "MovingPlatform", _root) as AnimatableBody2D
	b.set_script(load("res://scripts/world/moving_platform.gd"))
	b.position = top_left.round()
	b.z_index = 6
	b.collision_layer = 64
	b.collision_mask = 0
	var typed: Array[Vector2] = []
	for p in path:
		typed.append(p)
	b.set("path", typed)
	b.set("speed", speed)
	b.set("pause", pause)
	b.set("wait_for_rider", wait)
	b.set("phase", phase)
	var cs := _rect_shape(Vector2(w, 8), Vector2(w * 0.5, 4))
	cs.one_way_collision = true
	_node(cs, "Shape", b)
	var x := 0.0
	while x < w:
		var piece := _sprite(b, TIMBER, Rect2(42, 13, minf(96.0, w - x), 16), Vector2(x, -2))
		piece.name = "Timber"
		x += 96.0
	return b


# --- Bonus areas ---------------------------------------------------------------------------------

## A bonus area (BonusZone): another zone of the level, beside it and out of
## its view, over `area` (tiles; the camera holds to it while she is inside).
## "gather": `beads` (px) light up; gather all in `time_limit` s and the token
## appears at `token_pos`. "course": the token waits at `token_pos`, the end
## of a run of jumps. She arrives at `start` (px). Its way in is `_bonus_door`.
func _bonus_zone(kind: String, area: Rect2i, start: Vector2, token_pos: Vector2, flag: String, time_limit: float,
		title: String, bead_points := []) -> Node2D:
	var z := _node(Node2D.new(), "BonusZone", _root) as Node2D
	z.set_script(load("res://scripts/world/bonus_zone.gd"))
	z.set("kind", kind)
	z.set("area", area)
	z.set("time_limit", time_limit)
	z.set("title", title)
	z.z_index = 9
	var st := _node(Marker2D.new(), "Start", z) as Marker2D
	st.position = start.round()
	if not bead_points.is_empty():
		var beads := _node(Node2D.new(), "Beads", z)
		for p in bead_points:
			var a := _node(Area2D.new(), "Bead", beads) as Area2D
			a.position = (p as Vector2).round()
			var cs := CollisionShape2D.new()
			var cc := CircleShape2D.new()
			cc.radius = 9.0
			cs.shape = cc
			_node(cs, "Shape", a)
			var art := _node(Sprite2D.new(), "Art", a) as Sprite2D
			art.texture = load("res://assets/items/resin.png")
			art.hframes = 6
	var t := _node(Area2D.new(), "Token", z) as Area2D
	t.set_script(load("res://scripts/world/bonus_token.gd"))
	t.set("flag", flag)
	t.position = token_pos.round()
	var tart := _node(Sprite2D.new(), "Art", t) as Sprite2D
	tart.texture = load("res://assets/items/token.png")
	tart.hframes = 4
	var ts := CollisionShape2D.new()
	var tc := CircleShape2D.new()
	tc.radius = 9.0
	ts.shape = tc
	_node(ts, "Shape", t)
	_label("BONUS (%s, %d s)" % [kind, int(time_limit)], Vector2(area.position.x * TILE + 24, area.position.y * TILE + 24))
	return z


## The hidden way into a bonus area: a hollow standing on `floor_y` at `x`
## (px), dark inside with a faint Anima glow and motes drifting into it.
## Walking in takes her to `zone`; she comes back out at `return_pos`, which
## must lie outside the hollow.
func _bonus_door(x: float, floor_y: float, zone: Node2D, return_pos: Vector2, facing := 1, hollow_kind := "root-hollow") -> Area2D:
	var d := _node(Area2D.new(), "BonusDoor", _root) as Area2D
	d.set_script(load("res://scripts/world/bonus_door.gd"))
	d.position = Vector2(x, floor_y).round()
	d.z_index = 4
	d.set("facing", facing)
	d.set("zone_path", d.get_path_to(zone))
	_node(_rect_shape(Vector2(14, 26), Vector2(0, -13)), "Shape", d)
	var r := _node(Marker2D.new(), "Return", d) as Marker2D
	r.position = (return_pos - d.position).round()
	# The hollow: an arch of dark, a soft teal glow in it.
	var arch := PackedVector2Array([Vector2(-10, 0)])
	for k in 9:
		var a := PI + PI * k / 8.0
		arch.append(Vector2(cos(a) * 10.0, -22.0 + sin(a) * 10.0).round())
	arch.append(Vector2(10, 0))
	if daylight and not blockout:
		# Book 4's D13: a hollow (in a great tree's roots, or a ruin wall),
		# its opening 20 x 28, its floor on the ground.
		var hollow := _day_sprite(d, hollow_kind, Vector2(-24, -48))
		hollow.name = "Hollow"
	else:
		_shape(d, arch, Color("#120c1c") if not blockout else Color("#1d4a52"), "Hollow")
	var glow := _node(ColorRect.new(), "Glow", d) as ColorRect
	glow.size = Vector2(56, 56)
	glow.position = Vector2(-28, -44)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var m := ShaderMaterial.new()
	m.shader = load("res://shaders/glow.gdshader")
	m.set_shader_parameter("tint", Color(0.25, 0.88, 0.78, 0.42))
	m.set_shader_parameter("falloff", 1.8)
	glow.material = m
	var motes := _particles("BonusMotes", load("res://assets/fx/mote.png"), 10, 2.2, Rect2(x - 22, floor_y - 34, 44, 30))
	motes.color = Color(0.45, 0.95, 0.85, 0.85)
	motes.gravity = Vector2(0, -4)
	motes.initial_velocity_min = 2.0
	motes.initial_velocity_max = 6.0
	motes.spread = 180.0
	motes.material = _add_mat
	motes.z_index = 5
	_label("BONUS ENTRANCE", Vector2(x - 30, floor_y - 44))
	return d
