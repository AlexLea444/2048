extends Panel

enum DIR {NONE, LEFT, RIGHT, UP, DOWN}
enum MODE {STANDARD, EASY, HARD}

var tile_grid = Array()

var swipe_start = null
var swipe_end = null
var swiping = false
const MINIMUM_DRAG = 50

var game_mode = MODE.STANDARD

signal game_over

func _ready() -> void:
	tile_grid.resize(4)
	for i in range(4):
		tile_grid[i] = Array()
		tile_grid[i].resize(4)
		for j in range(4):
			tile_grid[i][j] = false
	_spawn_new_tile()

# Returns false if new tile cannot be spawned
func _spawn_new_tile() -> bool:
	var empties = _get_empties()
	if empties.is_empty():
		emit_signal("game_over")
		return false

	match game_mode:
		MODE.STANDARD:
			var coords = empties.pick_random()
			var scene = preload("res://tile.tscn") as PackedScene
			tile_grid[coords[0]][coords[1]] = scene.instantiate()
			add_child(tile_grid[coords[0]][coords[1]])
			_draw_tile_grid()
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
		_spawn_new_tile()

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

func _swipe_left() -> bool:
	var moved = false
	for i in range(4):
		for j in range(4):
			if not tile_grid[i][j]:
				for k in range(j,4):
					if tile_grid[i][k]:
						tile_grid[i][j] = tile_grid[i][k]
						tile_grid[i][k] = false
						moved = true
						break
	
	return moved
	
func _swipe_right() -> bool:
	var moved = false
	for i in range(4):
		for j in range(4):
			if not tile_grid[i][3 - j]:
				for k in range(j,4):
					if tile_grid[i][3 - k]:
						tile_grid[i][3 - j] = tile_grid[i][3 - k]
						tile_grid[i][3 - k] = false
						moved = true
						break
	
	return moved

func _swipe_up() -> bool:
	var moved = false
	for j in range(4):
		for i in range(4):
			if not tile_grid[i][j]:
				for k in range(i,4):
					if tile_grid[k][j]:
						tile_grid[i][j] = tile_grid[k][j]
						tile_grid[k][j] = false
						moved = true
						break
	
	return moved
	
func _swipe_down() -> bool:
	var moved = false
	for j in range(4):
		for i in range(4):
			if not tile_grid[3 - i][j]:
				for k in range(i,4):
					if tile_grid[3 - k][j]:
						tile_grid[3 - i][j] = tile_grid[3 - k][j]
						tile_grid[3 - k][j] = false
						moved = true
						break
	
	return moved

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
				tile_grid[i][j].set_position(Vector2(16 * (j + 1) + 150 * j, 16 * (i + 1) + 150 * i))
