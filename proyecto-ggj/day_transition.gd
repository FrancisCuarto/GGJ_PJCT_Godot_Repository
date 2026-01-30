extends CanvasLayer

@onready var fade_panel: ColorRect = get_node("Root/FadePanel")

var tween: Tween


func _ready():
	print("DayTransition READY")
	if fade_panel == null:
		push_error("FadePanel no encontrado")
		return

	# Arranca siempre en negro
	fade_panel.modulate.a = 1.0


func animar_fin_dia():
	if tween:
		tween.kill()

	# Oscurecer la pantalla
	tween = create_tween()
	tween.tween_property(fade_panel, "modulate:a", 1.0, 0.8)


func animar_inicio_dia(dia: int):
	print("Animando inicio del día", dia)

	if tween:
		tween.kill()

	# Forzar estado inicial oscuro
	fade_panel.modulate.a = 1.0

	# Fade in (oscuro → claro)
	tween = create_tween()
	tween.tween_property(fade_panel, "modulate:a", 0.0, 5.0)
