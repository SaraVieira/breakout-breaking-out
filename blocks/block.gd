class_name Block extends StaticBody2D

signal broken


const BREAKABLE_GROUP := "breakable"

const DAMAGED_DARKEN := 0.1

const CLINK_OFFSET := Vector2(0, 1.5)
const CLINK_TIME := 0.04


@export var block_type: BlockTypeData = preload("res://blocks/types/blue.tres"):
	set = set_block_type

var hits_taken: int = 0

@onready var sprite: Sprite2D = $Sprite

var _sprite_rest: Vector2
var _clink_tween: Tween


func _ready() -> void:
	_sprite_rest = sprite.position
	_apply_type()


func set_block_type(value: BlockTypeData) -> void:
	block_type = value
	hits_taken = 0
	_apply_type()


func is_breakable() -> bool:
	return block_type.hits > 0


func hit(body: Node2D) -> void:
	if not body.is_in_group("ball"):
		return

	if not is_breakable():
		_clink()
		return

	hits_taken += 1
	if hits_taken >= block_type.hits:
		GameState.add_score(block_type.points)
		queue_free()
		broken.emit()
	else:
		_apply_type()
		_clink()


func _apply_type() -> void:
	if sprite == null or block_type == null:
		return

	sprite.texture = block_type.texture
	sprite.self_modulate = _current_color()

	if is_breakable():
		add_to_group(BREAKABLE_GROUP)
	else:
		remove_from_group(BREAKABLE_GROUP)


func _current_color() -> Color:
	var color := block_type.color
	return color.darkened(DAMAGED_DARKEN) if hits_taken > 0 else color


func _clink() -> void:
	if _clink_tween and _clink_tween.is_valid():
		_clink_tween.kill()
	_clink_tween = create_tween()
	_clink_tween.tween_property(sprite, "position", _sprite_rest + CLINK_OFFSET, CLINK_TIME)
	_clink_tween.tween_property(sprite, "position", _sprite_rest, CLINK_TIME)
