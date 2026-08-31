shader_type canvas_item;

// Backdrop for the brick field: a slow plasma, quantised to the same cell as a
// brick and ordered-dithered between four dark teals. Quantising to the brick
// cell is the point — the backdrop is built out of the grid the bricks sit on
// rather than laid behind it, which is what makes it read as text mode.

// Cell the field is quantised to. Matches LevelBuilder.BRICK_SIZE.
uniform vec2 cell_size = vec2(28.0, 15.0);
// Nudges the cell grid so its seams line up with the brick field. See
// LevelBuilder.GRID_ORIGIN — this is that origin folded back into one cell.
uniform vec2 grid_offset = vec2(11.0, 2.0);

// Must be assigned to a NoiseTexture2D with seamless on, or the field visibly
// wraps as it drifts.
uniform sampler2D noise_texture : repeat_enable;
// Zoom of each of the two noise samples, in periods across the field. Low
// numbers on purpose: this should breathe, not boil.
uniform float scale_a = 0.9;
uniform float scale_b = 1.7;
// How far each sample drifts per second. Opposed directions, so the two slide
// through each other instead of the whole field sliding one way.
uniform vec2 drift_a = vec2(0.012, 0.006);
uniform vec2 drift_b = vec2(-0.007, 0.010);

// Where in the noise the field is sampled from, in the same cell space the
// fragment steps through. Moved per level: the texture is seamless, so a
// different origin is a different-looking patch at no cost, where reseeding the
// noise would regenerate the whole texture.
uniform vec2 field_offset = vec2(0.0);

// Window of the raw noise that gets stretched across the ramp. Widen the gap
// for a flatter field, narrow it for harder banding.
uniform float ramp_low : hint_range(0.0, 1.0) = 0.30;
uniform float ramp_high : hint_range(0.0, 1.0) = 0.70;

// The ramp, darkest first. Keep every entry under ~20% luminance or the DB32
// brick colours stop reading against it.
uniform vec4 ramp_0 : source_color = vec4(0.0, 0.078431, 0.086275, 1.0);
uniform vec4 ramp_1 : source_color = vec4(0.0, 0.137255, 0.145098, 1.0);
uniform vec4 ramp_2 : source_color = vec4(0.0, 0.194684, 0.195953, 1.0);
uniform vec4 ramp_3 : source_color = vec4(0.003922, 0.227451, 0.223529, 1.0);

// Rotates the whole ramp about the grey axis, in radians. Drive from
// GameState.level so the field drifts as the run goes on.
uniform float level_hue = 0.0;

// Noise UV advanced per cell, before scale. 0.05 puts roughly one period of
// scale_a across the 20-cell width of the field.
const float NOISE_STEP = 0.05;

// Ordered 4x4 Bayer matrix, the classic VGA dither.
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

// Rodrigues rotation about the (1,1,1) axis: shifts hue while leaving luma
// alone, so a hue drift can't brighten the field out of its value range.
vec3 hue_shift(vec3 color, float angle) {
	const vec3 axis = vec3(0.5773503); // normalised (1, 1, 1)
	float c = cos(angle);
	return color * c
		+ cross(axis, color) * sin(angle)
		+ axis * dot(axis, color) * (1.0 - c);
}

void fragment() {
	vec2 cell = floor((FRAGCOORD.xy + grid_offset) / cell_size);

	// Sampled per cell rather than per pixel, so a cell is one flat colour the
	// way a character cell would be.
	float a = texture(noise_texture, (cell * NOISE_STEP + field_offset) * scale_a + drift_a * TIME).r;
	float b = texture(noise_texture, (cell * NOISE_STEP + field_offset) * scale_b + drift_b * TIME).r;
	float value = smoothstep(ramp_low, ramp_high, a * 0.65 + b * 0.35);

	// Dither threshold varies per cell, not per pixel — a cell picks one of the
	// two ramp entries it falls between, and the checkerboard forms across the
	// field. Per-pixel would texture the inside of each cell and lose the grid.
	ivec2 tile = ivec2(mod(cell, 4.0));
	float threshold = (BAYER[tile.y * 4 + tile.x] + 0.5) / 16.0;

	float scaled = clamp(value, 0.0, 1.0) * 3.0;
	int index = int(floor(scaled)) + (fract(scaled) > threshold ? 1 : 0);

	COLOR = vec4(hue_shift(ramp_color(index), level_hue), 1.0);
}
