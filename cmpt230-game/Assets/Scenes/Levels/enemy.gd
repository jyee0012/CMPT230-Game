extends CharacterBody2D


const SPEED = 300.0
var chasing: bool= false
var returning:bool = false
const JUMP_VELOCITY = -400.0
@export var hp = 30
@export
var patrolRange = 500
var startPos
var facing = -1

var dead:bool=false
var taking_damage:bool=false
var atk = 20
var is_attacking:bool = false

var dir: Vector2
var knockback = -2500
var is_patrolling:bool=true

var player:CharacterBody2D

@export var spotRadius = 500

func _ready() -> void:
	startPos = position
	player = GameData.playerBody
	
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move()
	animationHandler()
	move_and_slide()
	areaChecker()
	if returning:
		returnToStart()
	

#checks if player is in spot radius	
func areaChecker():
	if position.distance_to(player.position) <= spotRadius:
		chasing = true
	else:
		if chasing == true:
			returning = true		
		chasing = false
func returnToStart():
	#returns enemy back to starting position with 3 margin of error since it will likely overshoot
	

	if position.x > startPos.x+3:
		velocity.x = -SPEED
	elif position.x < startPos.x-3:
		velocity.x = SPEED	
	else:
		returning = false
	
	dir.x = abs(velocity.x) / velocity.x
	
	
			
func animationHandler():
	var sprite = $Sprite2D
	if !dead and !taking_damage and !is_attacking:
		if dir.x == -1:
			sprite.flip_h = false
		elif dir.x == 1:
			sprite.flip_h = true
	elif !dead and taking_damage and !is_attacking:
		taking_damage = false
	elif dead and is_patrolling:
		is_patrolling = false
		
		
#patrols until player is in spot radius, then chases
func move():
	if !dead:
		if !chasing and !returning:
			patrol()
		elif chasing and !taking_damage:
			var dir_to_player = position.direction_to(player.position)*SPEED
			velocity.x = dir_to_player.x 
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage:
			var knockbackDir = position.direction_to(player.position) * knockback
			velocity.x = knockbackDir.x
		is_patrolling = true
	elif !dead:
		velocity.x = 0
		
func takeDamage(dmg:int) -> void:
	hp -= dmg
	taking_damage = true
	
	print("took dmg, hp:", hp)
	if hp <= 0:
		queue_free()
		dead = true

func patrol() -> void:

	if position.x > startPos.x + patrolRange or position.x < startPos.x - patrolRange:
		facing *= -1
		
	velocity.x = facing * SPEED
	dir.x = abs(velocity.x) / velocity.x
