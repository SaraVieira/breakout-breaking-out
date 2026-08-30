extends CharacterBody2D


const SPEED = 500.0


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
