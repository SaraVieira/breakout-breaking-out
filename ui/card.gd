extends Control
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cemter: ColorRect = $cemter

var powerup: PowerUp.PowerUpState

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.texture = powerup.image
	cemter.color = powerup.color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_card_click() -> void:
	GameState.current_powerups.append(powerup.id)
	GameState.next_level()
	GameState.resume_game()
	print("Next level: ", GameState.level)
