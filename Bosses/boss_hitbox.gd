extends Hitbox
class_name BossHitbox

func take_damage(dmg := 1.0, _source : Node2D = null):
	if target.has_method("set_hp") and target.has_method("get_hp"):
		target.set_hp(target.get_hp() - dmg)
		damage_taken.emit()
		if sfx:
			sfx.play()

func get_affiliation():
	return "enemy"
