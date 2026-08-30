extends CharacterBody2D
@onready var middle: Label = $"full paddle/middle"


const SPEED = 500.0
const NUDGE_SPACING := -12.0
const REST_LINE_SPACING := -10.0
const BOUNCE_WAIT := 0.05
const BOUNCE_TIME := 0.1

var bounce_tween: Tween

func nudge_down() -> void:
	middle.label_settings.line_spacing = NUDGE_SPACING
	if bounce_tween and bounce_tween.is_valid():
		bounce_tween.kill()
	bounce_tween = create_tween()
	bounce_tween.tween_interval(BOUNCE_WAIT)
	bounce_tween.tween_property(middle.label_settings, "line_spacing", REST_LINE_SPACING, BOUNCE_TIME)

func _physics_process(delta: float) -> void:
	if GameState.paused:
		return

	var direction := Input.get_axis("left", "right")
	var is_shift_pressed := Input.is_action_pressed("shift")
	var window_size := get_viewport_rect().size
	var constrain = window_size.x / 2 - 16
	var speed_multiplier = 1.0
	if is_shift_pressed:
		speed_multiplier = 2


	position.x = clamp(position.x, -constrain,constrain)

	if direction:
		velocity.x = direction * (SPEED * speed_multiplier)
	else:
		velocity.x = move_toward(velocity.x, 0, (SPEED))

	move_and_slide()
