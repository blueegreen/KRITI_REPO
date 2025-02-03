extends CharacterBody2D
class_name Player

enum state {IDLE, RUN, DASH, HURT, DEAD}
var _current_state := state.IDLE

@export var max_speed := 300;
@export var acceleration := 10;
@export var max_hp := 5;
@export var max_dash_cooldown := .8
@export var gun : Gun
@export var hitbox : PlayerHitbox
@onready var animation_player = $AnimationPlayer
@onready var player_hitbox = $player_hitbox
@onready var player_sprite = $player_sprite


var _hp : float
var _dash_cooldown := 0.0
var _dash_dir : Vector2


func _ready():
	_hp = max_hp

func set_hp(value):
	_hp = clamp(value, 0, max_hp)

func get_hp() -> float:
	return _hp   	

func _process(delta):
	_dash_cooldown -= delta
	if _hp < 0.1 and _current_state != state.DEAD:
		_current_state = state.DEAD
		animation_player.play("dead")
		await get_tree().create_timer(3).timeout
		get_tree().change_scene_to_file("res://stage_1.tscn")
	if velocity.x < 0:
		player_sprite.flip_h = true
	else:
		player_sprite.flip_h = false
	if gun:
		gun.look_at(get_global_mouse_position())
	var input_dir = Input.get_vector("left", "right", "up", "down")
	match _current_state:
		state.IDLE:
			animation_player.play("idle")
			velocity = velocity.lerp(Vector2.ZERO, 1 - exp(-acceleration * delta))
			if not input_dir.is_zero_approx():
				_current_state = state.RUN
		state.RUN:
			animation_player.play("run")
			velocity = velocity.lerp(input_dir * max_speed, 1 - exp(-acceleration * delta))
			if input_dir.is_zero_approx():
				_current_state = state.IDLE
		state.DASH:
			velocity = velocity.lerp(_dash_dir * 3 * max_speed, 1 - exp(-2*acceleration * delta))
		state.DEAD:
			velocity = Vector2.ZERO
			pass
		state.HURT:
			velocity = velocity.lerp(input_dir * max_speed, 1 - exp(-acceleration * delta))
			pass

	move_and_slide()
	
	if Input.is_action_pressed("shoot") and gun and _current_state != state.DEAD:
		gun.shoot(get_global_mouse_position())

func hurt():
	_current_state = state.HURT
	animation_player.play("hurt")
	await get_tree().create_timer(1).timeout
	_current_state = state.IDLE

func _unhandled_key_input(event):
	var input_dir = Input.get_vector("left", "right", "up", "down")
	if not input_dir.is_zero_approx() and event.is_action_pressed("run, dodge") and _dash_cooldown < 0:
		_current_state = state.DASH
		_dash_cooldown = max_dash_cooldown
		_dash_dir = input_dir
		if _dash_dir.x < 0:
			animation_player.play("dash_left")
		else:
			animation_player.play("dash")
		player_hitbox.collision_layer = 0
		await get_tree().create_timer(0.4).timeout
		_current_state = state.RUN
		player_hitbox.collision_layer = 2**2
