extends CanvasLayer

@onready var pelota = $Pelota
@onready var progress_bar = $ProgressBar

signal minijuego_terminado(exito: bool)

var progreso := 0
const PROGRESO_POR_REBOTE := 12


func _ready():
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
	progreso = min(progreso, 100)

	progress_bar.value = progreso

	if progreso >= 100:
		exito()


func exito():
	pelota.activa = false
	print("MINIJUEGO COMPLETADO")

	emit_signal("minijuego_terminado", true)

	await get_tree().create_timer(0.5).timeout
	get_tree().paused = true
	queue_free()



func _on_perdio():
	print("MINIJUEGO FALLADO")

	emit_signal("minijuego_terminado", false)

	await get_tree().create_timer(0.5).timeout
	get_tree().paused = true
	queue_free()
