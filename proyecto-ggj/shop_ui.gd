extends CanvasLayer

@export var mascaras_disponibles: Array[Mask]

@onready var list = $Panel/MaskList
@onready var nombre = $Panel/MaskList/Preview/LabelNombre
@onready var precio = $Panel/MaskList/Preview/LabelPrecio
@onready var boton = $Panel/MaskList/Preview/ButtonComprar
@onready var icono = $Panel/MaskList/Preview/IconoMascara

var mascara_seleccionada: Mask = null


func _ready():
	visible = false

	# El botón se conecta UNA sola vez
	boton.pressed.connect(comprar_actual)
	boton.disabled = true

	for mask in mascaras_disponibles:
		var b = Button.new()
		b.text = mask.nombre
		b.pressed.connect(func(): seleccionar(mask))
		list.add_child(b)


func _on_button_salir_pressed():
	print("boton presionado")

	DayManager.iniciar_dia()
	visible = false

	var continuar = get_tree().get_first_node_in_group("end_day")
	if continuar:
		continuar.continuar()


func seleccionar(mask: Mask):
	mascara_seleccionada = mask

	nombre.text = mask.nombre
	precio.text = "$" + str(mask.precio)
	
	# 👇 MOSTRAR IMAGEN
	if mask.icono:
		icono.texture = mask.icono
		icono.visible = true
	else:
		icono.texture = null
		icono.visible = false

	if mask in MaskManager.mascaras_compradas:
		boton.text = "Equipar"
	else:
		boton.text = "Comprar"

	boton.disabled = false


func comprar_actual():
	print("CLICK EN COMPRAR")

	if mascara_seleccionada == null:
		return

	if mascara_seleccionada in MaskManager.mascaras_compradas:
		MaskManager.equipar_mascara(mascara_seleccionada)
		print("Máscara equipada")
	else:
		var ok = MaskManager.comprar_mascara(mascara_seleccionada)
		if ok:
			boton.text = "Equipar"
			print("Máscara comprada")
