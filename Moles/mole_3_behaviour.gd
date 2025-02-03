extends MoleBehaviour

static func set_behaviour(mole:Mole) -> void:
	mole.movement_speed = 100.0
	mole.max_speed = 350.0
	mole.time_nav_update = 2.0
	mole.min_distance_to_player = 100.
	mole.max_hp = 5.0
	mole.shooting = true
	mole.shooting_target = mole.navigation_target
