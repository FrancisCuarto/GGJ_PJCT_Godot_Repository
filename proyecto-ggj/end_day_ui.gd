extends CanvasLayer


@onready var day_label = $FondoFinDia/Content/TitleLabel
@onready var money_label = $FondoFinDia/Content/MoneyLabel
@onready var continue_button = $FondoFinDia/Content/ContinueButton
@onready var audio_fin_dia: AudioStreamPlayer2D = $SonidoFinDIa

@onready var fondo: TextureRect = $FondoFinDia

var tween = Tween



func _ready():
	visible = false
	DayManager.connect("dia_finalizado", Callable(self, "_on_dia_finalizado"))
	continue_button.pressed.connect(_on_continue_pressed)
	
	# Arranca completamente negro
	fondo.modulate = Color(0, 0, 0, 1)

	# Creamos el tween
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	# Negro → imagen normal
	tween.tween_property(
		fondo,
		"modulate",
		Color(1, 1, 1, 1),
		0.8
	)



func _on_dia_finalizado():
	
	limpiar_autos_del_dia()
	
	var transition = get_tree().get_first_node_in_group("day_transition")
	if transition:
		transition.animar_fin_dia()
		
	
	
		
	visible = true
	get_tree().paused = true


	day_label.text = "Día %d finalizado" % (DayManager.dia_actual)
	money_label.text = "Dinero ganado: $%d" % MoneyManager.dinero_del_dia
	audio_fin_dia.play()

func limpiar_autos_del_dia():
	print("Limpieza total de autos")

	var autos = get_tree().get_nodes_in_group("autos")
	print("Autos encontrados:", autos.size())

	for auto in autos:
		auto.queue_free()
	
	var qm = get_tree().get_first_node_in_group("QueueManager")
	if qm:
		qm.resetear_dia()
		
		
func _on_continue_pressed():
	visible = false
	get_tree().paused = false
	DayManager.iniciar_dia()
	
	
func continuar():
	visible = false
	get_tree().paused = false
	DayManager.iniciar_dia()
	



func _on_shop_button_pressed() -> void:
	var shop = get_tree().get_first_node_in_group("shop_ui")
	if shop:
		shop.visible = true
	pass # Replace with function body.
