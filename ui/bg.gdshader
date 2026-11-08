shader_type canvas_item;


uniform vec2 cell_size = vec2(28.0, 15.0);
uniform vec2 grid_offset = vec2(11.0, 2.0);

uniform sampler2D noise_texture : repeat_enable;
uniform float scale_a = 0.9;
uniform float scale_b = 1.7;
uniform vec2 drift_a = vec2(0.012, 0.006);
uniform vec2 drift_b = vec2(-0.007, 0.010);

uniform vec2 field_offset = vec2(0.0);

uniform float ramp_low : hint_range(0.0, 1.0) = 0.30;
uniform float ramp_high : hint_range(0.0, 1.0) = 0.70;

uniform vec4 ramp_0 : source_color = vec4(0.0, 0.078431, 0.086275, 1.0);
uniform vec4 ramp_1 : source_color = vec4(0.0, 0.137255, 0.145098, 1.0);
uniform vec4 ramp_2 : source_color = vec4(0.0, 0.194684, 0.195953, 1.0);
uniform vec4 ramp_3 : source_color = vec4(0.003922, 0.227451, 0.223529, 1.0);

uniform float level_hue = 0.0;

const float NOISE_STEP = 0.05;

const float BAYER[16] = float[](
	 0.0,  8.0,  2.0, 10.0,
	12.0,  4.0, 14.0,  6.0,
	 3.0, 11.0,  1.0,  9.0,
	15.0,  7.0, 13.0,  5.0
);

vec3 ramp_color(int index) {
	if (index <= 0) { return ramp_0.rgb; }
	if (index == 1) { return ramp_1.rgb; }
	if (index == 2) { return ramp_2.rgb; }
	return ramp_3.rgb;
}

vec3 hue_shift(vec3 color, float angle) {
	const vec3 axis = vec3(0.5773503);
	float c = cos(angle);
	return color * c
		+ cross(axis, color) * sin(angle)
		+ axis * dot(axis, color) * (1.0 - c);
}

void fragment() {
	vec2 cell = floor((FRAGCOORD.xy + grid_offset) / cell_size);

	float a = texture(noise_texture, (cell * NOISE_STEP + field_offset) * scale_a + drift_a * TIME).r;
	float b = texture(noise_texture, (cell * NOISE_STEP + field_offset) * scale_b + drift_b * TIME).r;
	float value = smoothstep(ramp_low, ramp_high, a * 0.65 + b * 0.35);

	ivec2 tile = ivec2(mod(cell, 4.0));
	float threshold = (BAYER[tile.y * 4 + tile.x] + 0.5) / 16.0;

	float scaled = clamp(value, 0.0, 1.0) * 3.0;
	int index = int(floor(scaled)) + (fract(scaled) > threshold ? 1 : 0);

	COLOR = vec4(hue_shift(ramp_color(index), level_hue), 1.0);
}
