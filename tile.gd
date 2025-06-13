extends Node2D

var log_val = 1

func _ready() -> void:
	$Panel/Sprite2D.texture = preload("res://tiles/tile_1.png")

func _inc_log_val() -> void:
	log_val = log_val + 1
	_set_img()

func _set_img() -> void:
	match log_val:
		1: $Panel/Sprite2D.texture = preload("res://tiles/tile_1.png")
		2: $Panel/Sprite2D.texture = preload("res://tiles/tile_2.png")
		3: $Panel/Sprite2D.texture = preload("res://tiles/tile_3.png")
		4: $Panel/Sprite2D.texture = preload("res://tiles/tile_4.png")
		5: $Panel/Sprite2D.texture = preload("res://tiles/tile_5.png")
		6: $Panel/Sprite2D.texture = preload("res://tiles/tile_6.png")
		7: $Panel/Sprite2D.texture = preload("res://tiles/tile_7.png")
		8: $Panel/Sprite2D.texture = preload("res://tiles/tile_8.png")
		9: $Panel/Sprite2D.texture = preload("res://tiles/tile_9.png")
		10: $Panel/Sprite2D.texture = preload("res://tiles/tile_10.png")
		11: $Panel/Sprite2D.texture = preload("res://tiles/tile_11.png")
		12: $Panel/Sprite2D.texture = preload("res://tiles/tile_12.png")
		13: $Panel/Sprite2D.texture = preload("res://tiles/tile_13.png")
		14: $Panel/Sprite2D.texture = preload("res://tiles/tile_14.png")
		15: $Panel/Sprite2D.texture = preload("res://tiles/tile_15.png")
		16: $Panel/Sprite2D.texture = preload("res://tiles/tile_16.png")
		17: $Panel/Sprite2D.texture = preload("res://tiles/tile_17.png")
		_: 
			$Panel/Sprite2D.texture = preload("res://tiles/tile_0.png")
	
func _get_log_val() -> int:
	return log_val

func _set_log_val(new_val: int) -> void:
	log_val = new_val
	_set_img()
