shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_never;

uniform vec4 mist_color : source_color = vec4(0.54, 0.72, 0.70, 1.0);
uniform vec4 glow_color : source_color = vec4(0.63, 0.88, 0.84, 1.0);
uniform float density : hint_range(0.0, 1.0, 0.01) = 0.62;
uniform float flow_speed : hint_range(0.0, 2.0, 0.01) = 0.22;


void fragment() {
	vec2 centered = UV * 2.0 - 1.0;
	float horizontal_fade = 1.0 - smoothstep(0.56, 1.0, abs(centered.x));
	float vertical_fade = 1.0 - smoothstep(0.68, 1.0, abs(centered.y));
	float wave_a = sin(UV.y * 17.0 + TIME * flow_speed * 5.0 + sin(UV.x * 8.0) * 1.4);
	float wave_b = sin(UV.x * 13.0 - TIME * flow_speed * 3.0 + UV.y * 5.0);
	float flow = 0.5 + 0.25 * wave_a + 0.25 * wave_b;
	float veil = horizontal_fade * vertical_fade;
	ALBEDO = mix(mist_color.rgb, glow_color.rgb, clamp(flow, 0.0, 1.0) * 0.35);
	EMISSION = glow_color.rgb * veil * 0.16;
	ALPHA = veil * (0.26 + density * 0.34 + flow * 0.12);
}
