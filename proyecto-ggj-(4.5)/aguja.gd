extends Control

@onready var aguja: TextureRect = $Aguja

func _ready():
	# Esperamos un frame para que el size sea correcto
	await get_tree().process_frame
	aguja.pivot_offset = Vector2(aguja.size.x / 2, aguja.size.y)
	actualizar_reloj(DayManager.hora_actual)

func _process(delta):
	actualizar_reloj(DayManager.hora_actual)

func actualizar_reloj(hora: float):
	# hora entre 0 y 24
	var angulo_objetivo := (hora / 24.0) * TAU - TAU / 4
	aguja.rotation = lerp_angle(aguja.rotation, angulo_objetivo, 0.1)
