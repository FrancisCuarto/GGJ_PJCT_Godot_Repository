extends Node



# Paths a los .tres
const MASK_PATHS := [
	"res://resources/mascaras/mascara_comandantefort.tres",
	"res://resources/mascaras/mascara_messi.tres"
]
var todas_las_mascaras: Array[Mask] = []
var mascaras_compradas: Array[Mask] = []
var mascara_equipada: Mask = null

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
		mascara_equipada = obtener_mascara_por_id(id_equipada)

func comprar_mascara(mask: Mask) -> bool:
	if mask in mascaras_compradas:
		return false

	if MoneyManager.dinero_total < mask.precio:
		return false

	MoneyManager.gastar_dinero(mask.precio)
	mascaras_compradas.append(mask)
	return true

func _ready():
	# Cargar todas las máscaras al iniciar el juego
	for path in MASK_PATHS:
		var mask: Mask = load(path)
		if mask:
			todas_las_mascaras.append(mask)
		else:
			push_error("No se pudo cargar máscara: " + path)

func obtener_mascara_por_id(id: String) -> Mask:
	for mask in todas_las_mascaras:
		if mask.id == id:
			return mask
	return null



func equipar_mascara(mask: Mask):
	if mask in mascaras_compradas:
		mascara_equipada = mask
	if mask.desbloquea_minijuego != "":
		MiniGameManager.desbloquear(mask.desbloquea_minijuego)
