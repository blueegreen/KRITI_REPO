extends BossAttack

var _boss : BOSS3

enum state {IDLE, ATTACK}
var _current_state = state.IDLE

@export var warning_time := 2.0
@export var attack_time := 6.0
@export var rotation_speed := 2.0

func _ready():
	await get_tree().process_frame
	if get_parent() is BOSS3:
		_boss = get_parent()
	else:
		queue_free()
		return
	
	_boss.open_shell()
	await get_tree().create_timer(warning_time).timeout
	_current_state = state.ATTACK
	$Timer.wait_time = attack_time
	$Timer.start()
	$Timer.timeout.connect(end_attack)

func _process(delta):
	if _boss:
		global_position = _boss.body.global_position
	match _current_state:
		state.IDLE:
			pass
		state.ATTACK:
			rotation += rotation_speed * delta
			for child in get_children():
				if child is Gun:
					child.shoot_forward()

func end_attack():
	_current_state = state.IDLE
	await get_tree().create_timer(warning_time).timeout
	super()
	if _boss:
		_boss.close_shell()
	queue_free()
