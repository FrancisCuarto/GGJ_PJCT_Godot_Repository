extends Panel


@onready var day_label = $DayLabel
@onready var money_label = $MoneyLabel

func _process(delta):
	# Día actual
	day_label.text = "Día %d" % DayManager.dia_actual
	money_label.text = "%d" % MoneyManager.dinero_total
