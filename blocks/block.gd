class_name Block extends StaticBody2D
@onready var label: Label = $Label

var blocks = {
	0: {
		"is_metallic": true,
		"hits": null,
		"points": 0,
		"highlight_color": Color(1,1,1),
		"color": Color("ffd700ff")
	},
	1: {
		"is_metallic": true,
		"hits": 2,
		"highlight_color": Color(1,1,1),
		"points": 200,
		"color": Color("696a6a")
	},
	2: {
		"hits": 1,
		"highlight_color": Color(0.5,0.5,1),
		"points": 50,
		"color": Color("5fcde4"),
		"is_metallic": false,
	},
	3: {
		"hits": 1,
		"highlight_color": Color(0.5,1,0.5),
		"points": 50,
		"color": Color("53c194"),
		"is_metallic": false,
	},
	4: {
		"hits": 1,
		"highlight_color": Color(1,0.5,1),
		"points": 50,
		"color": Color("#76428a"),
		"is_metallic": false,
	},
	5: {
		"hits": 1,
		"highlight_color": Color(1,0.5,1),
		"points": 50,
		"color": Color("ac3232"),
		"is_metallic": false,
	}
}
enum BlockType {GOLD, SILVER, BLUE, GREEN, PURPLE, RED}
var hits = 0

@export var block_type: BlockType = BlockType.BLUE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.label_settings = label.label_settings.duplicate()
	label.label_settings.font_color = blocks[block_type]["color"] if blocks[block_type].has("color") else Color(1,1,1)

	if blocks[block_type]["is_metallic"]:
		label.material["shader_parameter/highlight_color"] = blocks[block_type]["highlight_color"]
	else:
		label.text = "▤▤"

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

		var blocks_in_scene = get_tree().get_nodes_in_group("brick")
		var gold_blocks = blocks_in_scene.filter(func(b): return b.block_type == BlockType.GOLD)
		if gold_blocks.size() == 0:
			GameState.win_game()
