shader_type canvas_item;
// Dark moat water: a bright, broken surface line, a wavering reflection of the
// world above that fades with depth, and slow bands of light below.
render_mode unshaded;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float surface_uv_y = 0.5;
uniform float height_px = 96.0;
uniform vec4 deep : source_color = vec4(0.05, 0.12, 0.17, 1.0);
uniform vec4 shallow : source_color = vec4(0.10, 0.25, 0.31, 1.0);
uniform vec4 line_color : source_color = vec4(0.56, 0.80, 0.78, 1.0);
uniform float reflect_strength = 0.6;
// Painted water (the creative lead's water atlas): when set, the water's colour
// comes from it, repeating sideways in world pixels from `world_x`; its last
// row runs on below it. Its own surface ripple replaces the drawn line.
uniform bool use_paint = false;
uniform sampler2D paint : filter_nearest, repeat_enable;
uniform vec2 paint_size = vec2(966.0, 86.0);
uniform float width_px = 384.0;
uniform float world_x = 0.0;
// Multiplies the painted water (a level by day lifts the dusk paint).
uniform vec4 paint_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

float hash(float n) {
	return fract(sin(n * 12.9898) * 43758.5453);
}

void fragment() {
	float depth = UV.y;            // 0 at the surface, 1 at the bottom
	float y_px = UV.y * height_px;
	// Pixel-art wave: whole-pixel horizontal offsets drifting with time.
	float wave = floor(sin(FRAGCOORD.y * 0.35 + TIME * 2.2) * 1.5 + 0.5);
	vec2 refl = vec2(SCREEN_UV.x + wave * SCREEN_PIXEL_SIZE.x, 2.0 * surface_uv_y - SCREEN_UV.y);
	vec3 mirrored = texture(screen_tex, refl).rgb;
	vec3 water = mix(shallow.rgb, deep.rgb, smoothstep(0.0, 0.8, depth));
	float a = 0.94;
	if (use_paint) {
		float px = floor(world_x + UV.x * width_px);
		float py = min(floor(y_px), paint_size.y - 1.0);
		vec4 p = texture(paint, vec2((mod(px, paint_size.x) + 0.5) / paint_size.x, (py + 0.5) / paint_size.y));
		water = min(p.rgb * paint_tint.rgb, vec3(1.0));
		a = p.a;
	}
	float r = reflect_strength * (1.0 - smoothstep(0.0, 0.7, depth));
	vec3 col = mix(water, mirrored * vec3(0.55, 0.8, 0.85), r);
	// Slow bands of light under the surface.
	float band = step(0.93, sin(UV.x * 40.0 + y_px * 0.6 - TIME * 1.3) * sin(UV.x * 13.0 - TIME * 0.7));
	col += band * 0.05 * (1.0 - depth);
	// The surface line, broken into short runs that shimmer.
	float run = hash(floor(FRAGCOORD.x / 3.0) + floor(TIME * 3.0) * 17.0);
	if (!use_paint) {
		if (y_px < 1.0) {
			col = mix(col, line_color.rgb, run > 0.25 ? 0.85 : 0.2);
		} else if (y_px < 2.0) {
			col = mix(col, line_color.rgb, 0.22);
		}
	}
	COLOR = vec4(col, a);
}
