class_name Ball extends CharacterBody2D

signal served(from: Vector2, with_velocity: Vector2)
signal fell(ball: Ball)

const REST_OFFSET := Vector2(0, 85)
const MIN_VERTICAL_RATIO := 0.35

var dir = Vector2.DOWN
var is_active = true
var launched := false
var is_extra := false
var _serving := true

@onready var paddle: Node2D = get_tree().get_first_node_in_group("paddle")

func _ready() -> void:
	if is_extra:
		return
	GameState.level_changed.connect(_on_level_changed)
	hold()

func hold() -> void:
	launched = false
	velocity = Vector2.ZERO
	_follow_paddle()

func launch() -> void:
	launched = true
	velocity = Vector2(-1, -1).normalized() * GameState.ball_speed
	if _serving:
		_serving = false
		served.emit(global_position, velocity)

func serve() -> void:
	is_active = true
	_serving = true
	show()
	hold()

func park() -> void:
	is_active = false
	launched = true
	velocity = Vector2.ZERO
	hide()

func _on_level_changed(_level: int) -> void:
	serve()

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
				if GameState.has_powerup(&"magnet") and not is_extra:
					hold()
				else:
					collision.get_collider().nudge_down()

			if collision.get_collider().is_in_group("bottom-wall"):
				fell.emit(self)
				return

		_keep_vertical()


func _keep_vertical() -> void:
	var speed := velocity.length()
	var min_y := speed * MIN_VERTICAL_RATIO
	if absf(velocity.y) >= min_y:
		return
	var vertical_sign := 1.0 if velocity.y > 0.0 else -1.0
	velocity.y = min_y * vertical_sign
	velocity.x = signf(velocity.x) * sqrt(speed * speed - min_y * min_y)
