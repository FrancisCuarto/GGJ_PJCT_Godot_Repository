extends Node

var mascaras_compradas: Array[Mask] = []
var mascara_equipada: Mask = null


func comprar_mascara(mask: Mask) -> bool:
	if mask in mascaras_compradas:
		return false

	if MoneyManager.dinero_total < mask.precio:
		return false

	MoneyManager.gastar_dinero(mask.precio)
	mascaras_compradas.append(mask)
	return true


func equipar_mascara(mask: Mask):
	if mask in mascaras_compradas:
		mascara_equipada = mask
	if mask.desbloquea_minijuego != "":
		MiniGameManager.desbloquear(mask.desbloquea_minijuego)
