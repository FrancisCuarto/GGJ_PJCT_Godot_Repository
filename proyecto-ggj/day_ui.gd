extends Panel


@onready var day_label = $DayLabel
@onready var time_label = $TimeLabel
@onready var money_label = $MoneyLabel

func _process(delta):
	# Día actual
	day_label.text = "Día %d" % DayManager.dia_actual
	money_label.text = "Dinero: $%d" % MoneyManager.dinero_total


	# Tiempo restante
	var tiempo = int(DayManager.tiempo_restante)
	var minutos = tiempo / 60
	var segundos = tiempo % 60


	time_label.text = "Tiempo: %02d:%02d" % [minutos, segundos]
