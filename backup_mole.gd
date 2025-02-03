extends Node2D
#
@onready var navigation_agent = $NavigationAgent2D
#
@export var movement_speed := 250.0
@export var navigation_target : Node2D = null
@export var time_nav_update := 2.0
@export var max_distance_to_player := 50.
#@export var max_radius_detect_moles := 150.
#
#var _player_ref : Node2D
var _current_time := 1.0
var _velocity := Vector2()

func get_velocity():
	return _velocity

func get_direction():
	return _velocity.normalized()

func set_velocity(vel):
	_velocity = vel
#
func _ready():
	navigation_target = get_tree().get_first_node_in_group("player")
	navigation_agent.target_desired_distance = max_distance_to_player
	add_to_group("enemy")
#
func _process(delta):
	update_nav_pos(delta)
	#movement_logic(delta)
	#pass
	#
#
func update_nav_pos(delta):
	if not navigation_target:
		return
	_current_time += delta
	if _current_time > time_nav_update and global_position.distance_to(navigation_target.global_position) > max_distance_to_player:
		navigation_agent.target_position = navigation_target.global_position
		_current_time = randf_range(-time_nav_update/2.0, time_nav_update/2.0)
#
#func movement_logic(delta):
	#var boid_force := Vector2(0, 0)
	#var collision_avoidance_force := Vector2(0, 0)
	#var navigation_force := Vector2.ZERO
	#
	#var cohesion_centre := global_position
	#var alignment_dir := Vector2.ZERO
	#var seperation_force := Vector2.ZERO
	#var max_radius_seperation_moles := 100.
	#
	#var cohesion_weight := 0.5
	#var alignment_weight := 0.5
	#var seperation_weight := 1.
	#
	#var navigation_weight := 0.6
	#var boid_weight := 0.4
	#var collision_avoidance_weight := 1.0
	#
	#var collision_count = 0
	#
	#var space_query = PhysicsShapeQueryParameters2D.new()
	#space_query.collision_mask = 2**0 + 2**3
	#space_query.transform = global_transform
	#space_query.shape = CircleShape2D.new()
	#space_query.shape.radius = max_radius_detect_moles
	#var nearby_obj = areas_bodies_from_space_query(space_query)
	#var areas = nearby_obj["areas"]
	#var bodies = nearby_obj["bodies"]
	#
	#for body in bodies:
		##var dist = body.global_position.distance_squared_to(global_position)
		#var dist_normal = dist_normal_to_obj(body)
		#collision_count += 1
		#collision_avoidance_force += dist_normal["normal"] * 300 / dist_normal["distance"]
#
	#if collision_count > 0:
		#collision_avoidance_force /= collision_count
		#collision_avoidance_force *= collision_avoidance_weight
#
	#var mole_count := 0
	#for area in get_tree().get_nodes_in_group("mole"):
		#if area.is_in_group("mole") and global_position.distance_squared_to(area.global_position) < pow(max_radius_detect_moles, 2):
			#mole_count += 1
			#cohesion_centre += area.global_position
			#alignment_dir += area.get_direction()
			#var dist = global_position.distance_squared_to(area.global_position)
			#if dist < pow(max_radius_seperation_moles, 2):
				#seperation_force += area.global_position.direction_to(global_position)
#
	#if mole_count > 0:
		#cohesion_centre /= mole_count
		#alignment_dir /= mole_count
		#seperation_force = seperation_force.normalized()
		#boid_force = (global_position.direction_to(cohesion_centre) * cohesion_weight \
		#+ alignment_dir * alignment_weight \
		#+ seperation_force * seperation_weight).normalized() * boid_weight
	#
	#
	#if not navigation_agent.is_navigation_finished():
		#navigation_force = global_position.direction_to(navigation_agent.get_next_path_position()) * navigation_weight
		#
	#var target_velocity = (boid_force + navigation_force).normalized() * movement_speed
	#
	#_velocity = _velocity.lerp(target_velocity, 1 - exp(-10 * delta))
	#_velocity = (_velocity + collision_avoidance_force * movement_speed).limit_length(movement_speed * 2.0)
	##_velocity = _velocity.lerp((_velocity + collision_avoidance_force + boid_force + navigation_force + seperation_force * movement_speed).limit_length(movement_speed), 1 - exp(-20 * delta))
	##_velocity = global_position.direction_to(navigation_agent.get_next_path_position()) * movement_speed
	#position += _velocity * delta
#
#func areas_bodies_from_space_query(query) -> Dictionary:
	#var state = get_world_2d().direct_space_state
	#var areas = []
	#var bodies = []
	#var result = state.intersect_shape(query)
	#for n in result:
		#if n["collider"] is RigidBody2D or n["collider"] is StaticBody2D:
			#bodies.append(n["collider"])
		#elif n["collider"] is Area2D:
			#areas.append(n["collider"])
	#return {"areas": areas, "bodies": bodies}
#
#func dist_normal_to_obj(obj):
	#var state = get_world_2d().direct_space_state
	#var ray_query
	#if obj is RigidBody2D:
		#ray_query = PhysicsRayQueryParameters2D.create(global_position, obj.global_position, 8)
	#elif obj is StaticBody2D:
		#ray_query = PhysicsRayQueryParameters2D.create(global_position, global_position + get_direction() * 50, 8)
	#ray_query.collision_mask = 2**0 + 2**3
	#var result = state.intersect_ray(ray_query)
	#if result:
		#return {"distance": result["position"].distance_squared_to(global_position), "normal": result["normal"]}
	#else:
		#return {"distance": INF, "normal": Vector2.ZERO}
