extends Node

# -----------------------------
# ESTADÍSTICAS BASE
# -----------------------------
@export var vida_max := 100
@export var estamina_max := 100
@export var carisma_max := 100

@onready var vida := 100
@onready var estamina := 100
@onready var carisma := 50.0





# -----------------------------
# CICLO DEL DÍA
# -----------------------------

func iniciar_dia():
	# La estamina se regenera al comenzar el día
	carisma = carisma_max 
	estamina = estamina_max
	

func iniciar_stats():
	print("INIT STATS | carisma_max:", carisma_max)
	vida = vida_max
	estamina = estamina_max
	carisma = carisma_max

func finalizar_dia():
	# Vida y carisma persisten, no se tocan
	pass

# -----------------------------
# OPERACIONES VIDA
# -----------------------------

func perder_vida(monto: int):
	vida = max(vida - monto, 0)

func curar_vida(monto: int):
	vida = min(vida + monto, vida_max)

# -----------------------------
# OPERACIONES ESTAMINA
# -----------------------------

func gastar_estamina(monto: int) -> bool:
	if estamina < monto:
		return false

	estamina -= monto
	return true

func recuperar_estamina(monto: int):
	estamina = min(estamina + monto, estamina_max)

# -----------------------------
# OPERACIONES CARISMA
# -----------------------------

func perder_carisma(monto: int):
	carisma = max(carisma - monto, 0)

func ganar_carisma(monto: int):
	carisma = min(carisma + monto, carisma_max)
