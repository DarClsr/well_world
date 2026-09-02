shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo_tex : source_color;
uniform float canopy_min_y = 1.0;
uniform float canopy_max_y = 7.0;
uniform float wind_strength = 0.62;
uniform float motion_time = 0.0;

void vertex() {
	vec3 origin = MODEL_MATRIX[3].xyz;
	float phase = origin.x * 0.17 + origin.z * 0.13;
	float wind = sin(motion_time * 0.48 + phase)
		+ 0.32 * sin(motion_time * 0.83 + phase * 1.71);
	float height_ratio = smoothstep(canopy_min_y, canopy_max_y, VERTEX.y);
	float camera_distance = distance(CAMERA_POSITION_WORLD, origin);
	float camera_fade = 1.0 - smoothstep(20.0, 42.0, camera_distance);
	float bend = wind * 0.12 * wind_strength * height_ratio * height_ratio * mix(0.20, 1.0, camera_fade);
	VERTEX.x += bend;
	VERTEX.z += bend * 0.42;
}

void fragment() {
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
	vec4 leaf = texture(albedo_tex, UV);
	ALBEDO = leaf.rgb;
	ALPHA = leaf.a;
	ALPHA_SCISSOR_THRESHOLD = 0.2;
	ROUGHNESS = 0.90;
}
