extends Control


func _on_display_pressed() -> void:
	get_tree().change_scene_to_file("res://display_menu.tscn")


func _on_sound_pressed() -> void:
	get_tree().change_scene_to_file("res://sound_menu.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
