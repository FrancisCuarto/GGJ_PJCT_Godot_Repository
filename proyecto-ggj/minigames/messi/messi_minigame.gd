extends CanvasLayer

@onready var pelota = $Pelota
@onready var progress_bar = $ProgressBar

signal minijuego_terminado(exito: bool)

var progreso := 300
const PROGRESO_POR_REBOTE := 135


func _process(delta):
	progreso -= delta * 75
	progreso = max(progreso, 0)
	progress_bar.value = progreso

	if progreso <= 0:
		terminar(false)


func _forzar_process_always(node: Node):
	node.process_mode = Node.PROCESS_MODE_ALWAYS
	#node.physics_process_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	for child in node.get_children():
		_forzar_process_always(child)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_forzar_process_always(self)
	get_tree().paused = false

	pelota.reboto.connect(_on_rebote)
	pelota.perdio.connect(_on_perdio)

	progress_bar.value = 0

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(
		preload("res://assets/minigame_textures/texturas/BOTAA_FUTBOL.png"),
		Input.CURSOR_ARROW,
		Vector2(32, 10) # centro del trapo
	)


func _on_rebote():
	progreso += PROGRESO_POR_REBOTE
	progreso = min(progreso, 1000)

	progress_bar.value = progreso

	if progreso >= 600:
		terminar(true)
		exito()


func exito():
	pelota.activa = false
	print("MINIJUEGO COMPLETADO")

	await get_tree().create_timer(0.5).timeout
	queue_free()


func _on_perdio():
	print("MINIJUEGO FALLADO")

	emit_signal("minijuego_terminado", false)

	


func terminar(exito: bool):
	Input.set_custom_mouse_cursor(null)
	emit_signal("minijuego_terminado", exito)
	queue_free()


func _on_pelota_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
