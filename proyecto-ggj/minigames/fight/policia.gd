extends CharacterBody2D

const SPEED = 130.0
const ATTACK_RANGE = 150.0
const ATTACK_COOLDOWN = 1.5
const ATTACK_DURATION = 0.5
const DAMAGE = 15

@onready var sprite = $Sprite2D
@onready var target = get_node("../Trapito") # Target the player (Trapito)

# Stats Manager Component
var stats: Node

# Textures
var texture_normal = preload("res://assets/policia/POLICIA_NORMAL.png")
var texture_attack = preload("res://assets/policia/POLICIA_GOLPE.png")

var can_attack = true
var is_attacking = false
var attack_timer = 0.0

func _ready():
	# Initialize StatsManager as a component
	var stats_script = load("res://stats_manager.gd")
	stats = stats_script.new()
	stats.name = "StatsManager" # Explicit name for finding
	add_child(stats)
	stats.iniciar_stats()
	stats.connect("on_health_changed", _on_health_changed)
	stats.connect("on_death", _on_death)
	
	sprite.texture = texture_normal

func _physics_process(delta):
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			sprite.texture = texture_normal
			# After attack ends, start cooldown
			await get_tree().create_timer(ATTACK_COOLDOWN).timeout
			can_attack = true
		return # Don't move while attacking
		
	if target and stats.health > 0:
		var direction = global_position.direction_to(target.global_position)
		var distance = global_position.distance_to(target.global_position)
		
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
	attack_timer = ATTACK_DURATION
	sprite.texture = texture_attack
	
	# Simple proximity hit check (since we are close)
	# For better accuracy, we could use a hitbox here too, but simple distance check works for enemy AI
	if target and global_position.distance_to(target.global_position) <= ATTACK_RANGE + 20:
		if target.has_method("get_stats"):
			target.get_stats().take_damage(DAMAGE)


# Stats interface
func get_stats():
	return stats

func _on_health_changed(current, max_val):
	print("Policia Health: ", current, "/", max_val)
	# Feedback: Flash Red and shake
	modulate = Color(1, 0, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.2)

func _on_death():
	print("Policia Defeated!")
	set_physics_process(false)
	sprite.modulate = Color(0.5, 0.5, 0.5, 0.5)
