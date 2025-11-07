shader_type spatial;
render_mode unshaded;

uniform sampler2D _MainTex;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = texture(_MainTex, UV).rgb;
}