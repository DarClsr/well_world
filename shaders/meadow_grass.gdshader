shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo_tex : source_color;
uniform float sway_strength = 0.11;
uniform float sway_speed = 0.92;
uniform float wind_frequency = 0.31;
uniform float wind_strength = 0.62;
uniform float motion_time = 0.0;

varying float instance_brightness;

void vertex() {
	vec3 origin = MODEL_MATRIX[3].xyz;
	float camera_distance = distance(CAMERA_POSITION_WORLD, origin);
	float phase = origin.x * wind_frequency + origin.z * wind_frequency * 0.79;
	float wind = sin(motion_time * sway_speed + phase)
		+ 0.38 * sin(motion_time * sway_speed * 1.67 + phase * 2.13);
	float height_ratio = clamp(VERTEX.y / 1.84, 0.0, 1.0);
	float camera_fade = 1.0 - smoothstep(12.0, 30.0, camera_distance);
	float bend = wind * sway_strength * wind_strength * height_ratio * height_ratio * mix(0.18, 1.0, camera_fade);
	VERTEX.x += bend;
	VERTEX.z += bend * 0.52;
	VERTEX *= 1.0 - smoothstep(26.0, 42.0, camera_distance);
	instance_brightness = INSTANCE_CUSTOM.r;
}

void fragment() {
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
	vec3 source = texture(albedo_tex, UV).rgb;
	float value = dot(source, vec3(0.299, 0.587, 0.114));
	float muted_value = mix(0.36, 0.50, value);
	vec3 muted_hue = mix(vec3(1.0), source / max(value, 0.001), 0.05);
	vec3 grass_color = muted_hue * muted_value * instance_brightness * vec3(0.72, 0.95, 0.70);
	ALBEDO = grass_color;
	EMISSION = grass_color * 0.03;
	ROUGHNESS = 0.92;
}
