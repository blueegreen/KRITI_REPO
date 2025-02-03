extends BossAttack

var boss : BOSS1 = null
var gun_hand : Gun = null
var player_ref : Player = null
var init_transform : Transform2D
@export var attack_duration := 5.0

var _finished = false

func _ready():
	await get_tree().process_frame
	$Timer.wait_time = attack_duration
	$Timer.start()
	if get_parent() is BOSS1:
		boss = get_parent()
	else:
		queue_free()
		return
	gun_hand = boss.gun_hand2
	player_ref = boss.player_ref
	init_transform = gun_hand.global_transform

func _process(delta):
	if _finished:
		return
	if gun_hand and player_ref:
		var target_angle = gun_hand.global_position.angle_to_point(player_ref.global_position)
		gun_hand.rotation = lerp_angle(gun_hand.rotation, target_angle, 1 - exp(-delta))
		gun_hand.shoot_forward()

func _on_timer_timeout():
	end_attack()
	
func end_attack():
	super()
	_finished = true
	if gun_hand:
		gun_hand.reset_transform()
	queue_free()
