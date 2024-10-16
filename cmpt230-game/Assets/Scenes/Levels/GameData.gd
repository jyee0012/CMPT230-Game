extends Node

@export var PlayerHealth = 3
@export var DashUnlocked = false
@export var DashesUnlocked = 1
@export var WalljumpUnlocked = false
@export var JumpsUnlocked = 1

signal dash_collect


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_item_collected() -> void:
	emit_signal("dash_collect")
