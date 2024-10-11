extends CharacterBody2D

enum playerState {Idle, Move, Jump, Dash, Wallslide, Grapple, Attack}

var state

@export var speed = 50
@export var accel = 50
@export var decel = 50
@export var jumpPow = 50
@export var gravMult = 2
@export var fastFallMultiplier = 2.0
@export var maxJumps = 2
var coyote = false
var timesJumped = 0

func _ready() -> void:
	state = playerState.Idle


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		state = playerState.Jump
		
	if is_on_floor():
		timesJumped = 0
		#dirty way of starting this timer, starts timer every 1/60th of a second until off the ground
		$CoyoteTime.start()
		coyote = true
	print(coyote)
	
	#changes gravity based on whether the player is rising or falling
	if velocity.y < 0:
		velocity += get_gravity() * delta * gravMult
	else:
		velocity += get_gravity() * delta * gravMult * fastFallMultiplier
	
	match state:
		playerState.Idle:
			if Input.is_anything_pressed():
				state = playerState.Move
		playerState.Move:
			movement(delta)
		playerState.Jump:
			jumpHandle(delta)
			movement(delta)
		playerState.Dash:
			pass
		playerState.Grapple:
			pass
		playerState.Attack:
			pass
	
	move_and_slide()
	#print(state)
			
func movement(delta: float) -> void:
	#gravity
	
	var direction = Input.get_axis("left","right")
	velocity.x = move_toward(velocity.x, speed*direction, accel)
	
	if direction:
		$Sprite2D.flip_h = velocity.x >= 0
	else:
		velocity.x = move_toward(velocity.x, 0, decel)
	
	if velocity.x == 0 and is_on_floor():
		state = playerState.Idle
		return
	
	
	
func jumpHandle(delta: float) -> void:
	if not canJump():
		state = playerState.Move
		return
	timesJumped += 1
	if Input.is_action_pressed("jump"):
		velocity.y = move_toward(velocity.y, -jumpPow, jumpPow/2)
		print(velocity.y)
	else:
		state = playerState.Move
	
func canJump() -> bool:
	return is_on_floor() or doubleJump() or coyote
	
func doubleJump() -> bool:
	return maxJumps - timesJumped > 0


func _on_coyote_time_timeout() -> void:
	coyote = false
	print("timeout")
