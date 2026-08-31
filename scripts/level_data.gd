class_name LevelData

## Loads and validates the pre-baked levels produced by tools/level-workshop.
##
## A levels file is a JSON array of levels; each level is an array of
## equal-length strings, one per brick row, top row first. Nothing here assumes
## symmetry — hand-made levels are free to be asymmetric.

const LEVELS_PATH := "res://levels/levels.json"
const EMPTY_CELL := "."
const GOLD_CELL := "$"

const CHAR_TO_TYPE := {
	"R": Block.BlockType.RED,
	"O": Block.BlockType.ORANGE,
	"Y": Block.BlockType.YELLOW,
	"G": Block.BlockType.GREEN,
	"B": Block.BlockType.BLUE,
	"P": Block.BlockType.PURPLE,
	"S": Block.BlockType.STEEL,
	"$": Block.BlockType.GOLD,
}


static func load_levels(path: String = LEVELS_PATH) -> Array[PackedStringArray]:
	var levels: Array[PackedStringArray] = []

	if not FileAccess.file_exists(path):
		_fail("%s: levels file not found" % path)
		return levels

	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_ARRAY:
		_fail("%s: expected a JSON array of levels" % path)
		return levels

	var raw_levels: Array = parsed
	for index in raw_levels.size():
		var level := _validate(raw_levels[index], index, path)
		if not level.is_empty():
			levels.append(level)

	if levels.is_empty():
		_fail("%s: contains no playable levels" % path)
	return levels

static func _validate(value: Variant, index: int, path: String) -> PackedStringArray:
	if typeof(value) != TYPE_ARRAY or (value as Array).is_empty():
		_fail("%s: level %d is not a non-empty array of rows" % [path, index])
		return PackedStringArray()

	var rows := PackedStringArray()
	var raw_rows: Array = value
	var width := -1
	var breakable := 0

	for row in raw_rows.size():
		if typeof(raw_rows[row]) != TYPE_STRING:
			_fail("%s: level %d row %d is not a string" % [path, index, row])
			return PackedStringArray()

		var line: String = raw_rows[row]
		if width == -1:
			width = line.length()
			if width == 0:
				_fail("%s: level %d has an empty row" % [path, index])
				return PackedStringArray()
		elif line.length() != width:
			_fail("%s: level %d is ragged — row %d is %d wide, expected %d" % [
				path, index, row, line.length(), width,
			])
			return PackedStringArray()

		for column in line.length():
			var cell := line[column]
			if cell == EMPTY_CELL:
				continue
			if not CHAR_TO_TYPE.has(cell):
				_fail("%s: level %d has unknown character '%s' at row %d, column %d" % [
					path, index, cell, row, column,
				])
				return PackedStringArray()
			if cell != GOLD_CELL:
				breakable += 1

		rows.append(line)

	if breakable == 0:
		_fail("%s: level %d has no breakable bricks" % [path, index])
		return PackedStringArray()

	return rows


static func _fail(message: String) -> void:
	push_error(message)
	assert(false, message) # debug builds stop here; exported builds skip the level
