extends Node


# -----------------------------
# ESTADO
# -----------------------------


var dinero_total := 0
var dinero_del_dia := 0


# -----------------------------
# CICLO DEL DÍA
# -----------------------------


func iniciar_dia():
	dinero_del_dia = 0


func finalizar_dia():
	# por ahora no hace nada extra
	pass


# -----------------------------
# OPERACIONES
# -----------------------------


func agregar_dinero(monto: int):
	dinero_total += monto
	dinero_del_dia += monto


func gastar_dinero(monto: int) -> bool:
	if dinero_total < monto:
		return false


	dinero_total -= monto
	return true
