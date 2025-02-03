extends Node2D
enum Phase {BASE, ONE, TWO, THREE, STUN}

@export var max_hp := 50.0
@export var phase_transition_1 := 0.6
@export var phase_transition_2 := 0.3

var _hp := 50.0
var _current_phase := Phase.BASE
var _busy_in_attack := false

var current_attack : BossAttack = null
var player_ref : Player = null

func _ready():
	_hp = max_hp
	player_ref = get_tree().get_first_node_in_group("player")
	phase_transition(Phase.ONE)

func _process(delta):
	if _busy_in_attack:
		return
	match _current_phase:
		Phase.BASE:
			pass
		Phase.ONE:
			pass
		Phase.TWO:
			pass
		Phase.THREE:
			pass
		Phase.STUN:
			pass
		_:
			return

func set_hp(value):
	_hp = clamp(value, 0, max_hp)
	calculate_phase()

func calculate_phase():
	match _current_phase:
		Phase.ONE:
			if _hp < max_hp * phase_transition_1:
				phase_transition(Phase.TWO)
		Phase.TWO:
			if _hp < max_hp * phase_transition_2:
				phase_transition(Phase.THREE)
		Phase.THREE:
			if _hp <= 0:
				end_boss()

func get_hp():
	return _hp

func phase_transition(new_phase: Phase):
	if current_attack:
		current_attack.end_attack()
	stun()
	match new_phase:
		Phase.ONE:
			pass
		Phase.TWO:
			pass
		Phase.THREE:
			pass
		_:
			return
	_current_phase = new_phase

func stun():
	pass

func attack_finished():
	_busy_in_attack = false

func end_boss():
	if current_attack:
		current_attack.end_attack()
	pass
