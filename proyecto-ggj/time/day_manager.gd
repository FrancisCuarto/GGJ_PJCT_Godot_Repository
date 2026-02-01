extends Node

# -----------------------------
# CONFIGURACIÓN
# -----------------------------
# Avance por bloques
const BLOQUE_HORA := 0.1 # 30 minutos

var acumulador_tiempo := 0.0

@export var duracion_dia_real :=1.0 # segundos reales (3 minutos)
signal dia_finalizado

# Horario laboral
const HORA_INICIO_JORNADA := 6.0
const HORA_FIN_JORNADA := 18.0


# -----------------------------
# ESTADO
# -----------------------------

var dia_actual := 1
var hora_actual := 0.0 # 0.0 → 24.0
var dia_activo := false

# -----------------------------
# READY
# -----------------------------

func _ready():
	await get_tree().process_frame
	StatsManager.iniciar_stats()
	iniciar_dia()

# -----------------------------
# CICLO DEL DÍA
# -----------------------------

func iniciar_dia():
	
	StatsManager.iniciar_dia()
	MoneyManager.iniciar_dia()
	print("Inicia el día ", dia_actual)

	hora_actual = HORA_INICIO_JORNADA
	acumulador_tiempo = 0.0
	dia_activo = true

	var transition = get_tree().get_first_node_in_group("day_transition")
	if transition:
		transition.animar_inicio_dia(dia_actual)

func finalizar_dia():
	print("Finaliza el día ", dia_actual)

	dia_activo = false
	emit_signal("dia_finalizado")
	dia_actual += 1

# -----------------------------
# UPDATE
# -----------------------------

func obtener_hora_formateada() -> String:
	var horas = int(hora_actual)
	var minutos = int((hora_actual - horas) * 60)
	return "%02d:%02d" % [horas, minutos]


func _process(delta):
	if not dia_activo:
		return

	acumulador_tiempo += delta

	var duracion_bloque_real = duracion_dia_real / 24.0

	if acumulador_tiempo >= duracion_bloque_real:
		acumulador_tiempo = 0.0
		hora_actual += BLOQUE_HORA

		# Clamp de seguridad
		if hora_actual >= HORA_FIN_JORNADA:
			hora_actual = HORA_FIN_JORNADA
			finalizar_dia()
