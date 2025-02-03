extends Node2D
class_name BOSS3

enum Phase {BASE, ONE, TWO, END}

@onready var animation_player = $AnimationPlayer

@export_category("boss nodes")
@export var ik_master : IK_Master
@export var body : Node2D
@export var hitbox : BossHitbox

@export_category("boss mechanics")
@export var max_hp := 70.0
@export var phase_transition_1 := 0.5
@export var cooldown_time = 2.0

@export var phase_1_attacks : Array[PackedScene]
@export var phase_2_attacks : Array[PackedScene]

var _hp := 50.0
var _current_phase := Phase.BASE
var _busy_in_attack := false
var _prev_attack_index := -1

var _is_closed := true
var _can_attack := true

var current_attack : BossAttack = null
var player_ref : Player = null

func _ready():
	_hp = max_hp
	player_ref = get_tree().get_first_node_in_group("player")
	phase_transition(Phase.ONE)

func _process(delta):
	match _current_phase:
		Phase.BASE:
			pass
		Phase.ONE:
			if can_attack():
				var new_index = randi_range(0, phase_1_attacks.size() - 1)
				if new_index == _prev_attack_index:
					new_index = (new_index + 1) % phase_1_attacks.size()
				_prev_attack_index = new_index
				spawn_attack(phase_1_attacks[new_index])
			pass
		Phase.TWO:
			if can_attack():
				var new_index = randi_range(0, phase_2_attacks.size() - 1)
				if new_index == _prev_attack_index:
					new_index = (new_index + 1) % phase_2_attacks.size()
				_prev_attack_index = new_index
				spawn_attack(phase_2_attacks[new_index])
			pass
		Phase.END:
			return

func can_attack():
	return _can_attack

func spawn_attack(atk:PackedScene):
	var new_attack : BossAttack = atk.instantiate()
	if not new_attack is BossAttack:
		new_attack.queue_free()
		return
	new_attack.global_position = global_position
	new_attack.attack_finished.connect(attack_finished)
	add_child(new_attack)
	current_attack = new_attack
	_busy_in_attack = true
	_can_attack = false
	
	#if GlobalRef.camera_ref:
		#GlobalRef.camera_ref.track_boss_attack(self)

func set_hp(value):
	_hp = clamp(value, 0, max_hp)
	calculate_phase()

func calculate_phase():
	match _current_phase:
		Phase.ONE:
			if _hp < max_hp * phase_transition_1:
				phase_transition(Phase.TWO)
		Phase.TWO:
			if _hp <= 0:
				phase_transition(Phase.END)

func get_hp():
	return _hp

func phase_transition(new_phase: Phase):
	if current_attack:
		current_attack.end_attack()
	match new_phase:
		Phase.ONE:
			print("starting phase 1")
			pass
		Phase.TWO:
			print("starting phase 2")
			pass
		Phase.END:
			print("boss dead")
			hitbox.queue_free()
			open_shell()
			var tween = create_tween().tween_property(body, "global_position", body.global_position + Vector2.DOWN * 2000, 3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			pass
	_current_phase = new_phase
	if _current_phase == Phase.END:
		await get_tree().create_timer(3).timeout
		load_next_level()

func load_next_level():
	get_tree().change_scene_to_file("res://win_stage.tscn")

func attack_finished():
	#if GlobalRef.camera_ref:
		#GlobalRef.camera_ref.track_player()
	await get_tree().create_timer(cooldown_time).timeout
	_busy_in_attack = false
	current_attack = null

func reset_attack():
	_can_attack = true

func open_shell():
	if not _is_closed:
		return
	animation_player.stop()
	animation_player.play("open")
	await get_tree().create_timer(1.0).timeout
	_is_closed = false

func close_shell():
	if _is_closed:
		return
	animation_player.stop()
	animation_player.play_backwards("open")
	animation_player.queue("idle")
	await get_tree().create_timer(1.0).timeout
	_is_closed = true
