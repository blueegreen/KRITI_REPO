extends BossAttack

var _boss : BOSS1 = null
var _whack_hand : WhackaMole = null
var _player_ref : Player

@export var aiming_time = 4.0
var _time = 0.0
var finished = false
@export var sfx : AudioStreamPlayer2D

func _ready():
	await get_tree().process_frame
	if get_parent() is BOSS1:
		_boss = get_parent()
	else:
		queue_free()
		return
	_whack_hand = _boss.whack_hand
	_player_ref = _boss.player_ref
	_whack_hand.finished.connect(reset_hand)

func _process(delta):
	if finished:
		return
	_time += delta
	if _time < aiming_time:
		if _whack_hand and _player_ref:
			_whack_hand.aim_at(_player_ref.global_position)
	else:
		if _whack_hand:
			finished = true
			_whack_hand.smash()

func reset_hand():
	end_attack()

func end_attack():
	super()
	if _whack_hand:
		_whack_hand.reset_transform()
	queue_free()
