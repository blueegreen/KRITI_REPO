extends Control
@export var next_level :String
@export var settings_level :String



	
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(next_level)


func _on_options_pressed() :
	get_tree().change_scene_to_file(settings_level)


func _on_quit_pressed() -> void:
	get_tree().quit()
