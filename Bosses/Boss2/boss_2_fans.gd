extends Node2D
class_name Boss2Fan

@export_category("sprite management")
@export var fan_sprite : Node2D
@export var sprite_parent : Node2D

@onready var pushing_area = $pushing_area
@onready var damage_area = $damage_area

@export_category("fan mechanics")
@export var max_speed := 14.0
@export var player_push_strength := 60000.
@export var mole_push_strength := 85000.
@export var damage := 2.0

var _rotation_speed := 0.0
var rotate_tween : Tween = null
var _init_transform : Transform2D

func _ready():
	_init_transform = transform
	start_fan()

func _process(delta):
	#sprite_parent.skew = deg_to_rad(rotation * 40.0)
	fan_sprite.rotation += _rotation_speed * delta
	if _rotation_speed > max_speed / 2.0:
		deal_damage()
	wind_push(delta)

func start_fan():
	if rotate_tween:
		rotate_tween.kill()
	rotate_tween = create_tween()
	rotate_tween.tween_property(self, "_rotation_speed", max_speed, 4.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

func stop_fan():
	if rotate_tween:
		rotate_tween.kill()
	rotate_tween = create_tween()
	rotate_tween.tween_property(self, "_rotation_speed", 0.0, 4.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func wind_push(delta):
	var wind_dir = Vector2.DOWN.rotated(rotation)
	var areas = pushing_area.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("mole"):
			var force = wind_dir * mole_push_strength * _rotation_speed / (area.global_position - global_position).project(wind_dir).length()
			area.set_velocity(area.get_velocity() + force * delta)
	var bodies = pushing_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			var force = wind_dir * player_push_strength * _rotation_speed / (body.global_position - global_position).project(wind_dir).length()
			body.velocity += force * delta
		elif body is RigidBody2D:
			var force = 5 * wind_dir * player_push_strength * _rotation_speed / (body.global_position - global_position).project(wind_dir).length()
			body.apply_central_force(force * delta)

func reset_transform():
	var tween = create_tween()
	tween.tween_property(self, "transform", _init_transform, 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

func deal_damage():
	for area in damage_area.get_overlapping_areas():
		if area.has_method("take_damage") and not area is BossHitbox:
			area.take_damage(damage, self)
