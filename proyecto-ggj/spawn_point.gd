extends Marker2D

@export var car_scene: PackedScene
@export var max_cars := 5


#spawnea los autos
func _spawn_car():
	if car_scene == null:
		push_warning("No hay escena de auto asignada")
		return
	var car_scene_instance = car_scene.instantiate()
	add_child(car_scene_instance)
	car_scene_instance.asignar_tarea_random()
	






# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#timer que maneja cuanto tarda en aparecer cada auto
func _on_timer_timeout() -> void:
	_spawn_car()
	pass # Replace with function body.
