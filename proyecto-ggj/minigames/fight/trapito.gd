extends CharacterBody2D

const SPEED = 200.0
const ATTACK_DURATION = 0.5
const DAMAGE = 10

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var animated_sprite := $AnimatedSprite2D

# Load textures
var texture_normal = preload("res://assets/trapito/TRAPITO_NORMAL.png")
var texture_attack = preload("res://assets/trapito/TRAPITO_PIÑA.png")

# Attack State
var is_attacking = false
var attack_timer = 0.0

# Hitbox
var hitbox: Area2D
var stats

func _ready():
	# Initialize StatsManager as a component
	var stats_script = load("res://stats_manager.gd")
	stats = stats_script.new()
	add_child(stats)
	stats.iniciar_stats()
	stats.connect("on_health_changed", _on_health_changed)
	stats.connect("on_death", _on_death)
	
	sprite.texture = texture_normal
	
	# Create Hitbox programmatically
	hitbox = Area2D.new()
	hitbox.name = "Hitbox"
	var hitbox_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 50
	hitbox_shape.shape = shape
	hitbox.add_child(hitbox_shape)
	add_child(hitbox)
	
	# Hitbox settings
	hitbox.monitoring = false # Disabled by default
	hitbox.monitorable = false
	hitbox.position = Vector2(50, 0) # Offset to the right (arm)
	hitbox.connect("body_entered", _on_hitbox_body_entered)

func _physics_process(delta):
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			end_attack()
	
	# Handle Attack
	if Input.is_action_just_pressed("ui_accept") and not is_attacking: # Spacebar or Enter
		start_attack()

	# Get the input direction and handle height/width movement
	var direction_x = Input.get_axis("left", "right")
	var direction_y = Input.get_axis("up", "down")
	
	if direction_x != 0:
		animated_sprite.play("walk")
	if direction_y != 0:
		animated_sprite.play("walk")
	
	if direction_x:
		velocity.x = direction_x * SPEED
		# Flip sprite and hitbox
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

func start_attack():
	is_attacking = true
	attack_timer = ATTACK_DURATION
	sprite.texture = texture_attack
	
	# Enable Hitbox
	hitbox.monitoring = true
	
func end_attack():
	is_attacking = false
	sprite.texture = texture_normal
	hitbox.monitoring = false

func _on_hitbox_body_entered(body):
	if body == self:
		return
		
	if body.has_method("get_stats"):
		var enemy_stats = body.get_stats()
		if enemy_stats and enemy_stats.has_method("take_damage"):
			enemy_stats.take_damage(DAMAGE)
			print("Hit enemy! Damage: ", DAMAGE)
	# Also check if body has the component directly or via a wrapper
	elif body.has_node("StatsManager"): # Dynamic check
		body.get_node("StatsManager").take_damage(DAMAGE)
		print("Hit enemy node! Damage: ", DAMAGE)

# Stats Manager Interface
func get_stats():
	return stats

func _on_health_changed(current, max_val):
	print("Trapito Health: ", current, "/", max_val)
	# Feedback: Flash Red
	modulate = Color(1, 0, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.2)

func _on_death():
	print("Trapito Died!")
	set_physics_process(false)
	modulate = Color(0.2, 0.2, 0.2)
	
	# Wait a bit before showing game over
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://trapito_fallecido.tscn")
