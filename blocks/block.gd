class_name Block extends StaticBody2D

signal broken


enum BlockType { RED, ORANGE, YELLOW, GREEN, BLUE, PURPLE, STEEL, GOLD }


const BREAKABLE_GROUP := "breakable"

const SOLID_GLYPH := "▤▤"
const METALLIC_GLYPH := "▒▒"

const DAMAGED_DARKEN := 0.1

const CLINK_OFFSET := Vector2(0, 1.5)
const CLINK_TIME := 0.04


static var TYPE_STATS := {
	BlockType.RED: {"color": Color("c2444a"), "hits": 1, "points": 50, "metallic": false},
	BlockType.ORANGE: {"color": Color("df7126"), "hits": 1, "points": 50, "metallic": false},
	BlockType.YELLOW: {"color": Color("fbf236"), "hits": 1, "points": 50, "metallic": false},
	BlockType.GREEN: {"color": Color("53c194"), "hits": 1, "points": 50, "metallic": false},
	BlockType.BLUE: {"color": Color("5fcde4"), "hits": 1, "points": 50, "metallic": false},
	BlockType.PURPLE: {"color": Color("a65ea2"), "hits": 1, "points": 50, "metallic": false},
	BlockType.STEEL: {"color": Color("696a6a"), "hits": 2, "points": 200, "metallic": true},
	BlockType.GOLD: {"color": Color("ffd700"), "hits": 0, "points": 0, "metallic": true},
}

@export var block_type: BlockType = BlockType.BLUE:
	set = set_block_type

var hits_taken: int = 0

@onready var label: Label = $Label

var _label_rest: Vector2
var _clink_tween: Tween


func _ready() -> void:
	label.label_settings = label.label_settings.duplicate()
	_label_rest = label.position
	_apply_type()


func set_block_type(value: BlockType) -> void:
	block_type = value
	hits_taken = 0
	_apply_type()


func stats() -> Dictionary:
	return TYPE_STATS[block_type]


func is_breakable() -> bool:
	return stats()["hits"] > 0


func hit(body: Node2D) -> void:
	if not body.is_in_group("ball"):
		return

	if not is_breakable():
		_clink()
		return

	hits_taken += 1
	if hits_taken >= stats()["hits"]:
		GameState.add_score(stats()["points"])
		queue_free()
		broken.emit()
	else:
		_apply_type()
		_clink()


func _apply_type() -> void:
	if label == null:
		return

	var type_stats := stats()
	label.text = METALLIC_GLYPH if type_stats["metallic"] else SOLID_GLYPH
	label.label_settings.font_color = _current_color()

	if is_breakable():
		add_to_group(BREAKABLE_GROUP)
	else:
		remove_from_group(BREAKABLE_GROUP)


func _current_color() -> Color:
	var color: Color = stats()["color"]
	return color.darkened(DAMAGED_DARKEN) if hits_taken > 0 else color



func _clink() -> void:
	if _clink_tween and _clink_tween.is_valid():
		_clink_tween.kill()
	_clink_tween = create_tween()
	_clink_tween.tween_property(label, "position", _label_rest + CLINK_OFFSET, CLINK_TIME)
	_clink_tween.tween_property(label, "position", _label_rest, CLINK_TIME)
