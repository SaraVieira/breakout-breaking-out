extends Node

var score: int = 0
var level: int = 1
var lives: int = 3
var is_game_over: bool = false
var is_game_won: bool = false


func reset() -> void:
	score = 0
	level = 1
	lives = 3
	is_game_over = false
	is_game_won = false

func add_score(points: int) -> void:
	score += points

func lose_life() -> void:

	if lives <= 0:
		is_game_over = true
	else:
		lives -= 1

func win_game() -> void:
	is_game_won = true
