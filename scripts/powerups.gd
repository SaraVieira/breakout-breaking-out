class_name PowerUp
const _3_BALLS = preload("uid://c2u6v2lc8qkhe")
const SPEED = preload("uid://c75o8noe4eb4y")
const EXPAND = preload("uid://bqbrs200pao3v")
const THROUGH = preload("uid://mv1a8isoltyy")
const MAGNET = preload("uid://3u4mhm8i8skf")

class PowerUpState extends RefCounted:
	var name: String
	var description: String
	var id: String
	var image: CompressedTexture2D
	var color: Color


	func _init(_name, _description, _id, _image, _color):
		name = _name
		description = _description
		id = _id
		image = _image
		color = _color




var balls3 =  PowerUpState.new("3 Balls", "Adds 2 extra balls to the game.", "balls3", _3_BALLS, Color(0.145, 0.476, 0.476, 1.0))
var speed_up = PowerUpState.new("Speed Up", "Increases the speed of the ball.", "speed_up", SPEED, Color(0.804, 0.833, 0.221, 1.0))
var paddle_expand = PowerUpState.new("Paddle Expand", "Expands the paddle size.", "paddle_expand", EXPAND, Color(0.768, 0.428, 0.31, 1.0))
var through_ball = PowerUpState.new("Through Ball", "Ball can pass through blocks.", "through_ball", THROUGH, Color(0.768, 0.428, 0.31, 1.0))
var sticky_paddle = PowerUpState.new("Sticky Paddle", "Ball sticks to the paddle on contact.", "sticky_paddle", EXPAND, Color(0.768, 0.428, 0.31, 1.0))
var laser = PowerUpState.new("Laser", "Paddle can shoot lasers.", "laser", EXPAND, Color(0.768, 0.428, 0.31, 1.0))
var shield = PowerUpState.new("Shield", "Protects the paddle from losing a life.", "shield", EXPAND, Color(0.768, 0.428, 0.31, 1.0))
var magnet = PowerUpState.new("Magnet", "Attracts the ball to the paddle.", "magnet", MAGNET, Color(0.768, 0.428, 0.31, 1.0))
var fire_ball = PowerUpState.new("Fire Ball", "Ball can destroy blocks on contact.", "fire_ball", EXPAND, Color(0.768, 0.428, 0.31, 1.0))
var score_multiplier = PowerUpState.new("Score Multiplier", "Doubles the score earned for a short duration.", "score_multiplier", EXPAND, Color(0.768, 0.428, 0.31, 1.0))

var allPowerUps = [balls3, speed_up, paddle_expand, through_ball, sticky_paddle, laser, shield, magnet, fire_ball, score_multiplier]


func get_random_powerups(count: int) -> Array:
	var shuffled = allPowerUps.duplicate()
	shuffled.shuffle()
	return shuffled.slice(0, count)
