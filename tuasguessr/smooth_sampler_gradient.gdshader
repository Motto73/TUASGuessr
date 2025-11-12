shader_type spatial;

uniform sampler2D Palette : filter_nearest, source_color;

void fragment() {
	vec3 up = texture(Palette, vec2(UV.x, 1.0)).rgb;
	vec3 down = texture(Palette, vec2(UV.x, 0.0)).rgb;
	ALBEDO = mix(up, down, UV.y);
}
