shader_type spatial;
render_mode unshaded;

uniform sampler2D image;

varying vec3 worldpos;

void vertex() {
	worldpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	ALBEDO = texture(image, UV).rgb;
	ALPHA = step(-0.15, worldpos.x);
}