extends Control


signal terminado(exito: bool)

@export var porcentaje_necesario := 1
@export var mancha_scene: PackedScene
@export var min_manchas := 5
@export var max_manchas := 7



var progreso := 0.0
var manchas: Array[Node] = []

func _ready():
	spawnear_manchas()
	manchas = $ManchaLayer.get_children()


func spawnear_manchas():
	var cantidad = randi_range(min_manchas, max_manchas)

	for i in range(cantidad):
		var mancha = mancha_scene.instantiate()
		$ManchaLayer.add_child(mancha)

		mancha.position = posicion_aleatoria()
		mancha.connect("limpiada", Callable(self, "actualizar_progreso"))

	actualizar_progreso()
	
func posicion_aleatoria() -> Vector2:
	var rect = $Parabrisas.get_rect()
	return Vector2(
	randf_range(rect.position.x, rect.position.x + rect.size.x),
	randf_range(rect.position.y, rect.position.y + rect.size.y)
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
	print("Minijuego emite terminado:", exito)
	emit_signal("terminado", exito)
	queue_free()
