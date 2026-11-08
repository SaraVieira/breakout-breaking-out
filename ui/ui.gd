extends Control

const MAX_LIVES: int = 3
@onready var level: Label = $HSplitContainer/HSplitContainer/level
@onready var lives: Label = %lives
@onready var points: Label = %points
 

func _ready() -> void:
	_refresh()

func _process(delta: float) -> void:
	_refresh()


func _refresh() -> void:
	points.text = str(GameState.score)
	var filled: int = clampi(GameState.lives, 0, MAX_LIVES)
	lives.text = "♥".repeat(filled) + "♡".repeat(MAX_LIVES - filled)
	level.text = "Level: " + str(GameState.level)
