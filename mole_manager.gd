extends Node2D
class_name MoleManager

var _player_ref : Node2D

var space_partition_grid : Array
var debug_text : Array
var grid_size : Vector2

@export_category("debug")
@export var debug_cell_text_visible := true

@export_category("space partitioning")
@export var world_origin : Vector2
@export var cell_size := 100.0
@export var world_size := Vector2(3000.0, 2000.0)
@export var calculation_distance_from_player : float = 500

@export_category("mole flocking behaviour")
@export var cohesion_weight := 0.5
@export var alignment_weight := 0.5
@export var seperation_weight := 1.0
@export var max_radius_seperation_moles := 80.0
@export var calculation_interval := 0.05
@export var mole_acceleration := 5.0

var _time := 0.0

@export var navigation_weight := 0.6
@export var boid_weight := 0.4

var _mole_count = 0

func _ready():
	_player_ref = get_tree().get_first_node_in_group("player")
	calculation_distance_from_player /= cell_size
	grid_size = Vector2(int(world_size.x/cell_size), int(world_size.y/cell_size))
	#world_origin = Vector2(-world_size.x/2, -world_size.y/2)
	space_partition_grid = []
	setup_new_grid()

func _process(delta):
	#_time += delta
	#if _time < calculation_interval:
		#return
	#else:
		#_time = 0
		
	_mole_count = 0
	verify_moles()
	for space_index in range(space_partition_grid.size()):
		
		if debug_text[space_index] and debug_cell_text_visible:
			debug_text[space_index].text = str(space_partition_grid[space_index].size())
		_mole_count += space_partition_grid[space_index].size()
		
		var neighbouring_moles_of_cell := []
		var common_cell_forces := {}
		var avoidance_force := Vector2.ZERO
		var calculate_this_cell = should_calculate(space_index)
		if calculate_this_cell:
			neighbouring_moles_of_cell = find_neighbouring_moles(space_index)
			common_cell_forces = calculate_common_cell_forces(neighbouring_moles_of_cell)
		avoidance_force = calculate_cell_avoidance_force(space_index)
		
		for mole_index in range(space_partition_grid[space_index].size() - 1, -1, -1):
			if calculate_this_cell:
				calculate_forces(space_partition_grid[space_index][mole_index], common_cell_forces, neighbouring_moles_of_cell, delta)
			add_avoidance(space_partition_grid[space_index][mole_index], avoidance_force, delta)
	
func add_avoidance(mole, avoidance_force:Vector2, delta):
	if avoidance_force.is_zero_approx():
		return
	var target_avoidance_velocity = avoidance_force * mole.movement_speed
	mole.set_velocity(mole.get_velocity().lerp(target_avoidance_velocity, 1 - exp(-mole_acceleration * delta)))
	
func verify_moles():
	for space_index in range(space_partition_grid.size()):
		for mole_index in range(space_partition_grid[space_index].size() - 1, -1, -1):
			if space_partition_grid[space_index][mole_index] == null:
				space_partition_grid[space_index].pop_at(mole_index)
			else:
				recalculate_grid_for_mole(space_index, mole_index)

func should_calculate(space_index):
	if not _player_ref:
		return false
	var player_space_index = Vector2(int((_player_ref.global_position.x - world_origin.x)/cell_size), int((_player_ref.global_position.y - world_origin.y)/cell_size))
	var space_index_y = int(space_index / grid_size.x)
	var space_index_x = int(space_index - space_index_y * grid_size.x)
	if abs(player_space_index.x - space_index_x) > calculation_distance_from_player\
	or abs(player_space_index.y - space_index_y) > calculation_distance_from_player:
		return false
	return true

func recalculate_grid_for_mole(space_index, mole_index):
	var old_index = space_index
	var new_index = find_index(space_partition_grid[space_index][mole_index])
	if old_index != new_index:
		var mole = space_partition_grid[space_index].pop_at(mole_index)
		if new_index < space_partition_grid.size():
			space_partition_grid[new_index].push_back(mole)

