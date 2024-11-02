extends Node

@export var PlayerHealth = 3
@export var DashUnlocked = false
@export var DashesUnlocked = 1
@export var WalljumpUnlocked = false
@export var JumpsUnlocked = 1

var playerBody: CharacterBody2D

signal dash_collect
signal hp_collect
signal whip_collect
signal wing_collect

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_item_boot_collected() -> void:
	emit_signal("dash_collect")


func _on_item_health_collected() -> void:
	emit_signal("hp_collect")
	#print("nice health, but we aint implemented that yet")


func _on_item_whip_collected() -> void:
	emit_signal("whip_collect")
	#print("nice whip, but we aint implemented that yet")

func _on_item_wing_collected() ->void:
	emit_signal("wing_collect")
