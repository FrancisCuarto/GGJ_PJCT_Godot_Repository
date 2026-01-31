extends Node
""""class_name SaveManager"""


"""SaveManager.guardar()
SaveManager.cargar()
SaveManager.hay_partida()


const SAVE_PATH := "user://savegame.json"

func hay_partida() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func guardar():
	var data := {
		"dia": DayManager.dia_actual,
		"dinero": MoneyManager.dinero,
		"mascaras_compradas": MaskManager.obtener_ids_compradas(),
		"mascara_equipada": MaskManager.obtener_id_equipada()
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

	print("Partida guardada")




func cargar():
	if not hay_partida():
		print("No hay partida para cargar")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)
	if data == null:
		push_error("Save corrupto")
		return

	DayManager.dia_actual = data.get("dia", 1)
	MoneyManager.dinero = data.get("dinero", 0)

	MaskManager.cargar_desde_save(
		data.get("mascaras_compradas", []),
		data.get("mascara_equipada", null)
	)

	print("Partida cargada")



func obtener_ids_compradas() -> Array[String]:
	var ids := []
	for mask in mascaras_compradas:
		ids.append(mask.id)
	return ids


func obtener_id_equipada() -> String:
	if mascara_equipada:
		return mascara_equipada.id
	return ""


func cargar_desde_save(ids_compradas: Array, id_equipada: String):
	mascaras_compradas.clear()
	mascara_equipada = null

	for id in ids_compradas:
		var mask = obtener_mascara_por_id(id)
		if mask:
			mascaras_compradas.append(mask)

	if id_equipada != "":
		mascara_equipada = obtener_mascara_por_id(id_equipada)"""
