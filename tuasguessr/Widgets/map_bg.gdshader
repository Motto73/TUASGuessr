shader_type canvas_item;

uniform float vignette_str = 0.2;
uniform float vignette_dist = 0.5;
uniform float lines_size = 20.0;
uniform float lines_distortion = 1.0;
uniform float lines_distortion_scale = 1.0;

uniform vec4 lines_color1 : source_color;
uniform vec4 lines_color2 : source_color;


vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}


void fragment() {
	vec2 pos = UV + vec2(lines_distortion) * noise(UV * lines_distortion_scale + vec2(0.5) * TIME);
	vec2 center = vec2(0.5,0.5);
	float dist = distance(center, UV) * 2.0;
	float vignette = 0.5 + (1.0 - dist + vignette_str) * 0.5;
	float line = mod(pos.y + TIME * 0.1, 1.0 / lines_size) * lines_size;
	COLOR.rgb = mix(lines_color1, lines_color2, line).rgb;
	COLOR.rgb *= vignette;
}