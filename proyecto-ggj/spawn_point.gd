extends Marker2D

@export var car_scene: PackedScene
@export var max_cars := 0



func _on_body_entered(body):
	if body.is_in_group("auto"):
		print("VIEWPORT ENTER")
		max_cars += 1

func _on_body_exited(body):
	if body.is_in_group("auto"):
		max_cars -= 1





#spawnea los autos
func _spawn_car():
	if car_scene == null:
		push_warning("No hay escena de auto asignada")
		return
	if max_cars <= 3:
		var car_scene_instance = car_scene.instantiate()
		add_child(car_scene_instance)
		car_scene_instance.asignar_tarea_random()
	else:
		print("Slots llenos")
	







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
