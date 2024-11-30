extends Control

@onready var main = $"../../"

func _on_resume_pressed() -> void:
	main.pauseMenu()
	

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()
	Engine.time_scale=1
	
	
func _on_quit_pressed() -> void:
	get_tree().quit()
