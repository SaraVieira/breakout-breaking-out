extends Control

const MAX_LIVES: int = 3
@onready var PowerupPopup: Control = $Container
@onready var level: Label = $HSplitContainer/level

@onready var lives: Label = %lives
@onready var points: Label = %points


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_refresh()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_refresh()
	if GameState.is_showing_powerup:
		PowerupPopup.show()
		GameState.pause_game()
	else:
		PowerupPopup.hide()


func _refresh() -> void:
	points.text = str(GameState.score)
	var filled: int = clampi(GameState.lives, 0, MAX_LIVES)
	lives.text = "♥".repeat(filled) + "♡".repeat(MAX_LIVES - filled)
	level.text = "Level: " + str(GameState.level)

func _on_button_pressed() -> void:
	GameState.next_level()
	GameState.resume_game()
