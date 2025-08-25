shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_tex : hint_screen_texture;
uniform float radius : hint_range(0.0, 20.0, 0.1) = 8.0;
uniform float amount : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform vec4 tint_color : source_color = vec4(1.0);

void fragment() {
	vec2 uv = SCREEN_UV;
	float r = max(radius, 0.0);
	vec4 out_col;
	if (r <= 0.0) {
		out_col = texture(screen_tex, uv);
	} else {
		vec2 texel = SCREEN_PIXEL_SIZE * r;

		const int TAP_COUNT = 12;
		vec2 kernel[12] = vec2[](
			vec2(-0.326212, -0.40581),
			vec2(-0.840144, -0.07358),
			vec2(-0.695914, 0.457137),
			vec2(-0.203345, 0.620716),
			vec2(0.96234, -0.194983),
			vec2(0.473434, -0.480026),
			vec2(0.519456, 0.767022),
			vec2(0.185461, -0.893124),
			vec2(0.507431, 0.064425),
			vec2(0.89642, 0.412458),
			vec2(-0.32194, -0.932615),
			vec2(-0.791559, -0.59771)
		);

		vec4 acc = texture(screen_tex, uv);
		float wsum = 1.0;
		for (int i = 0; i < TAP_COUNT; i++) {
			vec2 o = kernel[i] * texel;
			float w = 1.0 - clamp(length(kernel[i]), 0.0, 1.0);
			acc += texture(screen_tex, uv + o) * w;
			wsum += w;
		}

		vec4 blurred = acc / wsum;
		vec4 original = texture(screen_tex, uv);
		out_col = mix(original, blurred, amount);
	}
	COLOR = out_col * tint_color;
}
