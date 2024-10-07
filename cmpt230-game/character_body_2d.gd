extends CharacterBody2D

enum PlayerState {Idle, Dash, Jump, Walk, Climb, Grapple}

var player: PlayerState = PlayerState.Idle
const SPEED = 300.0
const JUMP_VELOCITY = -1200.0
# jumping
var jump_count = 0
@export var jumps_allowed = 2
@export var wall_jump = true
@export var wall_climb = false
var facing = 1
# dashing
@export var can_dash = true
@export var dash_allowed = 5
var dash_count = 0
var dashing = false
# grapple
@export var has_grapple = true
var grapple_range = 50
var grapple_speed = 500.0
var grapple_active = false
var timeStamp;
var death_count = 0

func _physics_process(delta: float) -> void:
	if player == PlayerState.Grapple:
		velocity += Vector2(facing, -1) * grapple_speed
		print_debug(velocity)
		if velocity.x <= grapple_speed and delta > timeStamp:
			velocity = Vector2.ZERO
			velocity.y = 0 
		if is_on_wall() or Input.is_action_just_pressed("jump"):
			player = PlayerState.Idle
			if is_on_wall():
				#print_debug("on wall")
				velocity.y = 0
		
		move_and_slide()
	elif player == PlayerState.Dash:
		print_debug("dash")
	elif player == PlayerState.Climb:
		print_debug("climb")
		JumpHandler()
		DeathHandler()	
		GetInput()
	#elif player == PlayerState.Jump:
		#print_debug("jump")
	#elif player == PlayerState.Walk:
		#print_debug("walk")
	#elif player == PlayerState.Idle:
		#print_debug("idle")	
	else:
		# Add the gravity.
		if not is_on_floor(): 
			if not (wall_climb && is_on_wall()):
				velocity += get_gravity() * delta * 3
		else:
			CountReset()
		JumpHandler()
		move_and_slide() #moved here to give prio to jump in order to prevent hugging the wall while wall jumping
		DeathHandler()	
		GetInput()
	if Input.is_action_just_pressed("grapple") and has_grapple:
		player = PlayerState.Grapple
		timeStamp = delta + 2
		print_debug("attempted to grapple.")
func CountReset() -> void:
	jump_count = 0
	dash_count = 0
	
func GetInput() -> void:
	#check if walking and not jumping then play sound if not playing
	if velocity.y == 0 and Input.get_axis("left", "right"):
		#print_debug("walk")
		if not $walk.playing:
			$walk.play()
	else:
		#print_debug("not walking")
		if $walk.playing:
			$walk.stop()
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_just_pressed("dash") and can_dash and dash_count < dash_allowed:
		velocity.x = facing * SPEED * 10
		$dash.play()
		dashing = true
		dash_count+=1
	else:
		if (dashing):
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if velocity.x == 0:
				dashing = false
		else:
			var direction := Input.get_axis("left", "right")
			if direction:
				facing = direction
				velocity.x = direction * SPEED
				$Sprite2D.flip_h = velocity.x <= 0
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				
				
func JumpHandler() -> void:
	if is_on_wall() and wall_jump:
		CountReset()
		if Input.is_action_just_pressed("jump") and jump_count < jumps_allowed:
			velocity.y = JUMP_VELOCITY
			velocity.x = -facing * SPEED * 10
			jump_count+=1
	# Handle jump.
	if Input.is_action_just_pressed("jump") and jump_count < jumps_allowed:
		velocity.y = JUMP_VELOCITY
		jump_count+=1
		#A wall jump that the player jumps away from in order to gain height 
		# (can be overridden by directional input while jumping)
		if is_on_wall() and wall_jump:
			velocity.x = -facing * SPEED * 10
func DeathHandler() -> void:
	# death handling
	if (position.y > 1000):
		$death.play()
		set_position(Vector2(0, 38))
		death_count+=1
		print(str(["Death: ", death_count]))	
