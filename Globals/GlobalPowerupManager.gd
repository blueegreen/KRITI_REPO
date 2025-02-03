extends Node

enum Powerup {PIERCE_UP, RANGE_UP, RATE_OF_FIRE, NUM_OF_BULLETS, HEALTH_UP, SPEED_UP,\
COFFEE_GUN, ICE_GUN, PAPER_GUN, VENDING_GUN}

var current_powerups := []

func apply_powerup(player:Player, powerup:Powerup):
	match powerup:
		Powerup.PIERCE_UP:
			if player.gun:
				player.gun.piercing += 1
		Powerup.RANGE_UP:
			if player.gun:
				player.gun.bullet_range *= 1.3
		Powerup.RATE_OF_FIRE:
			if player.gun:
				player.gun.delay_between_shots *= 0.6
		Powerup.NUM_OF_BULLETS:
			if player.gun:
				player.gun.bullets_in_batch = ceilf(player.gun.bullets_in_batch*1.5)
		Powerup.COFFEE_GUN:
			if player.gun:
				player.gun.queue_free()
			var new_gun = GlobalScenes.coffee_gun.instantiate()
			new_gun.global_position = player.global_position
			player.add_child(new_gun)
			player.gun = new_gun
		Powerup.VENDING_GUN:
			if player.gun:
				player.gun.queue_free()
			var new_gun = GlobalScenes.vending_gun.instantiate()
			new_gun.global_position = player.global_position
			player.add_child(new_gun)
			player.gun = new_gun
		Powerup.ICE_GUN:
			if player.gun:
				player.gun.queue_free()
			var new_gun = GlobalScenes.ice_gun.instantiate()
			new_gun.global_position = player.global_position
			player.add_child(new_gun)
			player.gun = new_gun
		Powerup.PAPER_GUN:
			if player.gun:
				player.gun.queue_free()
			var new_gun = GlobalScenes.paper_gun.instantiate()
			new_gun.global_position = player.global_position
			player.add_child(new_gun)
			player.gun = new_gun
