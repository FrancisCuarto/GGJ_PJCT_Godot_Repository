extends Node

# -----------------------------
# ESTADÍSTICAS BASE
# -----------------------------


signal on_health_changed(current_health, max_health)
signal on_death()

@onready var vida_max := 100
@onready var estamina_max := 100
@onready var carisma_max := 50.0

# Alias for English usage requested by user
var max_health: int:
	get: return vida_max
	set(value): vida_max = value

var vida := vida_max
var estamina := estamina_max
var carisma := carisma_max

# Alias for English usage
var health: int:
	get: return vida
	set(value):
		vida = value
		on_health_changed.emit(vida, vida_max)
		if vida <= 0:
			on_death.emit()

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
	on_health_changed.emit(vida, vida_max)
	if vida <= 0:
		on_death.emit()

# Alias for English usage
func take_damage(amount: int):
	perder_vida(amount)

func curar_vida(monto: int):
	vida = min(vida + monto, vida_max)
	on_health_changed.emit(vida, vida_max)

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
