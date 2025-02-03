extends BossAttack

enum state {NONE, WARNING, ATTACK}
var _current_state : state = state.NONE
var _boss : BOSS3
var _player_ref : Player

var _dir := Vector2()

@onready var warning_laser = $warning_laser
@onready var target = $target
@onready var attack_laser = $attack_laser
@onready var damage_area = $damage_area
@onready var timer = $Timer
@export var damage := 3.0
@export var warning_time := 2.0
@export var attack_time := 3.0
@export var sfx : AudioStreamPlayer2D
@export var warning_sfx : AudioStreamPlayer2D
@onready var attack_particles = $GPUParticles2D

func _ready():
	await get_tree().process_frame
	if get_parent() is BOSS3:
		_boss = get_parent()
		_player_ref = _boss.player_ref
	else:
		queue_free()
		return
	_boss.open_shell()
	global_position = _boss.global_position + randf_range(380, 450) * Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	_current_state = state.WARNING
	timer.wait_time = warning_time
	timer.timeout.connect(start_attack)
	timer.start()

func _process(delta):
	match _current_state:
		state.NONE:
			warning_laser.visible = false
			attack_laser.visible = false
			target.visible = false
		state.WARNING:
			if warning_sfx:
				warning_sfx.play()
			warning_laser.visible = true
			attack_laser.visible = false
			target.visible = true
			follow_player(delta, 350.0)
		state.ATTACK:
			if sfx:
				if not sfx.playing:
					sfx.play()
			if warning_sfx:
				warning_sfx.stop()
			warning_laser.visible = false
			attack_laser.visible = true
			target.visible = false
			follow_player(delta, 300.0)
			deal_damage()

func follow_player(delta, speed):
	if _player_ref:
		#global_position = global_position.lerp(_player_ref.global_position, 1 - exp(-speed * delta))
		_dir = _dir.lerp(global_position.direction_to(_player_ref.global_position), 1 - exp(-speed/100.0 * delta))
		global_position += _dir * speed * delta

func deal_damage():
	for area in damage_area.get_overlapping_areas():
		if area.has_method("take_damage") and not area is BossHitbox:
			area.take_damage(damage, self)

func start_attack():
	attack_particles.emitting = true
	_current_state = state.ATTACK
	timer.wait_time = attack_time
	timer.disconnect("timeout", start_attack)
	timer.timeout.connect(end_attack)
	timer.start()

func end_attack():
	super()
	attack_particles.emitting = false
	_boss.close_shell()
	_current_state = state.NONE
	await get_tree().create_timer(2.0).timeout
	queue_free()
	
