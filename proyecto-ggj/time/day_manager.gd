extends Node

# -----------------------------
# CONFIGURACIÓN
# -----------------------------

@export var duracion_dia := 30.0 # segundos
signal dia_finalizado
# -----------------------------
# ESTADO
# -----------------------------

var dia_actual := 1
var tiempo_restante := 0.0
var dia_activo := false

# -----------------------------
# READY
# -----------------------------

func _ready():
	

	iniciar_dia()

# -----------------------------
# CICLO DEL DÍA
# -----------------------------

func iniciar_dia():
	MoneyManager.iniciar_dia()
	print("Inicia el día ", dia_actual)
	tiempo_restante = duracion_dia
	dia_activo = true

func finalizar_dia():
	print("Finaliza el día ", dia_actual)
	dia_activo = false
	
	emit_signal("dia_finalizado")
	dia_actual += 1

# -----------------------------
# UPDATE
# -----------------------------

func _process(delta):
	if not dia_activo:
		return

	tiempo_restante -= delta

	if tiempo_restante <= 0:
		tiempo_restante = 0
		finalizar_dia()
