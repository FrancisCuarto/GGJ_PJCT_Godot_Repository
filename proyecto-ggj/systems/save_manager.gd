extends Node



#SaveManager.guardar()
#SaveManager.cargar()
#SaveManager.hay_partida()

var mascaras_compradas := MaskManager.mascaras_compradas
var mascara_equipada := MaskManager.mascara_equipada

const SAVE_PATH := "user://savegame.json"

func hay_partida() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func guardar():
	var data := {
		"dia": DayManager.dia_actual,
		"dinero": MoneyManager.dinero_total,
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
