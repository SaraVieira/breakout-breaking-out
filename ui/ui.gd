extends Control
@onready var lives: Label = $lives
@onready var points: Label = $points


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	points.text = str(GameState.score)
	lives.text = str(GameState.lives)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	points.text = str(GameState.score)
	lives.text = str(GameState.lives)
