extends CanvasLayer

@onready var vbox: VBoxContainer = $VBoxContainer
@onready var btn_jugar = $VBoxContainer/ButtonJugar
@onready var btn_continuar = $VBoxContainer/ButtonContinuar
@onready var btn_opciones = $VBoxContainer/ButtonOpciones
@onready var btn_salir = $VBoxContainer/ButtonSalir
@onready var music: AudioStreamPlayer = $AudioStreamPlayer

@export var sonido_golpe: Array[AudioStream] = []

var tween: Tween
var posicion_final: Vector2

func _ready():
	
		# Música: arrancar en silencio y hacer fade in
	music.volume_db = -30.0
	music.play()
	fade_in_musica()

	# Conectar botones
	btn_jugar.pressed.connect(_on_jugar)
	btn_continuar.pressed.connect(_on_continuar)
	btn_opciones.pressed.connect(_on_opciones)
	btn_salir.pressed.connect(_on_salir)

	# Guardamos la posición final
	posicion_final = vbox.position

	# Arranca fuera de pantalla (arriba)
	vbox.position.y = -vbox.size.y - 500

	# Animar entrada
	animar_entrada()

func animar_entrada():
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		vbox,
		"position",
		posicion_final,
		4.0
	)
func fade_in_musica():
	var music_tween := create_tween()
	music_tween.set_trans(Tween.TRANS_SINE)
	music_tween.set_ease(Tween.EASE_OUT)

	music_tween.tween_property(
		music,
		"volume_db",
		9.0,   # volumen final (ajustalo a gusto)
		3.0     # duración del fade
	)

# ------------------------
# Botones
# ------------------------

func _on_jugar():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_continuar():
	SaveManager.cargar()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_opciones():
	print("Opciones (WIP)")

func _on_salir():
	get_tree().quit()
