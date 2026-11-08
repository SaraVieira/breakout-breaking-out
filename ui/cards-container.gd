extends HSplitContainer
const CARD = preload("uid://cejdvy5wykvgn")


func _ready() -> void:
	if GameState.is_showing_powerup:
		for powerup in GameState.shown_powerups:
			var card = CARD.instantiate()
			card.powerup = powerup
			add_child(card)

func _process(delta: float) -> void:
	if GameState.is_showing_powerup:
		self.show()
		GameState.pause_game()
	else:
		self.hide()
