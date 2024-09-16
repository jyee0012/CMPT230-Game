extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var jump_count = 0
@export var jumps_allowed = 2
@export var wall_jump = true
var facing = 1
@export var can_dash = true
var dashing = false
var death_count = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0
	if is_on_wall() and wall_jump:
		jump_count = 0
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and jump_count < jumps_allowed:
		velocity.y = JUMP_VELOCITY
		jump_count+=1
		#A wall jump that the player jumps away from in order to gain height (can be overridden by directional input while jumping)
		if is_on_wall() and wall_jump:
			velocity.x = -facing * SPEED * 10
		# death handling
	if (position.y > 1000):
		set_position(Vector2(0, 38))
		death_count+=1
		print(str(["Death: ", death_count]))
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	if Input.is_action_just_pressed("shift") and can_dash:
		velocity.x = facing * SPEED * 10
		dashing = true
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
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()
