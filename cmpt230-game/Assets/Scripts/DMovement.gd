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
@export var hasGrapple = false
@export var grappleSpeed = 200
@export var grapple_range = 600
var startPos
var sliding = false
var hp 
var maxHp = 5
var canTakeDamage:bool = true
var inArea:bool = false



@export var canAttack = false
@export var attackRange = 500
@export var attackDmg = 1


#hp ui
@onready var Heart1 = $Control/HBoxContainer/Panel1
@onready var Heart2 = $Control/HBoxContainer/Panel2
@onready var Heart3 = $Control/HBoxContainer/Panel3
@onready var Heart4 = $Control/HBoxContainer/Panel4
@onready var Heart5 = $Control/HBoxContainer/Panel5

func _ready() -> void:
	
	GameData.playerBody = self
	state = playerState.Idle
	facing = directions.Right
	WalljumpUnlocked = true
	$Sounds/Walking.play()#walking sfx is paused whenever in idle state and unpaused when walking
	startPos = position
	hp = maxHp
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	#print("(",velocity.x, ", ", velocity.y,")")
	
	
	match state:
		playerState.Idle:
			$Sounds/Walking.stream_paused = true
			$Sprite2D.play("Idle")
			jumpHandle(delta)
			movement(delta)
			changeState()
			dashHandle()
		playerState.Move:
			$Sounds/Walking.stream_paused = false
			$Sprite2D.play("Run")
			jumpHandle(delta)
			movement(delta)
			changeState()
			dashHandle()
		playerState.Airborne:
			$Sounds/Walking.stream_paused = true
			if $Sprite2D.animation != "Jump":
				$Sprite2D.play("Jump")
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
	
	attackHandle()
	takingDmg()
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
		sliding = false
		timesJumped = 0
	elif $Timers/CoyoteTime.is_stopped() and coyote:
		$Timers/CoyoteTime.start()
		
	
	
	if Input.is_action_just_pressed("jump") and canJump():
		timesJumped += 1
		coyote = false
		velocity.y = -jumpPow
		#print(velocity.y)
	if not Input.is_action_pressed("jump") and velocity.y < -(jumpPow/2.0):
		velocity.y = -(jumpPow/2.0)

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
		$Timers/DashCooldown.start()
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
	$Timers/FlashTime.start()

func _on_flash_time_timeout() -> void:
	$Sprite2D.use_parent_material = true

func wallHandle() -> void:
	#print(velocity)
	if $Timers/WallTime.is_stopped() and not sliding:
		$Timers/WallTime.start() 
		
	
	if velocity.x == 0:
		if sliding:
			velocity.y = 20
		else:
			velocity.y = 0
	
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		coyote = true
		$Timers/CoyoteTime.start
		 
	if Input.is_action_just_pressed("jump"):
		$Sprite2D.play("Jump")
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
	var space_rid = get_world_2d().space
	var space_state = PhysicsServer2D.space_get_direct_state(space_rid)
	var target = Vector2(position.x + face*grapple_range, position.y -grapple_range)
	var query = PhysicsRayQueryParameters2D.create(position,target)
	var result = space_state.intersect_ray(query)
	
	if result:
	#	print("hit at point ", result.position)
		velocity += Vector2(face, -1) * grappleSpeed
		$Line2D.add_point(position)
		$Line2D.add_point(target)
	#	draw_line(position,target,Color.BROWN,2)
	else:
		state = playerState.Idle
			
	if is_on_wall() or Input.is_action_just_pressed("jump"):
		state = playerState.Idle
		if is_on_wall():
			#print_debug("on wall")
			velocity.y = 0

func deathHandle() -> void:
	
	position = startPos
	velocity = Vector2.ZERO
	hp = maxHp
		
func attackHandle() -> void:
	if Input.is_action_just_pressed("attack") and canAttack:
		canAttack = false
		$Timers/CooldownTimer.start()
		var hitbox
		if facing == directions.Right:
			hitbox = $ShapeCastRight
		elif facing == directions.Left:
			hitbox = $ShapeCastLeft
		if hitbox.is_colliding():
			if hitbox.get_collider(0).is_in_group("Enemies"):
				hitbox.get_collider(0).takeDamage(5)
				

func _on_cooldown_timer_timeout() -> void:
	canAttack = true
func _on_game_data_dash_collect() -> void:
	maxDashes += 1

func _on_wall_time_timeout() -> void:
	sliding = true

func _on_game_data_hp_collect() -> void:
	playerUpdateHp()
func _on_game_data_wing_collect() -> void:
	maxJumps += 1
func _on_game_data_whip_collect() -> void:
	canAttack = true
	hasGrapple = true
	print("can attack")
func playerUpdateHp(n:int = 1) -> void:
	hp += n
	if (hp > maxHp):
		hp = maxHp
	if (hp <= 0):
		deathHandle()
	print("hp update:", hp)
	
	Heart1.visible = hp >= 1
	Heart2.visible = hp >= 2
	Heart3.visible = hp >= 3
	Heart4.visible = hp >= 4
	Heart5.visible = hp >= 5
	

func takeDamageCooldown(val):
	canTakeDamage = false
	await get_tree().create_timer(val).timeout
	canTakeDamage = true
func playerResetHp() -> void:
	hp = maxHp	
	
	#checks whether hurtbox has been entered
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		inArea = true

#once hurtbox has been entered, player will continue to lose health until 
#it is left		
func takingDmg():
	if inArea:
		if canTakeDamage:			
			playerUpdateHp(-1)
			print("took dmg   new hp: ",hp)
			takeDamageCooldown(1)


func _on_hurtbox_body_exited(body: Node2D) -> void:
	inArea = false 
