extends RigidBody2D

func _ready():
	gravity_scale = 0.0
	lock_rotation = true
	linear_damp = 3.0
	collision_layer = 2**3
	collision_mask = 2**0 + 2**2 + 2**3

func move(strength : float, obj : Node2D):
	if obj is Bullet:
		var impulse = (obj.dir * 140.0 * strength).limit_length(240.0)
		apply_impulse(impulse, obj.global_position - global_position)
	else:
		var impulse = (obj.global_position.direction_to(global_position) * 300.0 * strength).limit_length(240.0)
		apply_central_impulse(impulse)