func calculate_cell_avoidance_force(space_index):
	var avoid = func():
		var space_index_y = int(space_index / grid_size.x)
		var space_index_x = int(space_index - space_index_y * grid_size.x)
		var force_dir := Vector2.ZERO
		if space_index_x == 0:
			force_dir.x = 1
		elif space_index_x == grid_size.x - 1:
			force_dir.x = -1
		if space_index_y == 0:
			force_dir.y = 1
		elif space_index_y == grid_size.y - 1:
			force_dir.y = -1
		return force_dir
		
	return avoid.call()

func calculate_common_cell_forces(neighbouring_moles):
	var cohesion_centre := global_position
	var alignment_dir := Vector2.ZERO

	var mole_count = 0
	for mole in neighbouring_moles:
		mole_count += 1
		cohesion_centre += mole.global_position
		alignment_dir += mole.get_direction()

	if mole_count > 0:
		cohesion_centre /= mole_count
		alignment_dir /= mole_count
	
	return {"cohesion_centre": cohesion_centre, "alignment_dir": alignment_dir}

func calculate_forces(mole, cell_forces, neighbouring_moles, delta):
	
	var boid_force := Vector2.ZERO
	var navigation_force := Vector2.ZERO
	
	var cohesion_centre : Vector2 = cell_forces["cohesion_centre"]
	var alignment_dir : Vector2 = cell_forces["alignment_dir"]
	var seperation_force := Vector2.ZERO

	for other_mole in neighbouring_moles:
		if mole == other_mole:
			continue
		var dist = mole.global_position.distance_squared_to(other_mole.global_position)
		if dist < pow(max_radius_seperation_moles, 2):
			seperation_force += other_mole.global_position.direction_to(mole.global_position)

	seperation_force = seperation_force.normalized()
	boid_force = (mole.global_position.direction_to(cohesion_centre) * cohesion_weight \
	+ alignment_dir * alignment_weight \
	+ seperation_force * seperation_weight).normalized() * boid_weight
	
	if not mole.navigation_agent.is_navigation_finished():
		navigation_force = mole.global_position.direction_to(mole.navigation_agent.get_next_path_position()) * navigation_weight
	
	var target_velocity = (boid_force + navigation_force).normalized() * mole.movement_speed

	mole.set_velocity(mole.get_velocity().lerp(target_velocity, 1 - exp(-mole_acceleration * delta)))

func setup_new_grid():
	space_partition_grid.clear()
	
	#setup debug
	for n in grid_size.x * grid_size.y:
		var new_label = Label.new()
		var new_node = Node2D.new()
		new_node.top_level = true
		new_node.position = Vector2(world_origin.x + cell_size*(int(n)%int(grid_size.x)), world_origin.y + cell_size*int((n/grid_size.x)))
		add_child(new_node)
		new_node.add_child(new_label)
		debug_text.push_back(new_label)
	
	#setup space_partition
	for n in grid_size.x * grid_size.y:
		space_partition_grid.append([])
	for child in get_children():
		if child.is_in_group("mole"):
			space_partition_grid[find_index(child)].append(child)

func find_neighbouring_moles(index):
	var neighbouring_moles = []
		
		# Check bounds and collect elements from the current cell and neighbors
	if index >= 0 and index < space_partition_grid.size():
		neighbouring_moles += space_partition_grid[index]
		
	if index + 1 >= 0 and index + 1 < space_partition_grid.size():
		neighbouring_moles += space_partition_grid[index + 1]
		
	if index - 1 >= 0 and index - 1 < space_partition_grid.size():
		neighbouring_moles += space_partition_grid[index - 1]
		
	if index - grid_size.x >= 0 and index - grid_size.x < space_partition_grid.size():
		neighbouring_moles += space_partition_grid[index - grid_size.x]
		
	if index + grid_size.x >= 0 and index + grid_size.x < space_partition_grid.size():
		neighbouring_moles += space_partition_grid[index + grid_size.x]
		
	return neighbouring_moles

func find_index(mole) -> int:
	var x_index = int((mole.position.x - world_origin.x) / cell_size)
	var y_index = int((mole.position.y - world_origin.y) / cell_size)

	# Clamp indices
	x_index = clamp(x_index, 0, grid_size.x - 1)
	y_index = clamp(y_index, 0, grid_size.y - 1)
	
	return x_index + y_index * grid_size.x

func add_mole(new_mole):
	add_child(new_mole)
	space_partition_grid[find_index(new_mole)].push_back(new_mole)
