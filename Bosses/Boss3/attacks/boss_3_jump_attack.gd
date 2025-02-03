extends BossAttack
class_name Boss3_JumpAttack

var _boss : BOSS3
var _ik_master : IK_Master
var _boss_body : Node2D
var _player_ref : Player

@export var jump_warning_time := 1.0
@export var jump_duration := 1.5
@export var jump_height := 600.0
@export var jump_number := 1
@export var damage := 3.0
@onready var jump_wait = $jump_wait
@onready var damage_area = $damage_area
@onready var shadow_sprite = $shadow_sprite
@export var sfx : AudioStreamPlayer2D

func _ready():
	await get_tree().process_frame
	if get_parent() is BOSS3:
		_boss = get_parent()
	else:
		queue_free()
		return
	_ik_master = _boss.ik_master
	_boss_body = _boss.body
	_boss_body._in_jump = true
	_player_ref = _boss.player_ref
	jump_wait.wait_time = jump_warning_time
	jump_wait.timeout.connect(jump)
	jump_wait.start()

func _process(_delta):
	if _boss_body:
		damage_area.global_position = _boss_body.global_position + Vector2.DOWN * 180.0

func jump():
	if not _boss:
		queue_free()
		return
	
	var landing = func():
		if sfx:
			sfx.play()
		deal_damage()
		_ik_master.land()
		jump_number -= 1;
		if jump_number > 0:
			jump_wait.start()
			return
		end_attack()
		_boss_body._in_jump = false
		shadow_sprite.visible = false
		await get_tree().create_timer(0.5).timeout
		queue_free()
	
	var init_pos = _boss_body.global_position
	var target_pos = _player_ref.global_position
	var half_target_pos = (_boss_body.global_position + target_pos) * 0.5
	var height_pos = (_boss_body.global_position + target_pos) * 0.5 + Vector2.UP * jump_height
	
	var recalculate_target = func():
		target_pos = _player_ref.global_position
	
	_ik_master.jump()
	shadow_sprite.visible = true
	
	shadow_sprite.global_position = _boss_body.global_position + Vector2.DOWN * 200.0
	var shadow_tween = create_tween()
	shadow_tween.tween_property(shadow_sprite, "global_position", shadow_sprite.global_position, jump_duration/4.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	shadow_tween.tween_property(shadow_sprite, "global_position", half_target_pos, jump_duration/2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	shadow_tween.set_parallel(true).tween_property(shadow_sprite, "scale", Vector2(0.7, 0.7), jump_duration/2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	shadow_tween.set_parallel(false).tween_property(shadow_sprite, "global_position", target_pos, jump_duration/2.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	shadow_tween.set_parallel(true).tween_property(shadow_sprite, "scale", Vector2(1., 1.), jump_duration/2.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	var jump_tween = create_tween()
	jump_tween.tween_property(_boss_body, "global_position", init_pos + Vector2.DOWN * 80, jump_duration/4.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	jump_tween.tween_property(_boss_body, "global_position", height_pos, jump_duration/2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	jump_tween.tween_callback(recalculate_target)
	jump_tween.tween_property(_boss_body, "global_position", target_pos - Vector2.DOWN * 180.0, jump_duration/2.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	jump_tween.tween_callback(landing)

func deal_damage():
	for area in damage_area.get_overlapping_areas():
		if not area is BossHitbox and area.has_method("take_damage"):
			area.take_damage(damage, damage_area)
