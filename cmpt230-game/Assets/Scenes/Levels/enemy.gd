extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var hp = 30
@export
var patrolRange = 500
var startPos
var facing = -1

func _ready() -> void:
	startPos = position
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	patrol()
	move_and_slide()

func takeDamage(dmg:int) -> void:
	hp -= dmg
	print("took dmg, hp:", hp)
	if hp <= 0:
		queue_free()

func patrol() -> void:
	var direction
	if position.x > startPos.x + patrolRange or position.x < startPos.x - patrolRange:
		facing *= -1
		$Sprite2D.flip_h = facing == 1
	velocity.x = facing * SPEED
