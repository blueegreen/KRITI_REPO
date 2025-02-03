extends Node2D

var move_duration := 6.0
var _current_move_duration := 0.0
var target_pos : Vector2
var _in_jump := false

func _ready():
	find_new_target()

func _process(delta):
	if _in_jump:
		return
	_current_move_duration += delta
	if _current_move_duration > move_duration:
		find_new_target()
		_current_move_duration = 0
	global_position = global_position.lerp(target_pos, 1 - exp(-delta * 0.2))

func find_new_target():
	target_pos = Vector2(randf_range(-600, 600), randf_range(-600, 600))
