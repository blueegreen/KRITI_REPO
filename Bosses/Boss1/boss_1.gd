extends Node2D
class_name BOSS1

enum Phase {BASE, ONE, TWO, END}

@export var max_hp := 50.0
@export var phase_transition_1 := 0.5
@export var cooldown_time = 15.0
@export var canvas_modulate : CanvasModulate

@onready var gun_hand = $Boss1_GunHand
@onready var gun_hand2 = $Boss1_GunHand_2
@onready var remote_hand = $Boss1_RemoteHand
@onready var whack_hand = $Boss1_WhackaMoleHand
@export var jcb_left_pos : Node2D
@export var jcb_right_pos : Node2D

@export var phase_1_attacks : Array[PackedScene]
@export var phase_2_attacks : Array[PackedScene]

var _hp := 50.0
var _current_phase := Phase.BASE
var _busy_in_attack := false
var _prev_attack_index := -1

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
	return (not _busy_in_attack) and not (current_attack)

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
	
	if GlobalRef.camera_ref:
		GlobalRef.camera_ref.track_boss_attack(self)

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
		Phase.END:
			return
		
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
			cooldown_time = 1.0
			if canvas_modulate:
				canvas_modulate.color = Color("cc736d")
			$face_sprite.frame = 1
			pass
		Phase.END:
			print("boss dead")
			$boss_hitbox.queue_free()
			$face_sprite.queue_free()
			if canvas_modulate:
				var tween = create_tween().tween_property(canvas_modulate, "color", Color(0, 0, 0, 1), 5).set_ease(Tween.EASE_IN)
	_current_phase = new_phase
	if _current_phase == Phase.END:
		await get_tree().create_timer(6).timeout
		load_next_level()

func load_next_level():
	get_tree().change_scene_to_file("res://stage_2.tscn")

func attack_finished():
	if GlobalRef.camera_ref:
		GlobalRef.camera_ref.track_player()
	await get_tree().create_timer(cooldown_time).timeout
	_busy_in_attack = false
	current_attack = null
