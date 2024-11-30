extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Levels/mainLevel.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_button_pressed() -> void:
	pass # Replace with function body.
