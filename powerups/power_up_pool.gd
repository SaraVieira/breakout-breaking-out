class_name PowerUpPool extends Resource


@export var all: Array[PowerUpData] = []


func pick(count: int) -> Array[PowerUpData]:
	var shuffled := all.duplicate()
	shuffled.shuffle()
	return shuffled.slice(0, count)
