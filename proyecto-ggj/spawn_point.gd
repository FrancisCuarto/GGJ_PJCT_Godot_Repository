extends Marker2D

@export var car_scene: PackedScene
@export var queue_manager: NodePath
@export var Player: NodePath
@export var car_types: Array[CarType]



#spawnea los autos
func _spawn_car():
	if car_scene == null:
		push_warning("No hay escena de auto asignada")
		return

	var qm = get_node(queue_manager)
	if qm == null:
		return

	if not qm.hay_espacio():
		return

	var car = car_scene.instantiate()

	# 🔑 ACÁ ENTRA EL RESOURCE
	car.car_type = elegir_car_type()

	get_parent().add_child(car)

	# referencias
	car.queue_manager = qm
	car.player = get_node(Player) # ajustá path si hace falta

	# registro y slot
	qm.registrar_auto(car)
	qm.asignar_slot(car)

	# AHORA sí, con car_type ya asignado
	car.asignar_tarea_random()
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




func elegir_car_type() -> CarType:
	var total := 0.0
	for c in car_types:
		total += c.probabilidad_spawn

	var r := randf() * total
	var acc := 0.0

	for c in car_types:
		acc += c.probabilidad_spawn
		if r <= acc:
			return c

	return car_types[0]





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#timer que maneja cuanto tarda en aparecer cada auto
func _on_timer_timeout() -> void:
	var qm = get_node(queue_manager)

	if qm == null:
		push_error("QueueManager no asignado en SpawnPoint")
		return

	if qm.hay_espacio():
		_spawn_car()
