extends Node2D

enum DIR {NONE, LEFT, RIGHT, UP, DOWN}

var tile_grid = Array()
var prev_tile_grid = Array()

var swipe_start = null
var swipe_end = null
var swiping = false
const MINIMUM_DRAG = 50

# game logistics
var game_mode = "STANDARD"
var disabled = false

var score = 0
var prev_score = 0
signal game_over
signal game_score(new_score: int)

func _ready() -> void:
	$reset.pressed.connect(Callable(self, "_on_reset_pressed"))
	$go_back.pressed.connect(Callable(self, "_on_go_back_pressed"))
	_setup_grids()

func _on_reset_pressed() -> void:
	score = 0
	prev_score = 0
	emit_signal("game_score", score)
	_clear_grid(tile_grid)
	_clear_grid(prev_tile_grid)
	_add_new_tile()
	#_draw_tile_grid()

func _on_go_back_pressed() -> void:
	score = prev_score
	prev_score = 0
	emit_signal("game_score", score)
	_copy_grid(prev_tile_grid, tile_grid)
	_clear_grid(prev_tile_grid)
	_childify_grid(tile_grid)
	#_draw_tile_grid()

func _disable() -> void:
	hide()
	disabled = true

func _enable() -> void:
	show()
	disabled = false

func _copy_grid(source_grid: Array, dest_grid: Array) -> void:
	_clear_grid(dest_grid)
	for i in range(4):
		for j in range(4):
			if source_grid[i][j]:
				dest_grid[i][j] = _copy_tile(source_grid[i][j])

func _clear_grid(grid: Array) -> void:
	for i in range(4):
		for j in range(4):
			if grid[i][j]:
				_drop_from_grid(grid, i, j)

func _hide_grid(grid: Array) -> void:
	for i in range(4):
		for j in range(4):
			if grid[i][j]:
				grid[i][j].hide()

func _unhide_grid(grid: Array) -> void:
	for i in range(4):
		for j in range(4):
			if grid[i][j]:
				grid[i][j].show()

func _childify_grid(grid: Array) -> void:
	for i in range(4):
		for j in range(4):
			if grid[i][j]:
				add_child(grid[i][j])
				grid[i][j]._set_img()

func _drop_from_grid(grid:Array, i: int, j: int) -> void:
	if not grid[i][j].get_parent():
		grid[i][j].free()
	else:
		remove_child(grid[i][j])
	grid[i][j] = false	

func _copy_tile(tile: Node2D) -> Node2D:
	var scene = preload("res://tile.tscn") as PackedScene
	var instance = scene.instantiate()
	instance._set_log_val(tile._get_log_val())
	instance._set_pos(tile._get_row(), tile._get_col())
	#add_child(instance)
	return instance

func _setup_grids() -> void:
	score = 0
	prev_score = 0
	tile_grid = _new_grid()
	prev_tile_grid = _new_grid()
	_add_new_tile()
	#_draw_tile_grid()

func _new_grid() -> Array:
	var new_grid = Array()
	new_grid.resize(4)
	for i in range(4):
		new_grid[i] = Array()
		new_grid[i].resize(4)
		for j in range(4):
			new_grid[i][j] = false
	return new_grid

# Returns false if new tile cannot be spawned
func _add_new_tile() -> bool:
	var empties = _get_empties()
	if empties.is_empty():
		emit_signal("game_over")
		return false

	match game_mode:
		"STANDARD":
			var coords = empties.pick_random()
			var scene = preload("res://tile.tscn") as PackedScene
			tile_grid[coords[0]][coords[1]] = scene.instantiate()
			add_child(tile_grid[coords[0]][coords[1]])
			tile_grid[coords[0]][coords[1]]._set_pos(coords[0], coords[1])
			
			# 10% chance of getting a 4
			if randf_range(0,1) < 0.1:
				tile_grid[coords[0]][coords[1]]._set_log_val(2)
			return true
		"NO4":
			var coords = empties.pick_random()
			var scene = preload("res://tile.tscn") as PackedScene
			tile_grid[coords[0]][coords[1]] = scene.instantiate()
			tile_grid[coords[0]][coords[1]]._set_pos(coords[0], coords[1])
			add_child(tile_grid[coords[0]][coords[1]])
			return true
		_:
			return false

# Returns list of all empty locations in tile grid
func _get_empties() -> Array:
	var empties = Array()
	for i in range(4):
		for j in range(4):
			if not tile_grid[i][j]:
				empties.append([i, j])
	return empties

func _input(event: InputEvent) -> void:
	if disabled:
		return
	if event is InputEventScreenTouch:
		if event.pressed and not swiping:
			swipe_start = event.position
			swiping = true
		else:
			if swiping:
				swipe_end = event.position
				_handle_swipe(DIR.NONE)
			swipe_start = null
			swipe_end = null
			swiping = false

func _handle_swipe(swipe_dir) -> void:
	if swipe_dir == DIR.NONE and swiping:
		swipe_dir = _get_dir()
	
	var tmp_prev_tile_grid = _new_grid()
	var tmp_prev_score = score
	_copy_grid(tile_grid, tmp_prev_tile_grid)

	var moved = false
	match swipe_dir:
		DIR.NONE:
			return
		DIR.LEFT:
			moved = _swipe_left()
		DIR.RIGHT:
			moved = _swipe_right()
		DIR.UP:
			moved = _swipe_up()
		DIR.DOWN:
			moved = _swipe_down()
	
	if moved:
		_add_new_tile()
		_copy_grid(tmp_prev_tile_grid, prev_tile_grid)
		prev_score = tmp_prev_score
		emit_signal("game_score", score)
		#_draw_tile_grid()
	_clear_grid(tmp_prev_tile_grid)

