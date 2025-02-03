extends Hitbox

signal hit(dmg, source)

func _ready():
	collision_layer = 2**1 + 2**2

func get_affiliation():
	return "none"

func take_damage(dmg:float=1.0, source:Node2D=null):
	if source:
		hit.emit(dmg, source)
	else:
		hit.emit(dmg, self)
