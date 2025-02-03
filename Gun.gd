extends Node2D
class_name Gun

@export var bullet : PackedScene
@export var damage := 1.0
@export var bullet_speed := 400.0
@export var bullets_in_batch : int = 3
@export var delay_between_batch_shots : float = 0.05
@export var delay_between_shots : float = 0.5
@export var angle_randomness : float = 0.2
@export var affiliation : String = "friendly"
@export var recoil_amount : float = 20
@export var bullet_range : float = 700.0
@export var piercing := 0.0
@export var orient_bullet := false
@export var area_attack := false
@export var area_attack_radius := 64.0
@export var gun_sprite : Sprite2D
@export var gun_shoot_sfx : AudioStreamPlayer2D
var cooldown: float = 0.0

var _init_scale : Vector2

func _ready():
	if gun_sprite:
		_init_scale = gun_sprite.scale

func _process(delta):
	cooldown -= delta
	if gun_sprite:
		if global_rotation > PI/2.0 or global_rotation < -PI/2.0:
			gun_sprite.scale.y = -1 * _init_scale.y
		else:
			gun_sprite.scale.y = 1 * _init_scale.y

func shoot(target_position: Vector2):
	if cooldown > 0.0:
		return
	cooldown = delay_between_shots
	if bullet == null:
		return
	if gun_shoot_sfx:
		gun_shoot_sfx.play()
	recoil_animation(target_position)
	for n in range(bullets_in_batch):
		var new_bullet : Bullet = bullet.instantiate()
		new_bullet.top_level = true
		new_bullet.speed = bullet_speed
		new_bullet.piercing = piercing
		new_bullet.area_attack = area_attack
		new_bullet.area_attack_radius = area_attack_radius
		new_bullet.damage = damage
		new_bullet.max_life = bullet_range/bullet_speed
		if get_node_or_null("bullet_spawn_point"):
			new_bullet.global_position = get_node("bullet_spawn_point").global_position
		else:
			new_bullet.global_position = global_position
		new_bullet.affiliation = affiliation
		new_bullet.dir = global_position.direction_to(target_position).rotated(randf_range(-angle_randomness/2.0, angle_randomness/2.0))
		if orient_bullet:
			new_bullet.look_at(new_bullet.global_position + new_bullet.dir * 100)
		owner.add_sibling(new_bullet)
		if not is_equal_approx(delay_between_batch_shots, 0.0):
			await get_tree().create_timer(delay_between_batch_shots).timeout

func shoot_forward():
	var dir = Vector2(cos(global_rotation), sin(global_rotation))
	shoot(global_position + dir * 3000)

func recoil_animation(target_position: Vector2):
	var dir = global_position.direction_to(target_position)
	if not gun_sprite:
		return
	var current_pos = gun_sprite.position
	var tween = create_tween()
	tween.tween_property(gun_sprite, "global_position", gun_sprite.global_position - dir*recoil_amount, min(0.05, delay_between_shots/3.0))
	tween.tween_property(gun_sprite, "position", current_pos, delay_between_shots/3.0)
