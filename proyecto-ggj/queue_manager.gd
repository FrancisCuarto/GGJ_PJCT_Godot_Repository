extends Node2D


# Cantidad máxima de autos activos (en cola + yéndose)
@export var max_autos := 3

# Slots físicos (Marker2D)
var slots: Array[Marker2D] = []

# Autos actualmente activos
var autos_activos := []


func _ready() -> void:
	# Tomamos todos los Marker2D hijos como slots
	for child in get_children():
		if child is Marker2D:
			slots.append(child)


# -----------------------------
# REGISTRO DE AUTOS
# -----------------------------
func registrar_auto(auto) -> void:
	if not autos_activos.has(auto):
		autos_activos.append(auto)
	print("Autos activos:", autos_activos.size())


func remover_auto(auto) -> void:
	autos_activos.erase(auto)
	print("Autos activos:", autos_activos.size())


func hay_espacio() -> bool:
	return autos_activos.size() < max_autos


# -----------------------------
# SLOTS
# -----------------------------
func asignar_slot(auto) -> bool:
	# Busca el primer slot libre
	for slot in slots:
		if not _slot_ocupado(slot):
			_ocupar_slot(slot, auto)
			return true
	return false


func liberar_slot(auto) -> void:
	# El auto libera su slot (si tenía)
	if auto.slot_actual != null:
		auto.slot_actual = null
		


# -----------------------------
# HELPERS
# -----------------------------
func _slot_ocupado(slot: Marker2D) -> bool:
	for a in autos_activos:
		if a.slot_actual == slot:
			return true
	return false


func _ocupar_slot(slot: Marker2D, auto) -> void:
	auto.slot_actual = slot
	auto.ir_a_slot(slot.global_position)
