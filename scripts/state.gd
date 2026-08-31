extends Node

signal level_changed(level: int)

var score: int = 0
var level: int = 1
var lives: int = 3
var is_game_over: bool = false
var is_level_won: bool = false
var is_showing_powerup: bool = true
var paused: bool = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if paused:
			resume_game()
		else:
			pause_game()

func pause_game() -> void:
	paused = true

func resume_game() -> void:
	paused = false

func reset() -> void:
	score = 0
	level = 1
	lives = 3
	is_game_over = false
	is_level_won = false
	is_showing_powerup = false
	level_changed.emit(level)

func add_score(points: int) -> void:
	score += points

func lose_life() -> void:
	if lives <= 0:
		is_game_over = true
	else:
		lives -= 1

func win_level() -> void:
	is_level_won = true
	is_showing_powerup = true

func next_level() -> void:
	level += 1
	is_level_won = false
	is_showing_powerup = false
	level_changed.emit(level)
