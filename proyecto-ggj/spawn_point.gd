extends Marker2D

@export var car_scene: PackedScene
@export var queue_manager: NodePath
@export var player: NodePath



#spawnea los autos
func _spawn_car():
	if car_scene == null:
		push_warning("No hay escena de auto asignada")
		return
	var qm = get_node(queue_manager)
	
	# 🔑 ACÁ está la pregunta que vos preguntaste
	if qm.autos_activos.size() >= qm.max_autos:
		return

	var car_scene_instance = car_scene.instantiate()
	get_parent().add_child(car_scene_instance)
	car_scene_instance.asignar_tarea_random()
	car_scene_instance.queue_manager = qm


	qm.registrar_auto(car_scene_instance)
	qm.asignar_slot(car_scene_instance)

	car_scene_instance.player = get_node("Player") # ajustá el path si hace falta
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
