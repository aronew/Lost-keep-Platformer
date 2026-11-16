extends "res://tools/surface_builder.gd"
## Shared tools for the platformer's levels, on top of surface_builder.gd: the
## level's systems (checkpoints, hazards, the Thornhound, chests, crates to
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
	_back_walls()
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
		_surface_finish()
	_finish()


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
	if blockout:
		var fake := cover.get_node("FakeRock") as TileMapLayer
		fake.visible = true
		# The hidden cells in the wall's own material (the cell above the hollow).
		var src := _root.get_node("Solid") as TileMapLayer
		var mat := src.get_cell_atlas_coords(Vector2i(hide.position.x, hide.position.y - 1))
		if mat != Vector2i(-1, -1):
			for x in range(hide.position.x, hide.end.x):
				for y in range(hide.position.y, hide.end.y):
					fake.set_cell(Vector2i(x, y), 0, mat)
		cover.get_node("Clip/FakeSkin").set("skin_visible", false)
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
	var art := _shape(a, poly, Color("#4a3448"), "Art")
	art.z_index = 1
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
	return e


func _offset(poly: PackedVector2Array, by: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(p + by)
	return out


# --- Creatures -------------------------------------------------------------------------------------

## A Thornhound on a flat floor, kept to [left_x, right_x] (world px).
func _thornhound(x: float, floor_y: float, left_x: float, right_x: float) -> Node2D:
	var h := _node(CharacterBody2D.new(), "Thornhound", _root) as CharacterBody2D
	h.set_script(load("res://scripts/world/thornhound.gd"))
	h.position = Vector2(x, floor_y)
	h.z_index = 7
	h.set("left_x", left_x)
	h.set("right_x", right_x)
	_node(_rect_shape(Vector2(20, 14), Vector2(0, -7)), "Shape", h)
	var art := _node(Sprite2D.new(), "Art", h) as Sprite2D
	art.texture = load("res://assets/characters/thornhound/thornhound.png")
	art.hframes = 10
	art.centered = false
	art.position = Vector2(-24, -31)
	var flash := ShaderMaterial.new()
	flash.shader = load("res://shaders/hit_flash.gdshader")
	art.material = flash
	var hb := _node(Area2D.new(), "Hurtbox", h) as Area2D
	hb.collision_layer = 4
	hb.collision_mask = 0
	hb.monitoring = false
	_node(_rect_shape(Vector2(30, 18), Vector2(0, -10)), "Shape", hb)
	var touch := _node(Area2D.new(), "Touch", h) as Area2D
	touch.collision_layer = 0
	touch.collision_mask = 2
	touch.monitorable = false
	_node(_rect_shape(Vector2(22, 14), Vector2(4, -9)), "Shape", touch)
	return h


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
	art.hframes = 2
	art.centered = false
	art.position = Vector2(-15, -23)
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
	# Blockout: pale cracked stone, so the mark reads against the black box.
	_shape(art, _box(Rect2(Vector2.ZERO, size)), Color("#6e6482"), "Stone")
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
