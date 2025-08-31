shader_type spatial;
render_mode blend_mix, specular_schlick_ggx;

uniform vec4 gem_color : source_color = vec4(0.2, 1.0, 0.6, 0.85);
uniform float transparency : hint_range(0.0, 1.0) = 0.6;

uniform float roughness : hint_range(0.0, 1.0) = 0.05;
uniform float specular : hint_range(0.0, 1.0) = 1.0;

uniform float faceting_steps : hint_range(1.0, 32.0) = 8.0;
uniform float faceting_strength : hint_range(0.0, 1.0) = 0.8;

uniform float fresnel_power : hint_range(0.5, 8.0) = 3.0;
uniform float emission_strength : hint_range(0.0, 8.0) = 1.2;
uniform float pulse_speed : hint_range(0.0, 10.0) = 1.5;

void vertex() {
}

void fragment() {
	vec3 n = normalize(NORMAL);

	// Faceted normal approximation
	float steps = max(faceting_steps, 1.0);
	vec3 quantized = normalize(round(n * steps) / steps);
	n = normalize(mix(n, quantized, faceting_strength));
	NORMAL = n;

	// Base PBR values
	ALBEDO = gem_color.rgb;
	METALLIC = 0.0;
	ROUGHNESS = roughness;
	SPECULAR = specular;

	// Fresnel rim + subtle pulsing
	vec3 V = normalize(-VIEW);
	float cos_theta = max(dot(n, V), 0.0);
	float fres = pow(1.0 - cos_theta, fresnel_power);
	float pulse = 0.6 + 0.4 * sin(TIME * pulse_speed);
	EMISSION = gem_color.rgb * (emission_strength * fres * pulse);

	// Transparent gem look, a bit more opaque at center
	float base_alpha = gem_color.a * transparency;
	float alpha = clamp(base_alpha, 0.0, 1.0);
	ALPHA = alpha;
}
