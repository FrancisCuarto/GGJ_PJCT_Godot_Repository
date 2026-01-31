extends CanvasLayer

signal minijuego_terminado(exito: bool)

@export var slots: Array[Marker2D] = []
@export var texturas: Array[Sprite2D] = []
@export var scena_estacionamiento: PackedScene
@export var auto_estatico: PackedScene
@export var player: PackedScene
var estacionamiento: Marker2D


func asignar_estacionamiento():
	var estacionamiento_objetivo = slots.pick_random()
	var estacionamiento_instance := scena_estacionamiento.instantiate()
	
	# Conectamos la señal del estacionamiento individual a una función de este script
	estacionamiento_instance.connect("carro_perfectamente_estacionado", _on_parking_spot_success)
	
	estacionamiento_objetivo.add_child(estacionamiento_instance)
	
	for slot in slots:
		if slot != estacionamiento_objetivo:
			var auto_estatico_instance := auto_estatico.instantiate()
			slot.add_child(auto_estatico_instance)


# Esta función se activa cuando el estacionamiento individual detecta el éxito
func _on_parking_spot_success(_carro):
	emit_signal("minijuego_terminado", true)
	queue_free() # Se autodestruye al terminar


func asignar_player():
	var player_instance = player.instantiate()
	$PlayerSpawn.add_child(player_instance)
	pass
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# LA SOLUCIÓN: Hacemos que este nodo y sus hijos ignoren la pausa del juego.
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	asignar_player()
	asignar_estacionamiento()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
