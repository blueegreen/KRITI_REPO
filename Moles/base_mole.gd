extends Area2D
class_name Mole

enum states {DEFAULT, STUN}
var current_state = states.DEFAULT

@onready var navigation_agent = $NavigationAgent2D

@export var skin : MoleSkin
@export var behaviour : Script
@export var gun : Gun
var movement_speed := 250.0
var max_speed := 250.0
var navigation_target : Node2D = null
var time_nav_update := 2.0
var min_distance_to_player := 50.
var max_hp := 1.0
var default_affiliation := "enemy"
var shooting := false
var shooting_target : Node2D

var _self_steering_direction : Vector2
var _current_direction := Vector2()
var _current_time := 1.0
var _velocity := Vector2()
var _hp := 1.0

func get_velocity():
	return _velocity

func get_direction():
	return _current_direction

func set_velocity(vel):
	_velocity = vel.limit_length(max_speed)

func get_hp():
	return _hp

func set_hp(value):
	_hp = clampf(value, 0.0, max_hp)

func _ready():
	navigation_target = get_tree().get_first_node_in_group("player")
	navigation_agent.target_desired_distance = min_distance_to_player
	_self_steering_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	if behaviour:
		if behaviour.has_method("set_behaviour"):
			behaviour.set_behaviour(self)
	set_hp(max_hp)
	set_affiliation(default_affiliation)

func _process(delta):
	_current_direction = _velocity.normalized()
	self_steer(delta)
	match(current_state):
		states.DEFAULT:
			update_nav_pos(delta)
			if skin:
				skin.orient(global_position.direction_to(navigation_target.global_position))
				if _velocity.length() > movement_speed/1.2:
					skin.run()
				else:
					skin.idle()
			if gun and shooting and shooting_target:
				gun.look_at(shooting_target.global_position)
				gun.shoot(shooting_target.global_position)
			position += _velocity * delta
		states.STUN:
			return

func self_steer(delta):
	var dir = get_direction()
	if dir.is_equal_approx(_self_steering_direction):
		_self_steering_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	else:
		var target_dir = dir.move_toward(_self_steering_direction, delta * 5)
		_velocity = _velocity.move_toward(target_dir * movement_speed / 2.0, delta * 20.0)

func update_nav_pos(delta):
	if not navigation_target:
		return
	_current_time += delta
	if _current_time > time_nav_update and global_position.distance_to(navigation_target.global_position) > min_distance_to_player:
		navigation_agent.target_position = navigation_target.global_position
		_current_time = randf_range(-time_nav_update/2.0, time_nav_update/2.0)

func get_affiliation():
	if is_in_group("friendly"):
		return "friendly"
	elif is_in_group("enemy"):
		return "enemy"

func set_affiliation(value: String):
	if value == "enemy" or value == "friendly":
		remove_from_group("enemy")
		remove_from_group("friendly")
		add_to_group(value)
	else:
		print("invalid_affiliation")

func take_damage(dmg, source = null):
	set_hp(_hp - dmg)
	if skin:
		skin.hurt()
	if source is Node2D:
		set_velocity(source.global_position.direction_to(global_position) * 300)
	if is_equal_approx(_hp, 0):
		queue_free()
