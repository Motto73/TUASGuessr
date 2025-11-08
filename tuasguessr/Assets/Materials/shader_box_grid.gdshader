shader_type spatial;

varying vec3 worldpos;

bool fs(float v){
	return fract(v) < 0.5;
}

void vertex() {
	worldpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	bool yep = fs(worldpos.x) && fs(worldpos.z);
	if(!fs(worldpos.x) && !fs(worldpos.z)) yep = true;
	if(yep) ALBEDO = vec3(1.0,1.0,1.0);
	else ALBEDO = vec3(0.0,0.0,0.0); 
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
