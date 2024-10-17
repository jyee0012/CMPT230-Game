extends Node2D

signal boot_collected
signal whip_collected
signal health_collected

enum type {boot, whip, health}

@export var item: type

@onready var sprite = $Sprite2D

func _ready() -> void:
	match  item:
		type.boot:
			sprite.texture = load("res://Assets/Sprites/Items/boot.png")
		type.whip:
			sprite.texture = load("res://Assets/Sprites/Items/whip.png")
		type.health:
			sprite.texture = load("res://Assets/Sprites/Items/cheeseheart.png")

func _on_area_2d_area_entered(area: Area2D) -> void:
	match item:
		type.boot:
			emit_signal("boot_collected")
		type.whip:
			emit_signal("whip_collected")
		type.health:
			emit_signal("health_collected")
	
	queue_free()
