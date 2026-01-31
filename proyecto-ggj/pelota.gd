extends Area2D

@export var velocidad_horizontal_max := 300.0 # Rango de movimiento lateral
@export var aceleracion := 40.0
@export var fuerza_rebote := 350.0

# Cambiamos a Vector2 para manejar X e Y [1]
var velocity := Vector2.ZERO
var activa := true

signal reboto
signal perdio

func _ready():
	# Es fundamental para que los números aleatorios cambien en cada partida [3, 4]
	randomize()

func _process(delta):
	if not activa:
		return

	# Aplicamos gravedad solo al eje Y [5, 6]
	velocity.y += aceleracion * delta
	
	# Actualizamos la posición usando el vector completo [7, 8]
	position += velocity * delta

func _input_event(viewport, event, shape_idx):
	if not activa:
		return

	if event is InputEventMouseButton and event.pressed:
		# Salto hacia arriba (Y negativo en Godot) [9, 10]
		velocity.y = -fuerza_rebote
		
		# Dirección random en el eje X usando randf_range [11, 12]
		velocity.x = randf_range(-velocidad_horizontal_max, velocidad_horizontal_max)
		
		# Aumentar dificultad
		fuerza_rebote += 50.0
		aceleracion += 20.0
		
		emit_signal("reboto")
		
func _on_area_entered(area):
	if area.name == "Piso":
		activa = false
		velocity = Vector2.ZERO # Detener movimiento
		emit_signal("perdio")
