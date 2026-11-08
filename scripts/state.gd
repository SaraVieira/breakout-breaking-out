extends Node

signal level_changed(level: int)
signal powerups_offered(powerups: Array[PowerUpData])

var score: int = 0
var level: int = 1
var lives: int = 3
var is_game_over: bool = false
var is_level_won: bool = false
var is_showing_powerup: bool = false
var paused: bool = false
var balls: int:
	get:
		return 3 if has_powerup(&"balls3") else 1
const POWERUPS: Registry = preload("res://powerups/power_ups.tres")

const BALL_BASE_SPEED := 250.0
const BALL_MIN_SPEED := 160.0
const BALL_MAX_SPEED := 350.0

var ball_speed := BALL_BASE_SPEED

var current_powerups: Array[StringName] = []
var shown_powerups: Array[PowerUpData] = []


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and not is_showing_powerup:
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
	paused = false
	current_powerups.clear()
	shown_powerups.clear()
	_update_ball_speed()
	level_changed.emit(level)

func has_powerup(id: StringName) -> bool:
	return current_powerups.has(id)

func count_powerup(id: StringName) -> int:
	var count := 0
	for powerup_id in current_powerups:
		if powerup_id == id:
			count += 1
	return count

func add_score(points: int) -> void:
	var multiplier_cards = count_powerup(&"score_multiplier")
	if multiplier_cards > 0:
		points *= 1.1 ** multiplier_cards
	score += points

func lose_life() -> void:
	if has_powerup(&"shield"):
		current_powerups.erase(&"shield")
		return
	lives = maxi(lives - 1, 0)
	if lives == 0:
		is_game_over = true

func win_level() -> void:
	is_level_won = true
	is_showing_powerup = true
	offer_powerups()

func can_offer(id: StringName) -> bool:
	match id:
		&"balls3":
			return balls < 3
		&"speed_up":
			return ball_speed < BALL_MAX_SPEED
		&"speed_down":
			return ball_speed > BALL_MIN_SPEED
	return true

func offer_powerups(cache_mode := ResourceLoader.CACHE_MODE_REUSE) -> void:
	var offerable: Array[PowerUpData] = []
	for id in POWERUPS.get_all_string_ids():
		var powerup := POWERUPS.load_entry(id, "", cache_mode) as PowerUpData
		if powerup and can_offer(powerup.id):
			offerable.append(powerup)
	offerable.shuffle()
	shown_powerups = offerable.slice(0, 3)
	powerups_offered.emit(shown_powerups)

func next_level() -> void:
	level += 1
	is_level_won = false
	is_showing_powerup = false
	_update_ball_speed()
	level_changed.emit(level)

func _update_ball_speed() -> void:
	var ups := count_powerup(&"speed_up")
	var downs := count_powerup(&"speed_down")
	var speed := BALL_BASE_SPEED * (1.1 ** ups) * (0.9 ** downs)
	ball_speed = clampf(speed, BALL_MIN_SPEED, BALL_MAX_SPEED)
