shader_type canvas_item;
// A pure white flash when something is struck: mixes the sprite toward white
// without changing its shape or alpha. By day, a rim of sky light along the
// sprite's top edges (and a little down its sides), so creatures and hazards
// stand off the stone behind them (the creative lead could not see them).

uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform vec4 rim_color : source_color = vec4(0.93, 0.98, 1.0, 1.0);
uniform float rim : hint_range(0.0, 1.0) = 0.0;
uniform float rim_side : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (rim > 0.0 && c.a > 0.5) {
		vec2 px = TEXTURE_PIXEL_SIZE;
		float up = texture(TEXTURE, UV - vec2(0.0, px.y)).a < 0.5 ? 1.0 : 0.0;
		float side = max(texture(TEXTURE, UV - vec2(px.x, 0.0)).a, texture(TEXTURE, UV + vec2(px.x, 0.0)).a) < 0.5 ? 1.0 : 0.0;
		float near_side = min(texture(TEXTURE, UV - vec2(px.x, 0.0)).a, texture(TEXTURE, UV + vec2(px.x, 0.0)).a) < 0.5 ? 1.0 : 0.0;
		c.rgb = mix(c.rgb, rim_color.rgb, max(up * rim, max(side, near_side) * rim_side));
	}
	COLOR = vec4(mix(c.rgb, vec3(1.0), flash), c.a * COLOR.a);
}
