extends Resource

class_name CarType

@export var nombre := "Auto Genérico"




#Sonido
@export var motor_loop: AudioStream
@export var motor_volumen := 8.0
@export var bocina: AudioStream
@export var sonido_enojo: AudioStream
@export var motor_start_sounds: Array[AudioStream] = []
@export var motor_start_volumen := 4.0
@export	var audio_motor: AudioStream
@export var sprite_frames: SpriteFrames
@export var anim_idle := "idle"
@export var anim_move := "move"
@export var sprite_scale := Vector2.ONE

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
