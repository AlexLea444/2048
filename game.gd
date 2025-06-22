extends Node2D

var high_score
var score_file = "user://scores.cfg"

var current_board
var other_boards = []

func _ready() -> void:
	$game_board.game_over.connect(Callable(self, "_on_game_over"))
	$game_board.game_score.connect(Callable(self, "_on_game_score"))
	$mode_select.item_selected.connect(Callable(self, "_on_mode_select_pressed"))
	current_board = $game_board
	_load_high_score()

func _on_mode_select_pressed(index: int) -> void:
	var selected_mode
	match index:
		0: selected_mode = "STANDARD"
		1: selected_mode = "NO4"
		_: selected_mode = "NONE"
	
	# Mode not changed
	if current_board.game_mode == selected_mode or selected_mode == "NONE":
		return
	
	# Board for mode already exists
	
	
	# New mode, create new board
	current_board._disable()
	other_boards.append(current_board)
	var scene = preload("res://game_board.tscn") as PackedScene
	current_board = scene.instantiate()
	current_board.game_mode = selected_mode
	current_board.game_over.connect(Callable(self, "_on_game_over"))
	current_board.game_score.connect(Callable(self, "_on_game_score"))
	add_child(current_board)
	_load_high_score()
	_on_game_score(0)

func _on_game_over() -> void:
	return

func _on_game_score(new_score: int) -> void:
	$score.text = "Score: " + str(new_score)
	
	if new_score > high_score:
		_update_high_score(new_score)

func _load_high_score() -> void:
	var config = ConfigFile.new()
	
	var err = config.load(score_file)
	if err != OK:
		config.set_value(current_board.game_mode, "high_score", 0)
		config.save(score_file)
		high_score = 0
		return

	high_score = config.get_value(current_board.game_mode, "high_score")
	if typeof(high_score) == TYPE_NIL:
		config.set_value(current_board.game_mode, "high_score", 0)
		config.save(score_file)
		high_score = 0
	$high_score.text = "High Score: " + str(high_score)

func _load_board(game_mode_to_load: String) -> bool:
	# Try in local (current session)
	for i in range(len(other_boards)):
		if other_boards[i].game_mode == game_mode_to_load:
			current_board._disable()
			other_boards.append(current_board)
			current_board = other_boards.pop_at(i)
			current_board._enable()
			_on_game_score(current_board.score)
			_load_high_score()
			return true
	
	# Try to load a save state
	var config = ConfigFile.new()
	
	var err = config.load(score_file)
	if err != OK:
		return false

	var loaded_board = config.get_value(game_mode_to_load, "save_state")
	if typeof(loaded_board) == TYPE_NIL:
		return false
	else:
		if game_mode_to_load == current_board.game_mode:
			current_board = loaded_board
		else:
			current_board._disable()
			other_boards.append(current_board)
			current_board = loaded_board

	current_board._enable()
	_on_game_score(current_board.score)
	_load_high_score()
	return false

func _update_high_score(new_score: int) -> void:
	if new_score <= high_score:
		return

	high_score = new_score
	$high_score.text = "High Score: " + str(high_score)
	
	var config = ConfigFile.new()
	
	var err = config.load(score_file)		
	if err != OK:
		return

	config.set_value(current_board.game_mode, "high_score", high_score)
	config.save(score_file)

func _notification(what: int) -> void:
	print(what)
	if what == NOTIFICATION_APPLICATION_PAUSED:
		print("HERE")
		var config = ConfigFile.new()
	
		var err = config.load(score_file)		
		if err != OK:
			return

		config.set_value(current_board.game_mode, "save_state", current_board)
		for i in range(len(other_boards)):
			config.set_value(other_boards[i].game_mode, "save_state", other_boards[i])
		config.save(score_file)
