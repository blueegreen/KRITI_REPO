extends Node2D
class_name MoleSpawner

@export var manager : MoleManager
@export var spawn_points : Array[Vector2]
@export var moles : Array[PackedScene]
@export var delay := 6.0
@export var batch_delay := 0.3
@export var max_moles := 100

var _spawn_time := 0.0

func _ready():
	if not manager:
		queue_free()
		return

func _process(delta):
	_spawn_time += delta
	if _spawn_time > delay:
		spawn_batch()
		_spawn_time = 0

func spawn_batch():
	var num = max_moles - manager._mole_count
	if num < 0:
		return
	num = min(num, 10)
	for n in range(num):
		spawn()
		await get_tree().create_timer(batch_delay).timeout

func spawn():
	var new_mole : Mole = null
	for m in range(moles.size()):
		var n = randf_range(0, 1)
		if n < 0.4:
			new_mole = moles[m].instantiate()
			break
	if not new_mole and moles.size() > 0:
		new_mole = moles[0].instantiate()
	new_mole.global_position = spawn_points.pick_random() + Vector2(randf_range(-80, 80), randf_range(-80, 80))
	manager.add_mole(new_mole)
