extends Control


signal terminado(exito: bool)

@export var porcentaje_necesario := 1
@export var mancha_scene: PackedScene
@export var min_manchas := 5
@export var max_manchas := 7




var progreso := 0.0
var manchas: Array[Node] = []

func _ready():
	CameraManager.enter_minigame()

	print("Parabrisas size:", $Parabrisas.size)
	print("ManchaLayer size:", $Parabrisas/ManchaLayer.size)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(
		preload("res://assets/minigame_textures/limpieza_textures/trapo.png"),
		Input.CURSOR_ARROW,
		Vector2(32, 10) # centro del trapo
	)
	spawnear_manchas()
	manchas = $Parabrisas/ManchaLayer.get_children()




func spawnear_manchas():
	var cantidad = randi_range(min_manchas, max_manchas)

	for i in range(cantidad):
		var mancha = mancha_scene.instantiate()
		$Parabrisas/ManchaLayer.add_child(mancha)

		mancha.position = posicion_aleatoria()
		mancha.connect("limpiada", Callable(self, "actualizar_progreso"))

	actualizar_progreso()
	
"""func posicion_aleatoria() -> Vector2:
	var rect = $Parabrisas/ManchaLayer.get_rect()
	return Vector2(
	randf_range(rect.position.x, rect.position.x + rect.size.x),
	randf_range(rect.position.y, rect.position.y + rect.size.y)
	)"""

func posicion_aleatoria() -> Vector2:
	var area_size = $Parabrisas/ManchaLayer.size
	var mancha_size = mancha_scene.instantiate().size

	var margen := 400.0

	return Vector2(
		randf_range(
			margen,
			area_size.x - mancha_size.x - margen
		),
		randf_range(
			margen,
			area_size.y - mancha_size.y - margen
		)
	)
	
	
	
func actualizar_progreso():
	var limpias := 0
	for mancha in manchas:
		if mancha.modulate.a <= 0:
			limpias += 1

	progreso = float(limpias) / manchas.size()
	$Progreso.value = progreso * 100

	if progreso >= porcentaje_necesario:
		terminar(true)
		
		
		
func terminar(exito: bool):
	Input.set_custom_mouse_cursor(null)
	print("Minijuego emite terminado:", exito)
	emit_signal("terminado", exito)
	queue_free()
