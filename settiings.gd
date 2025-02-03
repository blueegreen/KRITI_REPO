extends Control
@export var back_level :String







func _on_resolution_options_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920,1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600,900))
		2:
			DisplayServer.window_set_size(Vector2i(1280,720))
		3:
			DisplayServer.window_set_size(Vector2i(2560,1440))
		4:
			DisplayServer.window_set_size(Vector2i(3840,2160))


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
	


func _on_fw_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
