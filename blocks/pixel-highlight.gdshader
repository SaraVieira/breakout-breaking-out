// 2D Pixel Art Highlight Shader
// Creates a crisp pixel line of a given size that periodically glides over the sprite.
//
// You must supply the texture_size uniform with the size of the texture in the sprite.
// Use a negative speed for flipping the direction.
shader_type canvas_item;

uniform vec4 highlight_color: source_color = vec4(1.0, 1.0, 1.0, 1.0); // Color of the highlight (alpha scales the strength)
uniform float size_effect: hint_range(1.0, 10.0, 1.0) = 1.0; // Size of the effect in pixel units
uniform float speed = 1; // Effect speed
uniform float highlight_strength: hint_range(-4.0, 4.0, 0.05) = 0.5; // Strength of the highlight
uniform float angle_degrees: hint_range(0.0, 360.0, 1.0) = 45.0; // Travel direction of the effect (0 = left to right, 90 = top to bottom)
uniform float pause_duration = 0.5; // Pause duration between cycles
uniform vec2 texture_size = vec2(16, 16); // Texture size in pixels (e.g., vec2(16.0, 16.0) for a 16x16 texture)

void fragment() {
    // Set up base parameters
    vec4 old_color = COLOR;
    float time = TIME * abs(speed); // Absolute time for both positive and negative speeds
    float effect_cycle_duration = 1.0 + pause_duration; // Total time for one cycle and pause
    float mod_time = mod(time, effect_cycle_duration); // Current time within the cycle

    // Handle the pause
    float progress = mod_time / 1.0; // Normalize mod_time for active duration only

    if (mod_time > 1.0) {
        progress = 1.0; // Hold the highlight at the last position during the pause
    }

    // Reverse the direction if speed is negative
    if (speed < 0.0) {
        progress = 1.0 - progress; // Reverse progress when speed is negative
    }

    // Direction the highlight travels in; the band itself is perpendicular to it
    float angle = radians(angle_degrees);
    vec2 direction = vec2(cos(angle), sin(angle));

    // Snap the UV coordinates to the pixel grid, then work in pixel units
    vec2 pixel_size_uv = vec2(1.0) / texture_size;
    vec2 snapped_uv = floor(UV / pixel_size_uv) * pixel_size_uv;
    vec2 pixel_position = snapped_uv * texture_size;

    // Project the pixel onto the travel direction
    float position_value = dot(pixel_position, direction);

    // Project the whole texture rect onto the travel direction to get the sweep range
    float sweep_start = min(direction.x, 0.0) * texture_size.x + min(direction.y, 0.0) * texture_size.y;
    float sweep_length = abs(direction.x) * texture_size.x + abs(direction.y) * texture_size.y;

    // Calculate the current position of the highlight, padded so it fully enters and exits
    float half_size = size_effect / 2.0;
    float current_position = mix(sweep_start - half_size, sweep_start + sweep_length + half_size, progress);

    // Set the lower and upper bounds for the highlight effect
    float effect_lower_bound = current_position - half_size;
    float effect_upper_bound = current_position + half_size;

    // Use step to create crisp boundaries for the effect
    float effect_distance = step(effect_lower_bound, position_value) - step(effect_upper_bound, position_value);

    // Blend the picked color in wherever the band covers the pixel
    float blend = effect_distance * highlight_strength * highlight_color.a;
    COLOR.rgb = mix(old_color.rgb, highlight_color.rgb, vec3(blend));
}
