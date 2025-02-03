extends Node2D
@onready var mole_manager = $mole_manager
@onready var pause_menu: Control = $Pause_Menu

var spawn_time := 10.0
var _time := 0.0
var count = 0


func _ready():
	pause_menu.hide()
func _process(delta):
	_time += delta
	if _time > spawn_time:
		spawn_mole()
		_time = 0

func spawn_mole():
	var pos = Vector2(randf_range(-800, 800), randf_range(-300, 200))
	var new_mole = preload("res://Moles/mole_1.tscn").instantiate()
	new_mole.global_position = pos
	mole_manager.add_mole(new_mole)
	count += 1
	#print(count)
