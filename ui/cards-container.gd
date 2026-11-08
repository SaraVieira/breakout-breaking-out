extends HSplitContainer
const CARD = preload("uid://cejdvy5wykvgn")


func _ready() -> void:
	GameState.powerups_offered.connect(_show_cards)
	GameState.level_changed.connect(_on_level_changed)
	if GameState.is_showing_powerup:
		_show_cards(GameState.shown_powerups)
	else:
		hide()

func _show_cards(powerups: Array[PowerUpData]) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for powerup in powerups:
		var card = CARD.instantiate()
		card.powerup = powerup
		add_child(card)
	show()
	GameState.pause_game()

func _on_level_changed(_level: int) -> void:
	hide()
