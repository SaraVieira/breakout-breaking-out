extends Node

signal level_changed(level: int)
signal powerups_offered(powerups: Array)

var score: int = 0
var level: int = 1
var lives: int = 3
var is_game_over: bool = false
var is_level_won: bool = false
var is_showing_powerup: bool = false
var paused: bool = false
var balls: int = 1
var current_powerups = ["magnet"]
var powerups = PowerUp.new()
var shown_powerups = []

func _ready() -> void:
	win_level()


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
	if current_powerups.has("score_multiplier"):
		points *= 2
	score += points

func lose_life() -> void:
	if lives <= 0:
		is_game_over = true
	else:
		lives -= 1

func win_level() -> void:
	is_level_won = true
	is_showing_powerup = true
	shown_powerups = powerups.get_random_powerups(3)
	powerups_offered.emit(shown_powerups)

func next_level() -> void:
	level += 1
	is_level_won = false
	is_showing_powerup = false
	level_changed.emit(level)
