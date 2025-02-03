extends Area2D
class_name Hitbox

@export var sfx : AudioStreamPlayer2D

signal damage_taken
@export var target : Node2D

func get_affiliation():
	if not target:
		return
	if (target.is_in_group("friendly")):
		return "friendly"
	elif (target.is_in_group("enemy")):
		return "enemy"

func take_damage(_dmg := 1.0, _source : Node2D = null):
	damage_taken.emit()
	pass
