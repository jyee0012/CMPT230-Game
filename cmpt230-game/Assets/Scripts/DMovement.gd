extends CharacterBody2D

enum playerState {Idle, Move, Airborne, Dash, Wallslide, Grapple, Attack}
enum directions {Left,Right,Up,Down}
var state
var facing

@export var speed = 50
@export var accel = 50
@export var decel = 50
@export var jumpPow = 50
@export var gravMult = 2
@export var fastFallMultiplier = 2.0
@export var WalljumpUnlocked = false
var maxJumps = 0
@export var maxDashes = 0
@export var dashSpeed = 50
var coyote = false
var timesJumped = 0
var timesDashed = 0
@export var hasGrapple = true
@export var grappleSpeed = 200
var startPos

func _ready() -> void:
	state = playerState.Idle
	facing = directions.Right
	WalljumpUnlocked = true
	$Sounds/Walking.play()
	startPos = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	match state:
		playerState.Idle:
			$Sounds/Walking.stream_paused = true
			jumpHandle(delta)
			movement(delta)
			changeState()
			dashHandle()
		playerState.Move:
			$Sounds/Walking.stream_paused = false
			jumpHandle(delta)
			movement(delta)
			changeState()
			dashHandle()
		playerState.Airborne:
			$Sounds/Walking.stream_paused = true
			jumpHandle(delta)
			movement(delta)
			changeState()
			dashHandle()
		playerState.Dash:
			dashHandle()
		playerState.Wallslide:
			wallHandle()
			changeState()
			movement(delta)
		playerState.Grapple:
			grappleHandle()
		playerState.Attack:
			pass
	#print(state)
	deathHandle()
	move_and_slide()
	
#handles character movement and state swapping for movement related states (idle, airborne, moving)
func movement(delta: float) -> void:
	var direction = Input.get_axis("left","right")
	velocity.x = move_toward(velocity.x, speed*direction, accel)
	
	
	
	if direction:
		if velocity.x >= 0:
			facing = directions.Right
		else:
			facing = directions.Left
	else:
		velocity.x = move_toward(velocity.x, 0, decel)
	
	$Sprite2D.flip_h = facing == directions.Right

#handles everything to do with jumping
func jumpHandle(delta: float) -> void:
	#changes gravity based on whether the player is rising or falling
	if velocity.y < 0:
		velocity += get_gravity() * delta * gravMult
	else:
		velocity += get_gravity() * delta * gravMult * fastFallMultiplier
		
	#print(coyote)
	
	if is_on_floor():
		coyote = true
		timesJumped = 0
	elif $CoyoteTime.is_stopped() and coyote:
		$CoyoteTime.start()
		
	
	
	if Input.is_action_just_pressed("jump") and canJump():
		timesJumped += 1
		coyote = false
		velocity.y = -jumpPow
		#print(velocity.y)
	if not Input.is_action_pressed("jump") and velocity.y < -(jumpPow/2):
		velocity.y = -(jumpPow/2)

func canJump() -> bool:
	return is_on_floor() or doubleJump() or coyote

func doubleJump() -> bool:
	return maxJumps - timesJumped > 0

func _on_coyote_time_timeout() -> void:
	coyote = false
	#print("timeout")

func dashHandle() -> void:
	if Input.is_action_just_pressed("dash") and timesDashed < maxDashes:
		state = playerState.Dash
	else: return
	
	$Sounds/Dash.play()
	timesDashed += 1
	if timesDashed == 1:
		$DashCooldown.start()
	#velocity.y = 0
	if facing == directions.Left:
		velocity.x -= dashSpeed 
	else:
		velocity.x += dashSpeed
	if is_on_floor():
		state = playerState.Move
	else:
		state = playerState.Airborne

func _on_dash_cooldown_timeout() -> void:
	timesDashed = 0
	$Sprite2D.use_parent_material = false
	$FlashTime.start()

func _on_flash_time_timeout() -> void:
	$Sprite2D.use_parent_material = true

func wallHandle() -> void:
	#print(velocity)
	if velocity.x == 0:
		velocity.y = 0
	
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		coyote = true
		$CoyoteTime.start
		 
	if Input.is_action_just_pressed("jump"):
		#print("walljump")
		if facing == directions.Left:
			velocity = Vector2(jumpPow*2, -jumpPow/1.5)
			facing = directions.Right
		else:
			velocity = Vector2(-jumpPow*2, -jumpPow/1.5)
			facing = directions.Left

func changeState() -> void:
	if is_on_floor():
		if velocity.x == 0:
			state = playerState.Idle
		else:
			state = playerState.Move
	elif is_on_wall() and WalljumpUnlocked:
		state = playerState.Wallslide
	else:
		state = playerState.Airborne
	if hasGrapple and Input.is_action_just_pressed("grapple"):
		state = playerState.Grapple

func grappleHandle() -> void:
	var face = facing
	if facing == 0: face = -1
	velocity += Vector2(face, -1) * grappleSpeed
	if is_on_wall() or Input.is_action_just_pressed("jump"):
		state = playerState.Idle
		if is_on_wall():
			#print_debug("on wall")
			velocity.y = 0

func deathHandle() -> void:
	if Input.is_action_just_pressed("debug"):
		position = startPos

func _on_game_data_dash_collect() -> void:
	maxDashes += 1
