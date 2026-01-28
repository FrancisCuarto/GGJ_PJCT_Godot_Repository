extends TextureRect

signal limpiada

@export var fuerza := 0.3

func _ready():
	modulate.a = 1.0

func _on_mouse_entered():
	print("Mancha tocada")
	modulate.a -= fuerza
	if modulate.a <= 0:
		modulate.a = 0
		emit_signal("limpiada")
