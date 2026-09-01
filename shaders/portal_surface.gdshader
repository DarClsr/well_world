shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_prepass_alpha;

uniform vec4 deep_color : source_color = vec4(0.20, 0.54, 0.52, 1.0);
uniform vec4 glow_color : source_color = vec4(0.51, 0.94, 0.85, 1.0);
uniform float reaction_strength : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float time_glow : hint_range(0.5, 2.0, 0.01) = 1.0;


void fragment() {
	vec2 centered = UV * 2.0 - 1.0;
	float radius = length(centered);
	float mask = 1.0 - smoothstep(0.88, 1.0, radius);
	float broad_flow = sin((centered.x + centered.y) * 7.0 + TIME * 0.65);
	float crossing_flow = sin((centered.x - centered.y) * 5.0 - TIME * 0.42 + broad_flow * 0.8);
	float inner_ripple = sin(radius * 18.0 - TIME * (1.0 + reaction_strength * 1.8) + crossing_flow);
	float flow = 0.5 + broad_flow * 0.16 + crossing_flow * 0.14 + inner_ripple * 0.12;
	float edge_glow = smoothstep(0.48, 0.9, radius) * mask;
	float center_depth = 1.0 - smoothstep(0.0, 0.88, radius);
	vec3 color = mix(deep_color.rgb, glow_color.rgb, clamp(flow + edge_glow * 0.22 - center_depth * 0.16, 0.0, 1.0));
	ALBEDO = color;
	EMISSION = color * (0.28 + edge_glow * 0.34 + reaction_strength * 0.42) * time_glow;
	ALPHA = mask * (0.82 + flow * 0.1);
}
