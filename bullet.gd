extends Area2D
class_name Bullet

enum Type {FRIENDLY, ENEMY, ALL}

@export var speed : float = 400.0
@export var max_life : float = 2.0
@export var area_attack_radius := 32.0
@export var hit_sfx : AudioStreamPlayer2D
@export var hit_particles : GPUParticles2D
@onready var _life = max_life

var affiliation : String = "friendly"
var damage := 1.0
var dir := Vector2.ZERO
var piercing := 0.0
var area_attack := false

func _ready():
	body_entered.connect(_destroy_bullet)
	area_entered.connect(_deal_damage)
	top_level = true

func _physics_process(delta):
	position += dir * speed * delta 
	_life -= delta
	if _life < 0.0:
		_destroy_bullet()

func _deal_damage(area):
	if area.has_method("take_damage") and area.has_method("get_affiliation"):
		var area_affiliation = area.get_affiliation()
		if area_affiliation == affiliation:
			return
		area.take_damage(damage, self)
		if piercing <= 0:
			if area_attack:
				_deal_damage_in_area()
			_destroy_bullet()
		else:
			piercing -= 1;

func _deal_damage_in_area():
	var space_state = get_world_2d().direct_space_state
	var shape_query = PhysicsShapeQueryParameters2D.new()
	shape_query.shape = CircleShape2D.new()
	shape_query.shape.set_radius(area_attack_radius)
	shape_query.transform = global_transform
	shape_query.collision_mask = (2**1 + 2**2)
	shape_query.collide_with_areas = true
	shape_query.collide_with_bodies = false
	var result = space_state.intersect_shape(shape_query)
	for r in result:
		var collider = r["collider"]
		if collider.has_method("take_damage") and collider.has_method("get_affiliation"):
			if collider.get_affiliation() != affiliation:
				collider.take_damage(damage, self)

func _destroy_bullet(body=null):
	if body:
		if body.is_in_group("enemy") or body.is_in_group("player"):
			return
	if hit_sfx:
		hit_sfx.play()
	if hit_particles:
		hit_particles.emitting = true
	if get_node_or_null("Sprite2D"):
		get_node("Sprite2D").hide()
	collision_mask = 0
	await get_tree().create_timer(0.3).timeout
	queue_free()
