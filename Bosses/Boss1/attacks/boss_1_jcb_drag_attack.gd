extends BossAttack

@onready var jcb_arm = $jcb_arm
@onready var jcb_claw = $jcb_claw
@onready var jcb_arm_sprite = $jcb_arm/jcb_arm_sprite
@onready var jcb_claw_sprite = $jcb_claw/jcb_claw_sprite
@onready var jcb_pivot = $jcb_pivot
@onready var mole_ball := $jcb_claw/mole_ball

@export var drag_sfx : AudioStreamPlayer2D
@export var warning_time = 2.0

var _boss
var _pivot_vel := 0.0
var _claw_vel := 0.0
var _dir := 0

var _moles_collected := 0

func _ready():
	await get_tree().process_frame
	_boss = get_parent()
	if not _boss is BOSS1:
		queue_free()
		return
	
	mole_ball.finished.connect(end_attack)
	_dir = randi_range(0, 1)
	var final_pos : Vector2
	if _dir == 1:
		_dir = -1
		jcb_claw.scale.y = -1
		global_position = _boss.jcb_right_pos.global_position + Vector2(600, randf_range(-100, 100))
		final_pos = Vector2(_boss.jcb_right_pos.global_position.x, jcb_arm.global_position.y)
	else:
		_dir = 1
		global_position = _boss.jcb_left_pos.global_position + Vector2(-600, randf_range(-100, 100))
		final_pos = Vector2(_boss.jcb_left_pos.global_position.x, jcb_arm.global_position.y)
	var tween = create_tween()
	tween.tween_property(jcb_arm, "global_position", final_pos, 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(attack)

func _process(delta):
	jcb_physics(delta)
	pass

func jcb_physics(delta):
	jcb_arm.look_at(jcb_pivot.global_position)
	jcb_claw.look_at(jcb_pivot.global_position)
	#var dir = Input.get_axis("left", "right")
	#jcb_arm.position += Vector2(600 * delta * dir, 0)
	var pivot_spring_force = (jcb_arm.position.x - jcb_pivot.position.x) * 30
	_pivot_vel += pivot_spring_force * delta
	_pivot_vel *= max(0, (1 - min(3 * delta, 0.5)))
	jcb_pivot.position.x += _pivot_vel * delta
	var claw_spring_force = (jcb_pivot.position.x - jcb_claw.position.x) * 90
	_claw_vel += claw_spring_force * delta
	_claw_vel *= max(0, (1 - min(3 * delta, 0.5)))
	jcb_claw.position.x += _claw_vel * delta

func warning():
	pass

func attack():
	await get_tree().create_timer(warning_time).timeout
	if drag_sfx:
		drag_sfx.play()
	var tween = create_tween()
	var target_pos = jcb_arm.position + Vector2(1600 * _dir, 0)
	tween.tween_property(jcb_arm, "position", target_pos, 2.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(throw)

func throw():
	if drag_sfx:
		drag_sfx.stop()
	var x_form = [jcb_arm.global_transform, jcb_pivot.global_transform, jcb_claw.global_transform]
	global_position.x = jcb_arm.global_position.x
	jcb_arm.global_transform = x_form[0]
	jcb_pivot.global_transform = x_form[1]
	jcb_claw.global_transform = x_form[2]
	await get_tree().create_timer(1).timeout
	var rotate_tween = create_tween()
	rotate_tween.tween_property(self, "rotation", rotation + (-_dir * PI * 1.5), 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	rotate_tween.tween_callback(throw_ball)
	rotate_tween.tween_property(self, "position", position + Vector2(_dir * 700, -700), 0.6).set_ease(Tween.EASE_OUT)

func throw_ball():
	mole_ball.velocity = Vector2(-_dir, randf_range(PI/4.0, PI/3.0)).normalized() * mole_ball.max_velocity
	var pos = mole_ball.global_position
	jcb_claw.remove_child(mole_ball)
	add_sibling(mole_ball)
	mole_ball.global_position = pos
	pass
	
func _on_mole_collection_area_area_entered(area):
	if area is PlayerHitbox:
		area.take_damage(2.0, self)
	elif area is Mole:
		area.queue_free()
		_moles_collected += 1
		update_mole_ball()

func update_mole_ball():
	if _moles_collected > 0 and _moles_collected < 4:
		mole_ball.current_state = mole_ball.state.SMALL
	elif _moles_collected > 4:
		mole_ball.current_state = mole_ball.state.BIG

func end_attack():
	super()
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(_dir * 700, -700), 0.6).set_ease(Tween.EASE_OUT)
	tween.tween_callback(queue_free)
