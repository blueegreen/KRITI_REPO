extends Area2D

@export var max_repulsion_strength = 4000;
@export var min_repulsion_strength = 500;
@export var radius := 160
@export var disabled = false
var _repulsion_strength = 0;
var _speed := 0.0
var _prev_pos := Vector2()

func _ready():
	var shape = CircleShape2D.new()
	shape.set_radius(radius)
	$CollisionShape2D.set_shape(shape)
	_prev_pos = global_position

func _process(delta):
	if disabled:
		collision_mask = 0
		return
	else:
		collision_mask = 2**1
	_speed = (global_position.distance_squared_to(_prev_pos)) / delta
	_prev_pos = global_position
	_repulsion_strength = clamp(max(_speed - 100, 0) * 0.003 * max_repulsion_strength, min_repulsion_strength, max_repulsion_strength)
	
	var areas = get_overlapping_areas()
	for area in areas:
		if area.is_in_group("mole"):
			var force = global_position.direction_to(area.global_position) * _repulsion_strength
			area.set_velocity(area.get_velocity() + force * delta)
	
