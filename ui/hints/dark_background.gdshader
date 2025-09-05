shader_type canvas_item;

// Normalized rectangle in this panel's local UV space (x, y, w, h)
uniform vec4 clip_rect = vec4(0.0);
uniform bool clip_enabled = false;
uniform vec4 bg_color : source_color = vec4(0.0, 0.0, 0.0, 0.6);
uniform vec2 panel_size = vec2(1.0);

varying vec2 local_uv;

void vertex() {
	// Compute normalized local UV based on panel size passed from script
	local_uv = VERTEX / panel_size;
}

void fragment() {
	vec2 uv = local_uv;
	bool inside = false;
	if (clip_enabled) {
		inside = uv.x >= clip_rect.x && uv.y >= clip_rect.y &&
			uv.x <= (clip_rect.x + clip_rect.z) && uv.y <= (clip_rect.y + clip_rect.w);
	}
	float a = bg_color.a;
	if (clip_enabled && inside) {
		a = 0.0;
	}
	COLOR = vec4(bg_color.rgb, a);
}
