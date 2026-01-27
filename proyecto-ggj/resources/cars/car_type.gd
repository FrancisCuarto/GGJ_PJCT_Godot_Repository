extends Resource

class_name CarType

@export var nombre := "Auto Genérico"

# Movimiento
@export var speed_normal := 400.0
@export var speed_lenta := 250.0

# Gameplay
@export var paciencia_max := 10.0
@export var dinero_min := 50
@export var dinero_max := 150

# Visual
@export var sprite: Texture2D

# Tareas posibles (usa el enum Tarea del auto)
@export var tareas_posibles: Array[int] = []

# Spawn
@export_range(0.0, 1.0) var probabilidad_spawn := 1.0
