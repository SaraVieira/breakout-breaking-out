shader_type canvas_item;

uniform vec4 highlight_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float size_effect: hint_range(1.0, 10.0, 1.0) = 1.0;
uniform float speed = 1;
uniform float highlight_strength: hint_range(-4.0, 4.0, 0.05) = 0.5;
uniform float angle_degrees: hint_range(0.0, 360.0, 1.0) = 45.0;
uniform float pause_duration = 0.5;
uniform vec2 texture_size = vec2(16, 16);

void fragment() {
    vec4 old_color = COLOR;
    float time = TIME * abs(speed);
    float effect_cycle_duration = 1.0 + pause_duration;
    float mod_time = mod(time, effect_cycle_duration);

    float progress = mod_time / 1.0;

    if (mod_time > 1.0) {
        progress = 1.0;
    }

    if (speed < 0.0) {
        progress = 1.0 - progress;
    }

    float angle = radians(angle_degrees);
    vec2 direction = vec2(cos(angle), sin(angle));

    vec2 pixel_size_uv = vec2(1.0) / texture_size;
    vec2 snapped_uv = floor(UV / pixel_size_uv) * pixel_size_uv;
    vec2 pixel_position = snapped_uv * texture_size;

    float position_value = dot(pixel_position, direction);

    float sweep_start = min(direction.x, 0.0) * texture_size.x + min(direction.y, 0.0) * texture_size.y;
    float sweep_length = abs(direction.x) * texture_size.x + abs(direction.y) * texture_size.y;

    float half_size = size_effect / 2.0;
    float current_position = mix(sweep_start - half_size, sweep_start + sweep_length + half_size, progress);

    float effect_lower_bound = current_position - half_size;
    float effect_upper_bound = current_position + half_size;

    float effect_distance = step(effect_lower_bound, position_value) - step(effect_upper_bound, position_value);

    float blend = effect_distance * highlight_strength * highlight_color.a;
    COLOR.rgb = mix(old_color.rgb, highlight_color.rgb, vec3(blend));
}
