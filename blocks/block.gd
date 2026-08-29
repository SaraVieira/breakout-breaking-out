class_name Block extends StaticBody2D
@onready var sprite2d: Sprite2D = $sprite

var blocks = {
	0: {
		"sprite": preload("uid://da2bffkkl0i1v"),
		"hits": null,
		"highlight_color": Color(1,1,1)
	},
	1: {
		"sprite":  preload("uid://dt7bk8hxcjsd5"),
		"hits": 2,
		"highlight_color": Color(1,1,1)
	}
}
enum BlockType {GOLD, SILVER}
var hits = 0

@export var block_type: BlockType = BlockType.SILVER

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sprite = sprite2d
	sprite.texture = blocks[block_type]["sprite"]
	sprite.material["shader_parameter/highlight_color"] = blocks[block_type]["highlight_color"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func hit(body: Node2D) -> void:
	if body.is_in_group("ball"):
		if block_type == BlockType.SILVER:
			hits += 1
			if hits >= blocks[1]["hits"]:
				queue_free()
		else:
			queue_free()
