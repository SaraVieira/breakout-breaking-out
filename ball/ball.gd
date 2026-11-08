extends CharacterBody2D


const REST_OFFSET := Vector2(0, 85)

var dir = Vector2.DOWN
var is_active = true
var launched := false

@onready var paddle: Node2D = get_tree().get_first_node_in_group("paddle")

func _ready() -> void:
	GameState.level_changed.connect(_on_level_changed)

	hold()

func hold() -> void:
	launched = false
	velocity = Vector2.ZERO
	_follow_paddle()

func launch() -> void:
	launched = true
	velocity = Vector2(- GameState.ball_speed, - GameState.ball_speed)

func _on_level_changed(_level: int) -> void:
	var ups := GameState.count_powerup(&"speed_up")
	var downs := GameState.count_powerup(&"speed_down")
	var speed := GameState.BALL_BASE_SPEED * (1.1 ** ups) * (0.9 ** downs)
	GameState.ball_speed = clampf(speed, GameState.BALL_MIN_SPEED, GameState.BALL_MAX_SPEED)
	hold()

func _follow_paddle() -> void:
	if paddle:
		global_position = paddle.global_position + REST_OFFSET

func _physics_process(delta: float) -> void:
	if GameState.paused:
		return

	if not launched:
		_follow_paddle()
		if Input.is_action_just_pressed("space"):
			launch()
		return

	if is_active:
		var collision = move_and_collide(velocity * delta)
		if collision:
			velocity = velocity.bounce(collision.get_normal())

			if collision.get_collider().is_in_group("brick") and collision.get_collider().has_method("hit"):
				collision.get_collider().hit(self)

			if collision.get_collider().is_in_group("paddle"):
				if GameState.has_powerup(&"magnet"):
					hold()
				else:
					collision.get_collider().nudge_down()

			if collision.get_collider().is_in_group("bottom-wall"):
				GameState.lose_life()
				hold()
				print("Life lost! Remaining lives: ", GameState.lives)


		if(velocity.y > 0 and velocity.y < 100):
			velocity.y = -200
