extends CharacterBody2D

const SPEED = 200.0
const ATTACK_DURATION = 0.5

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var animated_sprite := $AnimatedSprite2D

# Load textures
var texture_normal = preload("res://assets/trapito/TRAPITO_NORMAL.png")
var texture_attack = preload("res://assets/trapito/TRAPITO_PIÑA.png")

var is_attacking = false
var attack_timer = 0.0

func _ready():
	# Initial setup
	sprite.texture = texture_normal
	
	# SETUP FOR FUTURE ANIMATIONS:
	# To add more frames, replace the simple texture swap with an AnimatedSprite2D.
	# 1. Add an AnimatedSprite2D node to the scene.
	# 2. Create a SpriteFrames resource.
	# 3. Add animations (e.g., "idle", "run", "attack").
	# 4. In code, use `animated_sprite.play("animation_name")`.

func _physics_process(delta):
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			sprite.texture = texture_normal
	
	# Handle Attack
	if Input.is_action_just_pressed("ui_accept") and not is_attacking: # Spacebar or Enter
		attack()

	# Get the input direction and handle height/width movement
	var direction_x = Input.get_axis("left", "right")
	var direction_y = Input.get_axis("up", "down")
	
	if direction_x != 0:
		animated_sprite.play("walk")
	if direction_y != 0:
		animated_sprite.play("walk")
	
	if direction_x:
		velocity.x = direction_x * SPEED
		# Flip sprite based on direction
		if direction_x < 0:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction_y:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	if direction_x == 0:
		animated_sprite.play("idle")

		
	# Flip horizontal
	if direction_x != 0:
		sprite.flip_h = direction_x < 0
		animated_sprite.flip_h = direction_x > 0
	
	
	if Input.is_action_pressed("pegar"):
		animated_sprite.play("pegar")
	
	move_and_slide()

func attack():
	is_attacking = true
	attack_timer = ATTACK_DURATION
	sprite.texture = texture_attack
	# If you want to spawn a hitbox or deal damage, do it here.
