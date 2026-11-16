extends "res://tools/surface_builder.gd"
## Shared tools for the platformer's levels, on top of surface_builder.gd: the
## level's systems (checkpoints, hazards, the lunging enemy, chests, crates to
## carry and throw, cracked walls, moving platforms, cocoons, bonus rooms, the
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
const COCOON_SHEET := ENV + "gate_silk_and_cocoon.png"
const ENV_WILDS := "res://assets/environment/wilds/"
const COCOON_SEALED := Rect2(167, 26, 35, 82)
const COCOON_OPEN := Rect2(210, 26, 40, 82)
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
		# The levels' ground is the creative lead's ruin stone (Book 3's W1, W2),
		# not Lost Keep's earth: material 0 for every mass in a level.
		_earth = _ruin_material()
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
	else:
		_build_atmosphere()
		_level_foreground()
		_tint_surface_kit(_root)
		_edge_shades()
	_finish()


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

## A checkpoint lantern post standing on `floor_y` at `x` (its left edge).
func _checkpoint(x: float, floor_y: float, flag: String) -> Node2D:
	var c := _node(Node2D.new(), "Checkpoint", _root) as Node2D
	c.set_script(load("res://scripts/world/checkpoint.gd"))
	c.position = Vector2(x, floor_y).round()
	c.z_index = 3
	c.set("flag", flag)
	var dark := _sprite(c, LANTERN_SHEET, POST_DARK, Vector2(0, -POST_DARK.size.y + 1))
	dark.name = "Dark"
	var lit := _sprite(c, LANTERN_SHEET, POST_LIT, Vector2(0, -POST_LIT.size.y + 1))
	lit.name = "Lit"
	lit.visible = false
	var l := _light(c, Vector2(POST_LAMP.x, -POST_DARK.size.y + 1 + POST_LAMP.y), LAMP, 1.0, 1.0, "Light")
	l.energy = 0.0
	var trig := _node(Area2D.new(), "Trigger", c) as Area2D
	_node(_rect_shape(Vector2(28, 48), Vector2(POST_LAMP.x, -24)), "Shape", trig)
	return c


## A bed of thorns over [x0, x1] standing on `floor_y` (a hazard).
func _thorns(x0: float, x1: float, floor_y: float, height := 12.0) -> Area2D:
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
	else:
		# Book 3's T3: the bramble bed's two ends, side by side.
		var left := _sprite(a, ENV_WILDS + "brambles.png", Rect2(4, 40, 26, 17), Vector2((x1 - x0) * 0.5 - 26.0, -16.0))
		left.name = "Bramble"
		var right := _sprite(a, ENV_WILDS + "brambles.png", Rect2(224, 40, 28, 17), Vector2((x1 - x0) * 0.5, -16.0))
		right.name = "Bramble"
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
	_node(_rect_shape(Vector2(region.size.x - 6, 6), Vector2(0, -3)), "Shape", c)
	var art := _sprite(c, CRATES, region, Vector2(-roundf(region.size.x * 0.5), -region.size.y + 1))
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


## A cocoon hanging so its foot is at `foot` (px); the one inside is `who`.
## `crop` trims the strand off its top (for a low ceiling).
func _cocoon(foot: Vector2, flag: String, who: String, crop := 0.0, parent: Node = null) -> Node2D:
	if parent == null:
		parent = _root
	var c := _node(Node2D.new(), "Cocoon", parent) as Node2D
	c.position = foot.round()
	c.z_index = 6
	var sealed := _sprite(c, COCOON_SHEET, Rect2(COCOON_SEALED.position + Vector2(0, crop), COCOON_SEALED.size - Vector2(0, crop)),
		Vector2(-roundf(COCOON_SEALED.size.x * 0.5), -COCOON_SEALED.size.y + crop))
	sealed.name = "Sealed"
	var open := _sprite(c, COCOON_SHEET, Rect2(COCOON_OPEN.position + Vector2(0, crop), COCOON_OPEN.size - Vector2(0, crop)),
		Vector2(-roundf(COCOON_OPEN.size.x * 0.5), -COCOON_OPEN.size.y + crop))
	open.name = "Open"
	open.visible = false
	var use := _node(Area2D.new(), "Use", c) as Area2D
	use.set_script(load("res://scripts/world/cocoon.gd"))
	use.set("flag", flag)
	use.set("who", who)
	use.set("prompt_offset", Vector2(0, -60 + crop * 0.5))
	_node(_rect_shape(Vector2(30, 40), Vector2(0, -20)), "Shape", use)
	return c


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
			var paint: Texture2D = load(ENV_WILDS + "water_paint.png")
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
	while y < bottom:
		var h := minf(252.0, bottom - y)
		var x := face_x - 31.0 if faces > 0 else face_x - 10.0
		var band := _underwater(RUIN + "ruin_wall.png", Rect2(0, 0, 41, h), Vector2(x, y), faces < 0)
		band.z_index = 13
		y += 252.0


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


# --- The bonus room --------------------------------------------------------------------------------

## A bonus room over `zone` (px): `beads` (px) light up when Kleo enters; the
## prize is a cocoon (hanging with its foot at `prize_foot`) and some Resin.
func _bonus_room(zone: Rect2, bead_points: Array, prize_foot: Vector2, flag: String, cocoon_flag: String, who: String,
		time_limit := 10.0, crop := 0.0) -> Node2D:
	var b := _node(Node2D.new(), "BonusRoom", _root) as Node2D
	b.set_script(load("res://scripts/world/bonus_room.gd"))
	b.set("flag", flag)
	b.set("time_limit", time_limit)
	b.z_index = 15
	var z := _node(Area2D.new(), "Zone", b) as Area2D
	_node(_rect_shape(zone.size, zone.get_center()), "Shape", z)
	var beads := _node(Node2D.new(), "Beads", b)
	for p in bead_points:
		var a := _node(Area2D.new(), "Bead", beads) as Area2D
		a.position = (p as Vector2).round()
		var cs := CollisionShape2D.new()
		var cc := CircleShape2D.new()
		cc.radius = 7.0
		cs.shape = cc
		_node(cs, "Shape", a)
		var art := _node(Sprite2D.new(), "Art", a) as Sprite2D
		art.texture = load("res://assets/items/resin.png")
		art.hframes = 6
		art.material = _unlit
	var reward := _node(Node2D.new(), "Reward", b) as Node2D
	reward.position = prize_foot.round()
	var c := _cocoon(Vector2.ZERO, cocoon_flag, who, crop, reward)
	c.position = Vector2.ZERO
	return b
