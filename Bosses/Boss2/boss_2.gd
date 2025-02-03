extends Node2D
class_name BOSS2

enum Phase {BASE, ONE, TWO, END}

@export var max_hp := 100.0
@export var phase_transition_1 := 0.5
@export var cooldown_time := 8.0
@export var max_move_distance := 900.0
@export var movement_duration := 1.5
@export var max_move_cooldown := 16.0
@export var antennae : TeslaCoil
@export var laser_gun_1 : LaserGun
@export var laser_gun_2 : LaserGun
@export var path_follow_node : PathFollow2D
@export var canvas_modulate : CanvasModulate
@export var spawner : MoleSpawner


@export var phase_1_attacks : Array[PackedScene]
@export var phase_2_attacks : Array[PackedScene]

var _hp := 50.0
var _current_phase := Phase.BASE
var _busy_in_attack := false
var _prev_attack_index := -1
var _path_move_tween : Tween
var _move_cooldown := 0.0

var current_attack : BossAttack = null
var player_ref : Player = null

func _ready():
	_hp = max_hp
	player_ref = get_tree().get_first_node_in_group("player")
	phase_transition(Phase.ONE)

func _process(delta):
	#print(_current_phase) if can_attack() else 0
	_move_cooldown -= delta
	if _current_phase != Phase.END:
		follow_path()
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
			pass

func follow_path():
	if path_follow_node:
		global_position = path_follow_node.global_position

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
			if spawner:
				spawner.delay = 999
			if canvas_modulate:
				canvas_modulate.color = Color("e48ca6")
			cooldown_time = 1.0
			pass
		Phase.END:
			print("boss dead")
			var tween = create_tween().tween_property(self, "global_position", global_position + Vector2.UP * 3000, 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			$boss2_hitbox.queue_free()
			if canvas_modulate:
				var canva_tween = create_tween().tween_property(canvas_modulate, "color", Color(0, 0, 0, 1), 5.0).set_ease(Tween.EASE_IN)
			pass
	_current_phase = new_phase
	if _current_phase == Phase.END:
		await get_tree().create_timer(6).timeout
		load_next_level()

func load_next_level():
	get_tree().change_scene_to_file("res://stage_3.tscn")

func attack_finished():
	if GlobalRef.camera_ref:
		GlobalRef.camera_ref.track_player()
	await get_tree().create_timer(cooldown_time).timeout
	_busy_in_attack = false
	current_attack = null

func move_on_damage():
	if _current_phase != Phase.END and _move_cooldown < 0:
		move_along_path()

func move_along_path():
	if path_follow_node:
		if _path_move_tween:
			if _path_move_tween.is_running():
				return
		if current_attack:
			current_attack.end_attack()
		_move_cooldown = max_move_cooldown
		var sgn = 1 if randi_range(0, 1) == 0 else -1
		var current_progress = path_follow_node.get_progress()
		var target_progress = current_progress + sgn * max_move_distance
		_path_move_tween = create_tween()
		_path_move_tween.tween_property(path_follow_node, "progress", target_progress, movement_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SPRING)
