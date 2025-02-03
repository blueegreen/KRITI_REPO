extends MoleBehaviour

static func set_behaviour(mole:Mole) -> void:
	mole.movement_speed = 200.0
	mole.max_speed = 350.0
	mole.time_nav_update = 2.0
	mole.min_distance_to_player = 50.
	mole.max_hp = 2.0
	mole.shooting = false
	mole.shooting_target = null
