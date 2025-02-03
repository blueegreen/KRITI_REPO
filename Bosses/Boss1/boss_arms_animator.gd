extends Node

@export var arms : Array[Node2D]
@export var radius := 40

var offset_array : Array
var init_pos_array : Array

var _circle_path_progress := 0.0

func _ready():
	for arm in arms:
		init_pos_array.append(arm.position)
		offset_array.append(randf_range(0, 3))

func _process(delta):
	if arms:
		_circle_path_progress += delta * 0.6
		for n in range(arms.size()):
			if arms[n].position.distance_to(init_pos_array[n]) > radius:
				continue
			var path = (_circle_path_progress + offset_array[n])/(PI * 2)
			path = (_circle_path_progress + offset_array[n]) - int(path)
			var target_pos = init_pos_array[n] + radius * Vector2(cos(path * 2 * PI), sin(path * 2 * PI))
			arms[n].position = arms[n].position.lerp(target_pos, 1 - exp(-delta))
