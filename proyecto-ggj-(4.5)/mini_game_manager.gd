extends Node
class_name MinigameManager

var minijuegos_desbloqueados: Array[String] = []

func desbloquear(id: String):
	if id != "" and not minijuegos_desbloqueados.has(id):
		minijuegos_desbloqueados.append(id)
		print("Minijuego desbloqueado:", id)

func esta_desbloqueado(id: String) -> bool:
	return minijuegos_desbloqueados.has(id)
