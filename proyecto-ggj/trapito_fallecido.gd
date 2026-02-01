extends Node2D

@onready var label_si = $si
@onready var label_no = $Label2

var selection = true # true = SI, false = NO

func _ready():
	add_to_group("game_over_screen")
	update_visuals()

func _process(delta):
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up"):
		selection = true
		update_visuals()
	elif Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_down"):
		selection = false
		update_visuals()
		
	if Input.is_action_just_pressed("ui_accept"):
		if selection:
			# Restart Fight
			get_tree().change_scene_to_file("res://minigames/fight/fight_scene.tscn")
		else:
			# Return to Main
			get_tree().change_scene_to_file("res://main.tscn")

func update_visuals():
	if selection:
		label_si.modulate = Color(1, 1, 0) # Yellow/Highlight
		label_no.modulate = Color(1, 1, 1) # Normal
	else:
		label_si.modulate = Color(1, 1, 1) # Normal
		label_no.modulate = Color(1, 1, 0) # Yellow/Highlight
