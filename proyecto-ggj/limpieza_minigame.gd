extends Control


signal terminado(exito: bool)

@export var porcentaje_necesario := 0.8

var progreso := 0.0
var manchas: Array[Node] = []

func _ready():
	manchas = $ManchaLayer.get_children()


func _on_mouse_entered():
	modulate.a -= 0.1
	
	
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
	emit_signal("terminado", exito)
	queue_free()
