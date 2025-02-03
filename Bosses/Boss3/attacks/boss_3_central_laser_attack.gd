extends BossAttack

enum state {IDLE, WARNING, ATTACK}
var _current_state : state = state.IDLE

var _boss : BOSS3
var _boss_body : Node2D
var _player_ref : Player
var _dir := Vector2()
@onready var laser_shooter : LaserGun = $laser_shooter
@export var warning_duration := 1.0
@export var attack_duration := 5.0
@export var sfx : AudioStreamPlayer2D

func _ready():
	await get_tree().process_frame
	if get_parent() is BOSS3:
		_boss = get_parent()
	else:
		queue_free()
		return
	_boss_body = _boss.body
	_player_ref = _boss.player_ref
	_boss.open_shell()
	await get_tree().create_timer(0.5).timeout
	start_warning()

func _process(delta):
	if not _boss:
		queue_free()
		return
	laser_shooter.global_position = _boss_body.global_position + Vector2.UP * 30
	var target_dir = laser_shooter.global_position.direction_to(_player_ref.global_position)
	_dir = _dir.lerp(target_dir, 1 - exp(-2.0 * delta))
	match _current_state:
		state.IDLE:
			return
		state.WARNING:
			laser_shooter.warning_shoot(_dir)
		state.ATTACK:
			if sfx:
				if not sfx.playing:
					sfx.play()
			laser_shooter.shoot(_dir)

func start_warning():
	_current_state = state.WARNING
	await get_tree().create_timer(warning_duration).timeout
	start_attack()

func start_attack():
	_current_state = state.ATTACK
	await get_tree().create_timer(attack_duration).timeout
	end_attack()

func end_attack():
	super()
	_current_state = state.IDLE
	laser_shooter.stop_shoot()
	if _boss:
		_boss.close_shell()
	queue_free()
