extends Area2D

@export var velocidad_horizontal_max := 300.0
@export var aceleracion := 40.0
@export var fuerza_rebote := 350.0

var velocity := Vector2.ZERO
var activa := true
var screen_size: Vector2

signal reboto
signal perdio

func _ready():
	# Obtiene el tamaño inicial del área visible
	screen_size = get_viewport_rect().size 
	# Asegura que randf_range sea realmente aleatorio
	randomize() 

func _physics_process(delta):
	if not activa:
		return

	# Aplicar gravedad (eje Y)
	velocity.y += aceleracion * delta
	
	# Mover la pelota en ambos ejes
	position += velocity * delta 
	
	# Lógica de rebote lateral (Eje X)
	var margen = 20.0 
	if position.x <= margen:
		velocity.x = abs(velocity.x) # Asegura dirección a la derecha
		position.x = margen
	elif position.x >= screen_size.x - margen:
		velocity.x = -abs(velocity.x) # Asegura dirección a la izquierda
		position.x = screen_size.x - margen

func _input_event(viewport, event, shape_idx):
	if not activa:
		return

	if event is InputEventMouseButton and event.pressed:
		# Salto hacia arriba (Y negativo en Godot)
		velocity.y = -fuerza_rebote
		
		# Dirección aleatoria en X usando randf_range
		velocity.x = randf_range(-velocidad_horizontal_max, velocidad_horizontal_max)
		
		# Aumentar dificultad progresivamente
		fuerza_rebote += 50.0
		aceleracion += 20.0
		
		emit_signal("reboto")
		
func _on_area_entered(area):
	if area.name == "Piso":
		activa = false
		velocity = Vector2.ZERO # Detener movimiento al morir
		emit_signal("perdio")
