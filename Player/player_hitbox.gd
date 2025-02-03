extends Hitbox
class_name PlayerHitbox

var i_time := false
@export var max_i_time := 0.4

func take_damage(dmg := 1.0, source : Node2D = null):
	if i_time:
		return
	i_time = true
	if source and target is CharacterBody2D:
		target.velocity = source.global_position.direction_to(global_position) * 500 * dmg
	if target.has_method("set_hp") and target.has_method("get_hp"):
		target.set_hp(target.get_hp() - dmg)
		damage_taken.emit()
		if sfx:
			sfx.play()
	await get_tree().create_timer(max_i_time).timeout
	i_time = false
	

func get_affiliation():
	return "friendly"
