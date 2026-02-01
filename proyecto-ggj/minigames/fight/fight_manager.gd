extends Node2D

@onready var player = $Trapito
@onready var health_bar = $CanvasLayer/ProgressBar

func _ready():
	# Wait for player to initialize stats
	await get_tree().process_frame
	
	if player.has_method("get_stats"):
		var stats = player.get_stats()
		health_bar.max_value = stats.max_health
		health_bar.value = stats.health
		
		stats.connect("on_health_changed", _on_player_health_changed)

func _on_player_health_changed(current, max_val):
	health_bar.value = current
