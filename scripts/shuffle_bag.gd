class_name ShuffleBag extends RefCounted


var _size: int
var _order: Array[int] = []


func _init(size: int) -> void:
	_size = maxi(size, 0)


func index_at(slot: int) -> int:
	if _size == 0:
		return -1

	var wanted := maxi(slot, 0)
	while _order.size() <= wanted:
		_refill()
	return _order[wanted]


func _refill() -> void:
	var deal: Array[int] = []
	for index in _size:
		deal.append(index)
	deal.shuffle()

	var previous := _order[-1] if not _order.is_empty() else -1
	if deal.size() > 1 and deal[0] == previous:
		var swap := randi_range(1, deal.size() - 1)
		deal[0] = deal[swap]
		deal[swap] = previous

	_order.append_array(deal)
