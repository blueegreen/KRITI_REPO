extends Node2D
class_name WhackaMole

signal finished

enum state {IDLE, AIMING, SMASH}
var _current_state = state.IDLE

@export var damage_radius := 160.0
@export var height_speed := 200.0

@onready var idle_sprite = $idle_sprite
@onready var aiming_sprite = $aiming_sprite
@onready var smash_sprite = $smash_sprite
@onready var cross_hair = $cross_hair
@onready var cross_hair_sprite = $cross_hair/cross_hair_sprite
@onready var mole_repulsor = $mole_repulsor
@export var sfx : AudioStreamPlayer2D

var _aiming_time := 0.0
var _vel := Vector2()
var _init_transform : Transform2D


func _ready():
	_init_transform = transform

func _process(delta):
	cross_hair_sprite.rotation += delta * 2.0
	match _current_state:
		state.IDLE:
			idle_sprite.visible = true
			aiming_sprite.visible = false
			smash_sprite.visible = false
			cross_hair.visible = false
		state.AIMING:
			idle_sprite.visible = false
			aiming_sprite.visible = true
			smash_sprite.visible = false
			cross_hair.visible = true
		state.SMASH:
			idle_sprite.visible = false
			aiming_sprite.visible = false
			smash_sprite.visible = true
			cross_hair.visible = false
	#if _current_state != state.SMASH:
		#aim_at(get_global_mouse_position())
	#if Input.is_action_just_pressed("shoot"):
		#smash()

func aim_at(pos: Vector2):
	_current_state = state.AIMING
	var delta = get_process_delta_time()
	global_rotation = move_toward(global_rotation, 0, delta * 5)
	_aiming_time += delta
	var height = Vector2(0, _aiming_time * height_speed)
	var current_pos = global_position + height
	var dir = current_pos.direction_to(pos)
	var dist = current_pos.distance_to(pos)
	var target_vel = (dir * dist * 5.0).limit_length(450.0)
	_vel = _vel.lerp(target_vel, 1 - exp(-3.0 * delta))
	global_position += _vel * delta
	cross_hair.global_position = global_position + height
	
func smash():
	if sfx:
		sfx.play()
	_aiming_time = 0
	var pos = cross_hair.global_position
	_current_state = state.SMASH
	var tween = create_tween()
	tween.tween_property(self, "global_position", pos, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(deal_damage)
	await get_tree().create_timer(0.8).timeout
	mole_repulsor.disabled = true
	finished.emit()
	_current_state = state.IDLE

func deal_damage():
	mole_repulsor.disabled = false
	var space_state = get_world_2d().direct_space_state
	var shape_query = PhysicsShapeQueryParameters2D.new()
	shape_query.shape = CircleShape2D.new()
	shape_query.shape.radius = damage_radius
	shape_query.transform = global_transform
	shape_query.collide_with_areas = true
	shape_query.collide_with_bodies = false
	shape_query.collision_mask = (2**1 + 2**2)
	var result = space_state.intersect_shape(shape_query)
	for n in result:
		if n["collider"].has_method("take_damage"):
			n["collider"].take_damage(3.0, self)

func reset_transform():
	var tween = create_tween()
	tween.tween_property(self, "transform", _init_transform, 0.5).set_trans(Tween.TRANS_QUAD)
