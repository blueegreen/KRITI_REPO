extends Gun
class_name BossGun

var _init_transform : Transform2D

func _ready():
	super()
	_init_transform = transform

func reset_transform():
	var tween = create_tween()
	tween.tween_property(self, "transform", _init_transform, 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
