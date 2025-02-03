extends Bullet

func _deal_damage(area):
	if area is BossHitbox:
		return
	super(area)
