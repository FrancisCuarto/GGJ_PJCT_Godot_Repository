extends Area2D

@export var velocidad := 200.0
@export var aceleracion := 40.0
@export var fuerza_rebote := 350.0

var velocidad_actual := 0.0
var activa := true

signal reboto
signal perdio


func _process(delta):
	if not activa:
		return

	velocidad_actual += aceleracion * delta
	position.y += velocidad_actual * delta

func _input_event(viewport, event, shape_idx):
	if not activa:
		return

	if event is InputEventMouseButton and event.pressed:
		velocidad_actual = -fuerza_rebote
		fuerza_rebote += 150       # rebotes más violentos
		aceleracion += 50
		velocidad += 600            # cae cada vez más rápido
		emit_signal("reboto")
		
func _on_area_entered(area):
	print("piso")

	if area.name == "Piso":
		activa = false
		emit_signal("perdio")
		
