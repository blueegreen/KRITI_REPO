extends Node2D

var target : CanvasItem
var _init_mat : Material
var flash_tween : Tween
@export var flash_mat : ShaderMaterial

func _ready():
	if get_parent() is CanvasItem:
		target = get_parent()
		if target.material:
			_init_mat = target.material
	else:
		push_warning("parent is not a CanvasItem")
		return

func trigger_shader():
	if not flash_mat or not target:
		return
	if flash_tween:
		flash_tween.kill()
	
	var reset_mat = func():
		if _init_mat:
			target.material = _init_mat
	
	target.material = flash_mat
	flash_tween = create_tween()
	flash_tween.tween_property(target.material, "shader_parameter/white", 1, 0.1)
	flash_tween.tween_property(target.material, "shader_parameter/white", 0, 0.15)
	flash_tween.tween_callback(reset_mat)
