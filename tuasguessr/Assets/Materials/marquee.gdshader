shader_type spatial;

uniform sampler2D Text : filter_nearest;
uniform sampler2D gradient;

void fragment() {
	vec2 size = vec2(textureSize(Text,0));
	vec2 pxuv = UV * size;
	vec2 center = floor(pxuv) + vec2(0.5,0.5);
	float dist = 1.0 - distance(center, pxuv) * 2.;
	ALBEDO = clamp(texture(Text, UV).xyz * dist, 0.0, 1.0) * texture(gradient, vec2(dist)).xyz * 30.0;
}