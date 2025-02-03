extends Area2D
class_name MoleBall

enum state {NONE, SMALL, BIG}
var current_state = state.NONE
signal finished

var big = false
var velocity := Vector2()

@export var max_collisions = 6
@export var max_time = 25.0
@export var max_velocity = 1000.0

var _time := 0.0
var _collision_count := 0

func _process(delta):
	_time += delta
	rotation += delta * 4
	if _time > max_time:
		explode()
		return
	match current_state:
		state.NONE:
			$small_sprite.visible = false
			$small_collider.disabled = true
			$big_sprite.visible = false
			$big_collider.disabled = true
		state.SMALL:
			$small_sprite.visible = true
			$small_collider.disabled = false
			$big_sprite.visible = false
			$big_collider.disabled = true
		state.BIG:
			$small_sprite.visible = false
			$small_collider.disabled = true
			$big_sprite.visible = true
			$big_collider.disabled = false

	if not velocity.is_zero_approx():
		global_position += velocity * delta
		var collision = check_for_collision()
		if collision:
			_collision_count += 1
			if _collision_count >= max_collisions:
				explode()
				return
			var normal = collision["normal"]
			var new_velocity = - (velocity.project(normal)) + (velocity - velocity.project(normal))
			velocity = new_velocity

func check_for_collision():
	var space_state = get_world_2d().direct_space_state
	var ray_query = PhysicsRayQueryParameters2D.create(global_position, global_position + velocity.normalized() * 96.0, (2 ** 0 + 2 ** 3))
	var result = space_state.intersect_ray(ray_query)
	if result:
		return result
	else:
		return null

func explode():
	finished.emit()
	queue_free()

func _on_area_entered(area):
	if area.has_method("take_damage") and not area is BossHitbox:
		area.take_damage(2.0, self)
	
