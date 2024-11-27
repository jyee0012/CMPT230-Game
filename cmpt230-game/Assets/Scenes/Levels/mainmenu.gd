extends Control

var new_scene = "res://Assets/Scenes/Levels/new_scene.tscn"
var testLevel = "res://Assets/Scenes/Levels/testlevel.tscn"


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Assets/Scenes/Levels/testLevel.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
