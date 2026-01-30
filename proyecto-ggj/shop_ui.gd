extends CanvasLayer



@export var mascaras_disponibles: Array[Mask]

@onready var list = $Panel/MaskList
@onready var nombre = $Panel/MaskList/Preview/LabelNombre
@onready var precio = $Panel/MaskList/Preview/LabelPrecio
@onready var boton = $Panel/MaskList/Preview/ButtonComprar

var mascara_seleccionada: Mask = null



func _on_button_salir_pressed():
	print("boton presionado")
	#var day_manager = get_tree().get_first_node_in_group("day_manager")
	#if day_manager:
		#day_manager.iniciar_dia()
	
	#DayManager.iniciar_dia()
	visible = false
	var continuar = get_tree().get_first_node_in_group("end_day")
	if continuar:
		continuar.continuar()
		
	
	
	
func _ready():
	visible = false
	for mask in mascaras_disponibles:
		var b = Button.new()
		b.text = mask.nombre
		b.pressed.connect(func(): seleccionar(mask))
		list.add_child(b)


func seleccionar(mask: Mask):
	mascara_seleccionada = mask

	nombre.text = mask.nombre
	precio.text = "$" + str(mask.precio)

	if mask in MaskManager.mascaras_compradas:
		boton.text = "Equipar"
	else:
		boton.text = "Comprar"

	boton.disabled = false
	boton.pressed.disconnect_all()
	boton.pressed.connect(comprar_actual)




func comprar_actual():
	if mascara_seleccionada == null:
		return

	if mascara_seleccionada in MaskManager.mascaras_compradas:
		MaskManager.equipar_mascara(mascara_seleccionada)
	else:
		var ok = MaskManager.comprar_mascara(mascara_seleccionada)
		if ok:
			boton.text = "Equipar"
