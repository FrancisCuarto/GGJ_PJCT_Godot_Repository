extends CanvasLayer


@onready var day_label = $Background/Content/DayLabel
@onready var money_label = $Background/Content/MoneyLabel
@onready var continue_button = $Background/Content/ContinueButton


func _ready():
	visible = false
	DayManager.connect("dia_finalizado", Callable(self, "_on_dia_finalizado"))
	continue_button.pressed.connect(_on_continue_pressed)


func _on_dia_finalizado():
	limpiar_autos_del_dia()
	
		
	visible = true
	get_tree().paused = true


	day_label.text = "Día %d finalizado" % (DayManager.dia_actual)
	money_label.text = "Dinero ganado: $%d" % MoneyManager.dinero_del_dia


func limpiar_autos_del_dia():
	print("Limpieza total de autos")

	var autos = get_tree().get_nodes_in_group("autos")
	print("Autos encontrados:", autos.size())

	for auto in autos:
		auto.queue_free()
		
	var qm = get_tree().get_first_node_in_group("queue_manager")
	if qm:
		qm.resetear_dia()
		
		
func _on_continue_pressed():
	visible = false
	get_tree().paused = false
	DayManager.iniciar_dia()
