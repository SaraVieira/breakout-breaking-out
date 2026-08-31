extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_card_click() -> void:
	GameState.next_level()
	GameState.resume_game()
	print("Next level: ", GameState.level)
