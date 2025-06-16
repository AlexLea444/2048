extends Node2D

var high_score
var score_file = "user://scores.cfg"

func _ready() -> void:
	$game_board.game_over.connect(Callable(self, "_on_game_over"))
	$game_board.game_score.connect(Callable(self, "_on_game_score"))
	_load_high_score()

func _on_game_over() -> void:
	$game_title.text = "2048"

func _on_game_score(new_score: int) -> void:
	$score.text = "Score: " + str(new_score)
	
	if new_score > high_score:
		_update_high_score(new_score)

func _load_high_score() -> void:
	var config = ConfigFile.new()
	
	var err = config.load(score_file)
	if err != OK:
		config.set_value("game", "high_score", 0)
		config.save(score_file)
		high_score = 0
		return

	high_score = config.get_value("game", "high_score")
	$high_score.text = "High Score: " + str(high_score)

func _update_high_score(new_score: int) -> void:
	if new_score <= high_score:
		return

	high_score = new_score
	$high_score.text = "High Score: " + str(high_score)
	
	var config = ConfigFile.new()
	
	var err = config.load(score_file)		
	if err != OK:
		return

	config.set_value("game", "high_score", high_score)
	config.save(score_file)
