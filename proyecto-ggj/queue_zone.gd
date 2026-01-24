extends Node2D

@export var slot_spacing := 64
var autos_en_cola := []

func agregar_auto(auto):
	autos_en_cola.append(auto)
	actualizar_cola()

func quitar_auto(auto):
	autos_en_cola.erase(auto)
	actualizar_cola()


func actualizar_cola():
	for i in autos_en_cola.size():
		var a = autos_en_cola[i]
		a.queue_index = i
		a.target_position = global_position + Vector2(-i * slot_spacing, 0)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
