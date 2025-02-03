extends BossAttack

enum state {IDLE, WARNING, ATTACK}
var _current_state := state.IDLE

var _boss : BOSS2
var _laser_gun : LaserGun
var _dir := Vector2()
@export var warning_duration := 2.0
@export var attack_duration := 10.0


func _ready():
	await get_tree().process_frame
	if get_parent() is BOSS2:
		_boss = get_parent()
	else:
		queue_free()
		return
	_laser_gun = _boss.laser_gun_1 if randi_range(0, 1) == 0 else _boss.laser_gun_2
	_dir = Vector2.RIGHT
	var tween = create_tween()
	tween.tween_property(self, "_dir", Vector2.DOWN, 0.6).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(warning)

func _process(delta):
	_laser_gun.look_at(_laser_gun.global_position + _dir * 500)
	match _current_state:
		state.IDLE:
			return
		state.WARNING:
			_laser_gun.warning_shoot(_dir)
		state.ATTACK:
			_laser_gun.shoot(_dir)

func warning():
	_current_state = state.WARNING
	await get_tree().create_timer(warning_duration).timeout
	swing_dir()
	attack()

func attack():
	_current_state = state.ATTACK
	await get_tree().create_timer(attack_duration * 1.2).timeout
	end_attack()

func swing_dir():
	if not _laser_gun or not _boss:
		return
	var tween = create_tween()
	var target_dir_1 = oriented_dir(_laser_gun, Vector2.LEFT)
	var target_dir_2 = Vector2.DOWN
	tween.tween_property(self, "_dir", target_dir_1, attack_duration/2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "_dir", target_dir_2, attack_duration/2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

func oriented_dir(gun: LaserGun, direction: Vector2) -> Vector2:
	if gun.flipped:
		return direction.reflect(Vector2.DOWN)
	else:
		return direction

func end_attack():
	super()
	_current_state = state.IDLE
	if _laser_gun:
		_laser_gun.stop_shoot()
		_laser_gun.reset_transform()
	queue_free()
