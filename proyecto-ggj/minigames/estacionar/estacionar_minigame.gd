extends CanvasLayer

signal minijuego_terminado(exito: bool)

@export var slots: Array[Marker2D] = []
@export var texturas: Array[Sprite2D] = []
@export var scena_estacionamiento: PackedScene
@export var auto_estatico: PackedScene
var estacionamiento: Estacionamiento
@onready var progress_bar = $ProgressBar
var progreso_actual := 0.0
@onready var player_car: PlayerCar = $ParkingMinigamePlayer


func asignar_estacionamiento():
	var estacionamiento_objetivo = slots.pick_random()
	var estacionamiento_instance := scena_estacionamiento.instantiate()
	estacionamiento = estacionamiento_instance
	
	# Conectamos la señal del estacionamiento individual a una función de este script
	estacionamiento_instance.connect("carro_perfectamente_estacionado", _on_parking_spot_success)
	
	estacionamiento_objetivo.add_child(estacionamiento_instance)
	
	for slot in slots:
		if slot != estacionamiento_objetivo:
			var auto_estatico_instance := auto_estatico.instantiate()
			slot.add_child(auto_estatico_instance)


# Esta función se activa cuando el estacionamiento individual detecta el éxito
func _on_parking_spot_success(_carro):
	emitir_exito_y_cerrar()
	emit_signal("minijuego_terminado", true)
	queue_free() # Se autodestruye al terminar


func emitir_exito_y_cerrar():
	print("MINIJUEGO: emitiendo señal de ÉXITO")
	emit_signal("minijuego_terminado",true)
	queue_free()
	

func terminar_con_fracaso():
	emit_signal("minijuego_terminado",false)
	queue_free()


	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# LA SOLUCIÓN: Hacemos que este nodo y sus hijos ignoren la pausa del juego.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_forzar_process_always(self)
	asignar_estacionamiento()
	pass # Replace with function body.

func _forzar_process_always(node: Node):
	node.process_mode = Node.PROCESS_MODE_ALWAYS
	#node.physics_process_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	for child in node.get_children():
		_forzar_process_always(child)

func _process(delta):
	if not is_instance_valid(player_car):
		return
	if not is_instance_valid(estacionamiento):
		return

	var progreso = estacionamiento.calcular_progreso(player_car)
	progreso_actual = lerp(progreso_actual, progreso, delta * 6.0)

	progress_bar.value = progreso_actual * 100.0

	if progreso_actual >= 0.99:
		terminar(true)

func terminar(exito: bool):
	emit_signal("minijuego_terminado", exito)
	queue_free()

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
