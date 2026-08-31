class_name Backdrop extends ColorRect

##teal, green, blue, violet, maroon, olive.
const HUES: Array[float] = [0.0, -40.0, 55.0, 110.0, 175.0, -110.0]

## Seconds to sweep from one level's hue to the next.
const SHIFT_DURATION := 0.6

const FIELD_SPREAD := 64.0

const BAND_WIDTH_MIN := 0.25
const BAND_WIDTH_MAX := 0.60

var _order := ShuffleBag.new(HUES.size())

var _shift: Tween


func _ready() -> void:
	GameState.level_changed.connect(_on_level_changed)
	material.set_shader_parameter("level_hue", _hue_for(GameState.level))
	_reroll_field()


func _on_level_changed(level_number: int) -> void:
	if _shift != null and _shift.is_valid():
		_shift.kill()

	var current: float = material.get_shader_parameter("level_hue")
	var target := current + angle_difference(current, _hue_for(level_number))

	_shift = create_tween().set_trans(Tween.TRANS_SINE)
	_shift.tween_property(material, "shader_parameter/level_hue", target, SHIFT_DURATION)
	_reroll_field()



func _hue_for(level_number: int) -> float:
	return deg_to_rad(HUES[_order.index_at(level_number - 1)])


func _reroll_field() -> void:
	material.set_shader_parameter("field_offset", Vector2(
		randf_range(0.0, FIELD_SPREAD),
		randf_range(0.0, FIELD_SPREAD),
	))

	var half := randf_range(BAND_WIDTH_MIN, BAND_WIDTH_MAX) * 0.5
	material.set_shader_parameter("ramp_low", 0.5 - half)
	material.set_shader_parameter("ramp_high", 0.5 + half)
