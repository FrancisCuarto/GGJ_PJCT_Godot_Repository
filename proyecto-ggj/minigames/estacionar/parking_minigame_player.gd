extends CharacterBody2D
class_name PlayerCar # Añadido para identificar al jugador fácilmente

# Referencia al CollisionShape2D del auto para usar en otros scripts
@onready var car_collider: CollisionShape2D = $"CollisionShape2D"

# --- Parámetros para ajustar la conducción (puedes cambiarlos en el Inspector) ---
@export var engine_power: float = 300.0   # Fuerza de aceleración
@export var max_speed: float = 350.0      # Velocidad máxima
@export var rotation_speed: float = 1.0   # Qué tan rápido gira
@export var friction: float = 3.0         # Fricción del suelo (más alto = frena más rápido)

# Variables para guardar el estado del input
var acceleration_input: float = 0.0
var steer_input: float = 0.0


func _physics_process(delta: float) -> void:
	# 1. Leemos los inputs del jugador
	get_player_input()

	# 2. Aplicamos la rotación
	# Solo permitimos girar si el auto se está moviendo (hacia adelante o atrás)
	if velocity.length() > 10.0:
		rotation += steer_input * rotation_speed * delta 

	# 3. Calculamos la aceleración y la aplicamos
	var acceleration_vector = Vector2.UP.rotated(rotation) * acceleration_input * engine_power
	
	if acceleration_input != 0:
		# Si estamos acelerando o frenando, aplicamos la fuerza del motor
		velocity += acceleration_vector * delta
	else:
		# Si no se presiona nada, la fricción detiene el auto
		velocity = velocity.lerp(Vector2.ZERO, friction * delta)

	# 4. Limitamos la velocidad para que no exceda la máxima
	velocity = velocity.limit_length(max_speed)
	
	# 5. ¡Movemos el auto!
	move_and_slide()


func get_player_input():
	# Obtiene el input de giro usando "left" y "right"
	steer_input = Input.get_axis("left", "right")
	
	# Obtiene el input de aceleración usando "down" y "up"
	acceleration_input = Input.get_axis("down", "up")
