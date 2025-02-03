extends BossAttack

enum state {IDLE, WARNING, ATTACK}
var _current_state := state.IDLE

var _boss : BOSS2
var _coil : TeslaCoil
var _hit_cooldown := 0.0
@export var num_of_hits := 25
@export var delay_between_hits := 0.5
@export var warning_time := 2.0

func _ready():
	await get_tree().process_frame
	if get_parent() is BOSS2:
		_boss = get_parent()
	else:
		queue_free()
		return
	
	_coil = _boss.antennae
	num_of_hits = max(1, num_of_hits + randi_range(-2, 2))
	warning()

func _process(delta):
	match _current_state:
		state.IDLE:
			pass
		state.WARNING:
			pass
		state.ATTACK:
			if _coil:
				_hit_cooldown -= delta
				if _hit_cooldown < 0 and num_of_hits > 0:
					_coil.small_attack()
					num_of_hits -= 1
					_hit_cooldown = delay_between_hits
				if num_of_hits <= 0:
					end_attack()

func warning():
	_current_state = state.WARNING
	await get_tree().create_timer(warning_time).timeout
	attack()

func attack():
	_current_state = state.ATTACK

func end_attack():
	super()
	_current_state = state.IDLE
	queue_free()
