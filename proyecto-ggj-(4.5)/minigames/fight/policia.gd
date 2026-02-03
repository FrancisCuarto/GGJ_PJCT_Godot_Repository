extends CharacterBody2D

const SPEED = 150.0
const ATTACK_RANGE = 80.0
const ATTACK_COOLDOWN = 1.5
const ATTACK_DURATION = 0.5

@onready var sprite = $Sprite2D
@onready var player = get_node("../Trapito") # Assumes Trapito is a sibling node named "Trapito"

# Load textures
var texture_normal = preload("res://assets/policia/POLICIA_NORMAL.png")
var texture_attack = preload("res://assets/policia/POLICIA_GOLPE.png")

var can_attack = true
var is_attacking = false
var attack_timer_duration = 0.0

func _ready():
	sprite.texture = texture_normal
	
	# SETUP FOR FUTURE ANIMATIONS:
	# Similar to Trapito, use AnimatedSprite2D for smooth animations.
	
func _physics_process(delta):
	if is_attacking:
		attack_timer_duration -= delta
		if attack_timer_duration <= 0:
			is_attacking = false
			sprite.texture = texture_normal
			# After attack ends, start cooldown
			await get_tree().create_timer(ATTACK_COOLDOWN).timeout
			can_attack = true
		return # Don't move while attacking
		
	if player:
		var direction = global_position.direction_to(player.global_position)
		var distance = global_position.distance_to(player.global_position)
		
		# Flip sprite to face player
		if direction.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
			
		if distance > ATTACK_RANGE:
			velocity = direction * SPEED
		else:
			velocity = Vector2.ZERO
			if can_attack:
				attack()
				
		move_and_slide()

func attack():
	can_attack = false
	is_attacking = true
	attack_timer_duration = ATTACK_DURATION
	sprite.texture = texture_attack
	# Logic to check if player was hit would go here
