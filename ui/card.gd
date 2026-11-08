extends Control
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cemter: ColorRect = $cemter
@onready var button: Button = $Button

var powerup: PowerUpData

func _ready() -> void:
	sprite_2d.texture = powerup.image
	cemter.color = powerup.color
	button.text = powerup.name


func _process(delta: float) -> void:
	pass

func _on_card_click() -> void:
	GameState.current_powerups.append(powerup.id)
	GameState.next_level()
	GameState.resume_game()
	print("Next level: ", GameState.level)
