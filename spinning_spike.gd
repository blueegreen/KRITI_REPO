extends Node2D

@export var damage := 3.0
@onready var area_2d = $Area2D

func _process(_delta):
	for area in area_2d.get_overlapping_areas():
		if area.has_method("take_damage") and not area is BossHitbox:
			area.take_damage(damage, self)
