extends TextureRect

signal limpiada

@export var fuerza := 0.6

@export var texturas: Array[Texture2D] = []

	
func _ready():
	# Elegir textura aleatoria
	if not texturas.is_empty():
		texture = texturas.pick_random()
	modulate.a = 1.0

func _on_mouse_entered():
	print("Mancha tocada")
	modulate.a -= fuerza
	if modulate.a <= 0:
		modulate.a = 0
		emit_signal("limpiada")

func _process(delta):
	var rect = get_rect().grow(12)
	if rect.has_point(get_local_mouse_position()):
		modulate.a -= fuerza * delta * 5
