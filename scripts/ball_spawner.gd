class_name BallSpawner extends Node2D

const BALL_SCENE := preload("res://ball/ball.tscn")
const SPLIT_ANGLE_DEGREES := 25.0

@export var main_ball: Ball


func _ready() -> void:
	main_ball.served.connect(_on_served)
	main_ball.fell.connect(_on_ball_fell)
	GameState.level_changed.connect(_on_level_changed)


func _on_served(from: Vector2, with_velocity: Vector2) -> void:
	for i in GameState.balls - 1:
		var side := -1.0 if i % 2 == 0 else 1.0
		var step := floorf(i / 2.0) + 1.0
		_spawn_extra(from, with_velocity.rotated(deg_to_rad(SPLIT_ANGLE_DEGREES * step * side)))


func _spawn_extra(from: Vector2, with_velocity: Vector2) -> void:
	var ball: Ball = BALL_SCENE.instantiate()
	ball.is_extra = true
	ball.launched = true
	ball.velocity = with_velocity
	ball.fell.connect(_on_ball_fell)
	add_child(ball)
	ball.global_position = from


func _on_ball_fell(ball: Ball) -> void:
	if ball.is_extra:
		ball.queue_free()
	else:
		ball.park()

	if _active_ball_count() == 0:
		GameState.lose_life()
		print("Life lost! Remaining lives: ", GameState.lives)
		main_ball.serve()


func _active_ball_count() -> int:
	var count := 1 if main_ball.is_active else 0
	for extra in get_children():
		if not extra.is_queued_for_deletion():
			count += 1
	return count


func _on_level_changed(_level: int) -> void:
	for extra in get_children():
		remove_child(extra)
		extra.queue_free()
