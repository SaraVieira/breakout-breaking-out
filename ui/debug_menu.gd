class_name DebugMenu extends CanvasLayer

@onready var panel: PanelContainer = $Panel


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	panel.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F1:
		panel.visible = not panel.visible
		get_viewport().set_input_as_handled()


func _on_win_level_pressed() -> void:
	GameState.win_level()


func _on_reload_powerups_pressed() -> void:
	GameState.is_showing_powerup = true
	GameState.offer_powerups(ResourceLoader.CACHE_MODE_REPLACE_DEEP)
