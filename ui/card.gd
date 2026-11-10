extends Control
@onready var easier: Sprite2D = $easier
@onready var label: Label = $Label
@onready var portal_harder: Sprite2D = $"portal-harder"
@onready var portal_easier: Sprite2D = $"portal-easier"
@onready var portal_neutral: Sprite2D = $"portal-neutral"
@onready var bg_easier: Sprite2D = $"bg-easier"
@onready var bg_harder: Sprite2D = $"bg-harder"
@onready var bg_neutral: Sprite2D = $"bg-neutral"

var powerup: PowerUpData

func _ready() -> void:
	#easier.texture = powerup.image
	label.text = powerup.name
	label.label_settings = label.label_settings.duplicate()
	if powerup.difficulty == 0:
		portal_easier.visible = true
		bg_easier.visible = true
		label.label_settings.shadow_color = "#6abe30"
	if powerup.difficulty == 1:
		portal_neutral.visible = true
		bg_neutral.visible = true
		label.label_settings.shadow_color = "#cac221"
	if powerup.difficulty == 2:
		portal_harder.visible = true
		bg_harder.visible = true
		label.label_settings.shadow_color = "#ac3232"


func _process(delta: float) -> void:
	pass

func _on_card_click() -> void:
	GameState.current_powerups.append(powerup.id)
	GameState.next_level()
	GameState.resume_game()
	print("Next level: ", GameState.level)
