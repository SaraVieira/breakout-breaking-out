shader_type canvas_item;

uniform vec2 half_size = vec2(0.2, 0.1);
uniform float smooth_size = 0.01;

uniform sampler2D noise_texture: repeat_enable;
uniform vec2 portal_speed = vec2(0.1);

void fragment() {
	vec2 uv = floor(UV / TEXTURE_PIXEL_SIZE) * TEXTURE_PIXEL_SIZE;
	vec2 noise_displacement = uv + portal_speed * TIME;
	vec2 noise = (texture(noise_texture, noise_displacement).rg * 2.0 - vec2(1.0)) * 0.05;
	COLOR = texture(TEXTURE, uv + noise);
	vec2 left_size = 0.5 - half_size;
	vec2 right_size = 0.5 + half_size;
	vec2 left = smoothstep(left_size - smooth_size, left_size + smooth_size, uv + noise);
	vec2 right = smoothstep(right_size + smooth_size, right_size - smooth_size, uv + noise);
	float rectangle = 1.0 - left.x * right.x * left.y * right.y;
	COLOR.a *= rectangle;
}
