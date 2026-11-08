extends HSplitContainer
const CARD = preload("uid://cejdvy5wykvgn")


func _ready() -> void:
	GameState.powerups_offered.connect(_show_cards)
	if GameState.is_showing_powerup:
		_show_cards(GameState.shown_powerups)

func _show_cards(powerups: Array[PowerUpData]) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for powerup in powerups:
		var card = CARD.instantiate()
		card.powerup = powerup
		add_child(card)

func _process(delta: float) -> void:
	if GameState.is_showing_powerup:
		self.show()
		GameState.pause_game()
	else:
		self.hide()
