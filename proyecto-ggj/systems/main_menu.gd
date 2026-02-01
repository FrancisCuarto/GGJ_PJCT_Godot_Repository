extends CanvasLayer

@onready var btn_jugar = $VBoxContainer/ButtonJugar
@onready var btn_continuar = $VBoxContainer/ButtonContinuar
@onready var btn_opciones = $VBoxContainer/ButtonOpciones
@onready var btn_salir = $VBoxContainer/ButtonSalir

func _ready():
	btn_jugar.pressed.connect(_on_jugar)
	btn_continuar.pressed.connect(_on_continuar)
	btn_opciones.pressed.connect(_on_opciones)
	btn_salir.pressed.connect(_on_salir)

	# Si no hay partida guardada
	#btn_continuar.disabled = not SaveManager.hay_partida()



func _on_jugar():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_continuar():
	SaveManager.cargar()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_opciones():
	print("Opciones (WIP)")

func _on_salir():
	get_tree().quit()
