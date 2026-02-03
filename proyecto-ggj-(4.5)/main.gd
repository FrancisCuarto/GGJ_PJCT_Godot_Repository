extends Node2D

@onready var music: AudioStreamPlayer = $AudioStreamPlayer
var tween = Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DayManager.iniciar_dia()
	music.volume_db = -30.0
	music.play()
	fade_in_musica()
	

			


func fade_in_musica():
	var music_tween := create_tween()
	music_tween.set_trans(Tween.TRANS_SINE)
	music_tween.set_ease(Tween.EASE_OUT)

	music_tween.tween_property(
		music,
		"volume_db",
		0.0,   # volumen final (ajustalo a gusto)
		5.0     # duración del fade
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
