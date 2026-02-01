extends Control

@onready var vida_bar = $Vida
@onready var estamina_bar = $Estamina
@onready var carisma_bar = $Carisma




func _ready():
	await get_tree().process_frame
	actualizar_stats()

func _process(delta):
	actualizar_stats()

func actualizar_stats():
	vida_bar.max_value = StatsManager.vida_max
	vida_bar.value = StatsManager.vida

	estamina_bar.max_value = StatsManager.estamina_max
	estamina_bar.value = StatsManager.estamina

	carisma_bar.max_value = StatsManager.carisma_max
	carisma_bar.value = StatsManager.carisma
