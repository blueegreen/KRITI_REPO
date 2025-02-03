extends BossAttack

enum state {IDLE, WARNING, ATTACK}
var _current_state := state.IDLE

var _boss : BOSS2
var _laser_guns : Array[LaserGun]
var _dir := Vector2()
@export var warning_duration := 2.0
@export var attack_duration := 14.0


func _ready():
	await get_tree().process_frame
	if get_parent() is BOSS2:
		_boss = get_parent()
	else:
		queue_free()
		return
	_laser_guns.append(_boss.laser_gun_1)
	_laser_guns.append(_boss.laser_gun_2)
	_dir = Vector2.RIGHT
	var tween = create_tween()
	tween.tween_property(self, "_dir", Vector2.DOWN, 0.6).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(warning)

func _process(delta):
	for gun in _laser_guns:
		gun.look_at(gun.global_position + oriented_dir(gun, _dir) * 500)
	match _current_state:
		state.IDLE:
			return
		state.WARNING:
			for gun in _laser_guns:
				gun.warning_shoot(oriented_dir(gun, _dir))
		state.ATTACK:
			for gun in _laser_guns:
				gun.shoot(oriented_dir(gun, _dir))

func warning():
	_current_state = state.WARNING
	await get_tree().create_timer(warning_duration).timeout
	swing_dir()
	attack()

func attack():
	_current_state = state.ATTACK
	await get_tree().create_timer(attack_duration * 1.2).timeout
	end_attack()

func oriented_dir(gun: LaserGun, direction: Vector2) -> Vector2:
	if gun.flipped:
		return direction.reflect(Vector2.DOWN)
	else:
		return direction

func swing_dir():
	if _laser_guns.size() == 1 or not _boss:
		return
	var tween = create_tween()
	var target_dir_1 = Vector2.LEFT
	var target_dir_2 = Vector2.DOWN
	tween.tween_property(self, "_dir", target_dir_1, attack_duration/2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "_dir", target_dir_2, attack_duration/2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

func end_attack():
	super()
	_current_state = state.IDLE
	for gun in _laser_guns:
		gun.stop_shoot()
		gun.reset_transform()
	queue_free()
