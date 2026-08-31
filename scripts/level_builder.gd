class_name LevelBuilder extends Node2D

## Builds the brick field for the current level out of the pre-baked JSON.
## Generation lives in the level workshop — this only ever reads.

const BRICK_SCENE := preload("res://blocks/block.tscn")

const BRICK_SIZE := Vector2(28.0, 15.0)

## Column count the generator targets. Narrower levels — hand-made ones, or an
## older batch — are centred against this rather than left-aligned.
const GRID_WIDTH := 18

## Top-left cell of a full-width row. Cell (col, row) sits at
## GRID_ORIGIN + Vector2(col, row) * BRICK_SIZE.
const GRID_ORIGIN := Vector2(-240.0, -150.0)

var levels: Array[PackedStringArray] = []
var current_index: int = -1


var _order: Array[int] = []


func _ready() -> void:
	levels = LevelData.load_levels()
	GameState.level_changed.connect(build)
	build(GameState.level)



func build(level_number: int) -> void:
	clear()
	if levels.is_empty():
		return

	current_index = _level_index(level_number)
	var rows := levels[current_index]
	var origin := _origin_for(rows[0].length())

	for row in rows.size():
		var line := rows[row]
		for column in line.length():
			var cell := line[column]
			if cell == LevelData.EMPTY_CELL:
				continue
			_spawn_brick(LevelData.CHAR_TO_TYPE[cell], origin, column, row)



func _level_index(level_number: int) -> int:
	var slot := maxi(level_number - 1, 0)
	while _order.size() <= slot:
		_refill_order()
	return _order[slot]


## Appends one shuffled pass over every level. Its first pick is swapped away
## from the outgoing pass's last pick, so a level never lands twice in a row
## across the seam between two passes.
func _refill_order() -> void:
	var bag: Array[int] = []
	for index in levels.size():
		bag.append(index)
	bag.shuffle()

	var previous := _order[-1] if not _order.is_empty() else -1
	if bag.size() > 1 and bag[0] == previous:
		var swap := randi_range(1, bag.size() - 1)
		bag[0] = bag[swap]
		bag[swap] = previous

	_order.append_array(bag)


## GRID_ORIGIN, nudged right so a level narrower than GRID_WIDTH stays centred.
func _origin_for(width: int) -> Vector2:
	return GRID_ORIGIN + Vector2((GRID_WIDTH - width) * 0.5 * BRICK_SIZE.x, 0.0)


func clear() -> void:
	for child in get_children():
		# Removed as well as freed, so the brick leaves its groups this frame
		# rather than at the end of it.
		remove_child(child)
		child.queue_free()


func _spawn_brick(type: Block.BlockType, origin: Vector2, column: int, row: int) -> void:
	var brick: Block = BRICK_SCENE.instantiate()
	brick.block_type = type # set before add_child, per the brick's setter contract
	brick.position = origin + Vector2(column, row) * BRICK_SIZE
	brick.broken.connect(_on_brick_broken)
	add_child(brick)


func _on_brick_broken() -> void:
	# The brick that just broke is already queued for deletion but still listed
	# in the group until the end of the frame, so filter those out.
	for brick in get_tree().get_nodes_in_group(Block.BREAKABLE_GROUP):
		if not brick.is_queued_for_deletion():
			return
	GameState.win_level()