# Deprecated (Wasn't working!!!)
func _will_move(swipe_dir: DIR) -> bool:
	var tmp = _new_grid()
	_copy_grid(tile_grid, tmp)
	
	var moved = false
	match swipe_dir:
		DIR.NONE:
			return false
		DIR.LEFT:
			moved = _swipe_left()
		DIR.RIGHT:
			moved = _swipe_right()
		DIR.UP:
			moved = _swipe_up()
		DIR.DOWN:
			moved = _swipe_down()
	
	_copy_grid(tmp, tile_grid)
	_clear_grid(tmp)
	return moved

func _get_dir() -> DIR:
	var x_diff = swipe_end.x - swipe_start.x
	var y_diff = swipe_end.y - swipe_start.y
	if abs(x_diff) > abs(y_diff):
		if abs(x_diff) < MINIMUM_DRAG:
			return DIR.NONE
		elif x_diff > 0:
			return DIR.RIGHT
		else:
			return DIR.LEFT
	else:
		if abs(y_diff) < MINIMUM_DRAG:
			return DIR.NONE
		elif y_diff > 0:
			return DIR.DOWN
		else:
			return DIR.UP

func _combine_tiles(absorber, absorbee) -> void:
	if absorber._get_log_val() != absorbee._get_log_val():
		return

	absorber._inc_log_val()
	score += pow(2, absorber._get_log_val())

func _swipe_left() -> bool:
	var moved = false
	for i in range(4):
		for j in range(4):
			if tile_grid[i][j]:
				for k in range(j + 1,4):
					if tile_grid[i][k]:
						if tile_grid[i][k]._get_log_val() == tile_grid[i][j]._get_log_val():
							_combine_tiles(tile_grid[i][j], tile_grid[i][k])
							_drop_from_grid(tile_grid, i, k)
							moved = true
						break
	for i in range(4):
		for j in range(4):
			if not tile_grid[i][j]:
				for k in range(j + 1,4):
					if tile_grid[i][k]:
						tile_grid[i][j] = tile_grid[i][k]
						tile_grid[i][j]._set_pos(i, j)
						tile_grid[i][k] = false
						moved = true
						break
	
	return moved
	
func _swipe_right() -> bool:
	var moved = false
	for i in range(4):
		for j in range(4):
			if tile_grid[i][3 - j]:
				for k in range(j + 1,4):
					if tile_grid[i][3 - k]:
						if tile_grid[i][3 - k]._get_log_val() == tile_grid[i][3 - j]._get_log_val():
							_combine_tiles(tile_grid[i][3 - j], tile_grid[i][3 - k])
							_drop_from_grid(tile_grid, i, 3-k)
							moved = true
						break
	for i in range(4):
		for j in range(4):
			if not tile_grid[i][3 - j]:
				for k in range(j + 1,4):
					if tile_grid[i][3 - k]:
						tile_grid[i][3 - j] = tile_grid[i][3 - k]
						tile_grid[i][3 - j]._set_pos(i, 3 - j)
						tile_grid[i][3 - k] = false
						moved = true
						break
	
	return moved

func _swipe_up() -> bool:
	var moved = false
	for j in range(4):
		for i in range(4):
			if tile_grid[i][j]:
				for k in range(i + 1,4):
					if tile_grid[k][j]:
						if tile_grid[k][j]._get_log_val() == tile_grid[i][j]._get_log_val():
							_combine_tiles(tile_grid[i][j], tile_grid[k][j])
							_drop_from_grid(tile_grid, k, j)
							moved = true
						break
	for j in range(4):
		for i in range(4):
			if not tile_grid[i][j]:
				for k in range(i + 1,4):
					if tile_grid[k][j]:
						tile_grid[i][j] = tile_grid[k][j]
						tile_grid[i][j]._set_pos(i, j)
						tile_grid[k][j] = false
						moved = true
						break
	
	return moved
	
func _swipe_down() -> bool:
	var moved = false
	for j in range(4):
		for i in range(4):
			if tile_grid[3 - i][j]:
				for k in range(i + 1,4):
					if tile_grid[3 - k][j]:
						if tile_grid[3 - k][j]._get_log_val() == tile_grid[3 - i][j]._get_log_val():
							_combine_tiles(tile_grid[3 - i][j], tile_grid[3 - k][j])
							_drop_from_grid(tile_grid, 3-k, j)
							moved = true
						break
	for j in range(4):
		for i in range(4):
			if not tile_grid[3 - i][j]:
				for k in range(i + 1,4):
					if tile_grid[3 - k][j]:
						tile_grid[3 - i][j] = tile_grid[3 - k][j]
						tile_grid[3 - i][j]._set_pos(3 - i, j)
						tile_grid[3 - k][j] = false
						moved = true
						break
	
	return moved

# Deprecated
func _closest_in_dir(i: int, j: int, dir: DIR) -> Array:
	var idx = -1
	if dir == DIR.LEFT or dir == DIR.RIGHT:
		idx = i
	else:
		idx = j
		
	for k in range(idx, 4):
		match dir:
			DIR.LEFT: j = 3 - k
			DIR.RIGHT: j = k
			DIR.UP: i = 3 - k
			DIR.DOWN: i = k
			_: return []
		if tile_grid[i][j]:
			return [i, j]
			
	return []

func _draw_tile_grid() -> void:
	for i in range(4):
		for j in range(4):
			if tile_grid[i][j]:
				tile_grid[i][j].set_position(Vector2(20 + 16 * (j + 1) + 150 * j, 400 + 16 * (i + 1) + 150 * i))
