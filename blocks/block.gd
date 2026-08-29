class_name Block extends StaticBody2D
@onready var sprite2d: Sprite2D = $sprite

var blocks = {
	0: {
		"sprite": preload("uid://da2bffkkl0i1v"),
		"hits": null,
		"points": 0,
		"highlight_color": Color(1,1,1)
	},
	1: {
		"sprite":  preload("uid://dt7bk8hxcjsd5"),
		"hits": 2,
		"highlight_color": Color(1,1,1),
		"points": 200
	},
	2: {
		"sprite": preload("uid://bjxra7n7qtj1c"),
		"hits": 1,
		"highlight_color": Color(0.5,0.5,1),
		"points": 50,
	},
	3: {
		"sprite": preload("uid://xa2rmf06q2f1"),
		"hits": 1,
		"highlight_color": Color(0.5,1,0.5),
		"points": 50,
	},
	4: {
		"sprite": preload("uid://bqhl8dcvek6ca"),
		"hits": 1,
		"highlight_color": Color(1,0.5,1),
		"points": 50,
	},
	5: {
		"sprite": preload("uid://bqhl8dcvek6ca"),
		"hits": 1,
		"highlight_color": Color(1,0.5,1),
		"points": 50,
	}
}
enum BlockType {GOLD, SILVER, BLUE, GREEN, PURPLE, RED}
var hits = 0

@export var block_type: BlockType = BlockType.BLUE

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
		if block_type == BlockType.GOLD:
			return
		if block_type == BlockType.SILVER:
			hits += 1
			if hits >= blocks[1]["hits"]:
				queue_free()
		else:
			queue_free()
			GameState.add_score(blocks[block_type]["points"])
