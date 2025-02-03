extends Node2D
class_name LaserGun

@export_category("mechanics")
@export var laser_width := 10
@export var laser_damage_tick := 1.0

@export_category("rendering")
@export var sfx : AudioStreamPlayer2D
@export var flipped = false
@export var laser_spawn_marker : Marker2D
@export var laser : PackedScene
@export var warning_laser_scene : PackedScene
@export var gun_sprite : Sprite2D
@export var gun_sprite_flipped : Sprite2D
var laser_1 : Line2D
var laser_2 : Line2D
var warning_laser : Line2D
var laser_spawn_point : Node2D
var _init_transform : Transform2D
var _damaged_entities = []

func _ready():
	if gun_sprite and gun_sprite_flipped:
		gun_sprite_flipped.visible = flipped
		gun_sprite.visible = not flipped
	if laser:
		laser_1 = laser.instantiate()
		add_child(laser_1)
		laser_2 = laser.instantiate()
		add_child(laser_2)
	if warning_laser_scene:
		warning_laser = warning_laser_scene.instantiate()
		add_child(warning_laser)
	if laser_spawn_marker:
		laser_spawn_point = laser_spawn_marker
	else:
		laser_spawn_point = self
	_init_transform = transform

func warning_shoot(dir:Vector2):
	if not warning_laser:
		return
	warning_laser.visible = true
	warning_laser.set_point_position(0, laser_spawn_point.global_position)
	warning_laser.set_point_position(1, laser_spawn_point.global_position + dir * 4000)

func shoot(dir:Vector2):
	if warning_laser:
		warning_laser.visible = false
	if sfx:
		if not sfx.playing:
			sfx.play()
	_damaged_entities.clear()
	var first_collision
	var second_collision
	var new_dir := Vector2()
	
	laser_1.visible = true
	
	first_collision = find_collision(laser_spawn_point.global_position, dir)
	if first_collision:
		new_dir = (-dir.project(first_collision["normal"])) + (dir - dir.project(first_collision["normal"]))
		second_collision = find_collision(first_collision["position"] - dir * 2.0, new_dir)
	
	if first_collision:
		laser_1.set_point_position(0, laser_spawn_point.global_position)
		laser_1.set_point_position(1, first_collision["position"])
		laser_2.visible = true
		if second_collision:
			laser_2.set_point_position(0, first_collision["position"])
			laser_2.set_point_position(1, second_collision["position"])
		else:
			laser_2.set_point_position(0, first_collision["position"])
			laser_2.set_point_position(1, first_collision["position"] + new_dir * 3000)
		deal_damage(laser_2.get_point_position(0), laser_2.get_point_position(1))
	else:
		laser_2.visible = false
		laser_1.set_point_position(0, laser_spawn_point.global_position)
		laser_1.set_point_position(1, laser_spawn_point.global_position + dir * 3000)
	deal_damage(laser_1.get_point_position(0), laser_1.get_point_position(1))
	for n in _damaged_entities:
		n.take_damage(laser_damage_tick)

func stop_shoot():
	if laser_1 and laser_2:
		laser_1.visible = false
		laser_2.visible = false
	if warning_laser:
		warning_laser.visible = false

func deal_damage(first_point : Vector2, second_point : Vector2):
	var dist = first_point.distance_to(second_point)
	var rot = (second_point - first_point).angle()
	var space_state = get_world_2d().direct_space_state
	var shape_query = PhysicsShapeQueryParameters2D.new()
	shape_query.shape = RectangleShape2D.new()
	shape_query.shape.set_size(Vector2(dist, laser_width))
	shape_query.transform = Transform2D(rot, (first_point + second_point)/2)
	shape_query.collide_with_areas = true
	shape_query.collide_with_bodies = false
	shape_query.collision_mask = (2**1 + 2**2)
	var result = space_state.intersect_shape(shape_query)
	for n in result:
		if n["collider"].has_method("take_damage") and not n["collider"] is BossHitbox:
			_damaged_entities.append(n["collider"])

func find_collision(from: Vector2, dir: Vector2):
	dir = dir.normalized()
	var space_state = get_world_2d().direct_space_state
	var ray_query = PhysicsRayQueryParameters2D.create(from, from + dir * 5000, 2**0)
	var result = space_state.intersect_ray(ray_query)
	if result:
		return result
	else:
		return null

func reset_transform():
	if sfx:
		sfx.stop()
	var transform_tween = create_tween()
	transform_tween.tween_property(self, "transform", _init_transform, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
