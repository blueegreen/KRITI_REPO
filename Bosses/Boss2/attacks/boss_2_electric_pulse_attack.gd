extends BossAttack

var _boss : BOSS2
var _coil : TeslaCoil

func _ready():
	await get_tree().process_frame
	if get_parent() is BOSS2:
		_boss = get_parent()
	else:
		queue_free()
		return
	
	_coil = _boss.antennae
	if _coil:
		_coil.big_attack()
		_coil.finished.connect(end_attack)
