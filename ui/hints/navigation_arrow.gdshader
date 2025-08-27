shader_type canvas_item;
render_mode unshaded, blend_add;

uniform float thickness : hint_range(0.0, 1.0) = 0.12; // Total line thickness in UV space
uniform float glow : hint_range(0.0, 1.0) = 0.20; // Extra soft glow around the line
uniform float speed : hint_range(-4.0, 4.0) = 0.5; // Rainbow scroll speed
uniform float cycles : hint_range(0.1, 10.0) = 1.0; // Rainbow cycles along the X axis
uniform float brightness : hint_range(0.0, 4.0) = 1.5; // Brightness multiplier
uniform float alpha : hint_range(0.0, 1.0) = 1.0; // Opacity multiplier
uniform bool vertical = false; // If true, the line runs vertically
uniform float angle_deg : hint_range(-180.0, 180.0) = 0.0; // Additional rotation in degrees (0 keeps original)
uniform bool reverse_colors = false; // Flip gradient direction

// Color sources
uniform bool use_gradient_texture = false;
uniform sampler2D gradient_tex;
uniform bool use_two_colors = false;
uniform vec4 color_a : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 color_b : source_color = vec4(0.0, 0.0, 1.0, 1.0);

vec3 hsv2rgb(vec3 c) {
	vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
	return c.z * mix(vec3(1.0), rgb, c.y);
}

void fragment() {
	// Rotate UV around the center according to angle and optional vertical toggle
	float rad = radians(angle_deg + (vertical ? 90.0 : 0.0));
    float c = cos(rad);
    float s = sin(rad);
    mat2 rot = mat2(vec2(c, s), vec2(-s, c));
	vec2 uv = (rot * (UV - vec2(0.5))) + vec2(0.5);

	float half_thickness = thickness * 0.5;
	float dist_to_center = abs(uv.y - 0.5);
	// 1.0 inside the line core, smoothly falling to 0.0 over `glow`
	float line_mask = 1.0 - smoothstep(half_thickness, half_thickness + glow, dist_to_center);

	// Coordinate along the line for color evaluation
	float t = uv.x;
	if (reverse_colors) {
		t = 1.0 - t;
	}
	// Scroll and repeat
	t = fract(t * cycles + TIME * speed);

	vec3 base_rgb;
	float base_a = 1.0;
	if (use_gradient_texture) {
		vec4 g = texture(gradient_tex, vec2(t, 0.5));
		base_rgb = g.rgb;
		base_a = g.a;
	} else if (use_two_colors) {
		base_rgb = mix(color_a.rgb, color_b.rgb, t);
		base_a = mix(color_a.a, color_b.a, t);
	} else {
		// Default to rainbow HSV
		base_rgb = hsv2rgb(vec3(t, 1.0, 1.0));
	}

	vec3 rgb = base_rgb * brightness * line_mask;
	COLOR = vec4(rgb, line_mask * alpha * base_a);
}
