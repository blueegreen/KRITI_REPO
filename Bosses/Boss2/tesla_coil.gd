extends Node2D
class_name TeslaCoil

signal finished

enum state {BIG_ATTACK, NONE}
var _current_state = state.NONE
var _big_attack_radius := 32.0
var _player_ref : Player

@onready var electric_pulse_sprite = $electric_pulse_sprite
@onready var attack_spawn_point = $attack_spawn_point

@export_category("big_attack")
@export var damage_width := 20.0
@export var final_radius := 3000.0
@export var duration := 4.0
@export var big_damage := 3.0

@export_category("small_attack")
@export var small_attack_radius = 400.0
@export var small_damage := 2.0

var small_shock_scene = preload("res://Bosses/Boss2/tesla_small_shock.tscn")

func _ready():
	_player_ref = get_tree().get_first_node_in_group("player")

func _process(_delta):
	match _current_state:
		state.NONE:
			return
		state.BIG_ATTACK:
			deal_big_damage()
	
func deal_big_damage():
	var space_state = get_world_2d().direct_space_state
	var shape_query = PhysicsShapeQueryParameters2D.new()
	shape_query.shape = CircleShape2D.new()
	shape_query.transform.origin = attack_spawn_point.global_position
	shape_query.shape.radius = _big_attack_radius
	shape_query.collide_with_areas = true
	shape_query.collide_with_bodies = false
	shape_query.collision_mask = (2**1 + 2**2)
	var result = space_state.intersect_shape(shape_query)
	for n in result:
		if n["collider"].has_method("take_damage") and not n["collider"] is BossHitbox:
			var dist = attack_spawn_point.global_position.distance_to(n["collider"].global_position)
			if dist > _big_attack_radius - damage_width:
				n["collider"].take_damage(big_damage)

func big_attack():
	var end_attack = func():
		electric_pulse_sprite.visible = false
		electric_pulse_sprite.scale = Vector2(1, 1)
		_current_state = state.NONE
		finished.emit()
	
	if _current_state == state.BIG_ATTACK:
		return
	_current_state = state.BIG_ATTACK
	electric_pulse_sprite.visible = true
	electric_pulse_sprite.modulate = Color(1, 1, 1, 1)
	_big_attack_radius = 32.0
	
	var attack_tween = create_tween().set_parallel(true)
	attack_tween.tween_property(self, "_big_attack_radius", final_radius,duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	#attack_tween.tween_property(electric_pulse_sprite, "modulate", Color(1, 1, 1, 0.5),duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	attack_tween.tween_property(electric_pulse_sprite, "scale", Vector2(1, 1) * final_radius / 32.0,duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	attack_tween.set_parallel(false).tween_callback(end_attack)

func small_attack():
	var rand_pos = attack_spawn_point.global_position + Vector2(randf_range(-small_attack_radius, small_attack_radius), randf_range(-small_attack_radius, small_attack_radius))
	var new_shock = small_shock_scene.instantiate()
	new_shock.global_position = rand_pos
	new_shock.spawn_point = attack_spawn_point.global_position
	if _player_ref and randf_range(0, 1) < 0.3:
		new_shock.global_position = _player_ref.global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
	new_shock.damage = small_damage
	add_child(new_shock)
