extends Node2D

signal collected

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("send a signal")
	emit_signal("collected")
	queue_free()
