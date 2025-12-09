shader_type canvas_item;

uniform float vignette_str = 0.2;
uniform float vignette_dist = 0.5;
uniform float lines_size = 20.0;

void fragment() {
	vec2 center = vec2(0.5,0.5);
	float dist = distance(center, UV) * 2.0;
	float vignette = 0.5 + (1.0 - dist + vignette_str) * 0.5;
	float line = mod(UV.y + TIME * 0.1, 1.0 / lines_size) * lines_size;
	COLOR.rgb *= vec3(line) * vignette;
}