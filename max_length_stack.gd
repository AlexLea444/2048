class_name MaxLengthStack extends Resource

var data = []
var max_length = 5

func _ready() -> void:
	return

func _process() -> void:
	return

func _set_max_length(new_max_length: int) -> void:
	while len(data) > new_max_length:
		data.pop_front()
	max_length = new_max_length

func _push(recent) -> void:
	data.push_back(recent)
	if len(data) > max_length:
		data.pop_front()

func _pop():
	return data.pop_back()

func _back():
	return data.back()
