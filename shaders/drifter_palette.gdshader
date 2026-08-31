shader_type spatial;
render_mode diffuse_toon, specular_disabled;

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap_anisotropic;
uniform vec4 tint_color : source_color = vec4(0.72, 0.78, 0.70, 1.0);
uniform vec4 rim_color : source_color = vec4(0.30, 0.72, 0.68, 1.0);
uniform float saturation : hint_range(0.0, 1.0, 0.01) = 0.68;
uniform float value_scale : hint_range(0.25, 1.25, 0.01) = 0.78;
uniform float rim_strength : hint_range(0.0, 1.0, 0.01) = 0.10;


void fragment() {
	vec4 sampled = texture(albedo_texture, UV);
	float luminance = dot(sampled.rgb, vec3(0.299, 0.587, 0.114));
	vec3 muted_color = mix(vec3(luminance), sampled.rgb, saturation);
	ALBEDO = muted_color * tint_color.rgb * value_scale;
	ROUGHNESS = 0.94;
	float rim = pow(1.0 - max(dot(NORMAL, VIEW), 0.0), 3.0);
	EMISSION = rim_color.rgb * rim * rim_strength;
}
