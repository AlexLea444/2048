extends Node2D

func _ready() -> void:
	$game_board.game_over.connect(Callable(self, "_on_game_over"))

func _on_game_over() -> void:
	print("Game Over")
	$title.text = "2048 :("
