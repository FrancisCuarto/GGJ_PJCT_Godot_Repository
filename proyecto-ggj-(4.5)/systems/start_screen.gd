extends Control

@onready var label: Label = $Label
@onready var trapito_rect: TextureRect = $Background/trapito_cabeza_inicio
@onready var nombre_juego: TextureRect = $Background/nombre_juego
# o Label, si fuera Label:
# @onready var nombre_juego: Label = $Background/nombre_juego


const SMOKE_TEXTURE = preload("res://assets/inicio/HUMO.png")
var smoke_rect: TextureRect

func _ready() -> void:
	# Remove the existing static node if it exists to clean up (the one we don't want)
	if has_node("humo inicio"):
		get_node("humo inicio").queue_free()

	_setup_smoke()
	# Trapito is already in scene, just need to set initial state if needed?
	# User placed it where they want it.
	
	_animate_label()

func _setup_smoke() -> void:
	smoke_rect = TextureRect.new()
	smoke_rect.texture = SMOKE_TEXTURE
	smoke_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	smoke_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	
	var vp_size = get_viewport_rect().size
	smoke_rect.size = Vector2(vp_size.x, vp_size.y + 200)
	smoke_rect.position = Vector2(0, 0)
	smoke_rect.modulate.a = 0.8
	
	add_child(smoke_rect)
	# Ensure smoke is in front of everything except maybe label?
	# Scene has Background -> (Trapito, Casa). Label is sibling of Background.
	# We want smoke on top of Trapito/Casa but maybe behind Label?
	# Label is at index 1 (Background is 0).
	# If we add_child, it's at index 2 (top). 
	# Let's move it to simulate depth. index 1 is Label.
	move_child(smoke_rect, 1) # Put before Label
	# But Label needs to be on top.
	# Current children: Background, Label, Smoke(new).
	# Swap Label to last?
	move_child(label, get_child_count() - 1)

	# Rising animation (moving up)
	var tween = create_tween().set_loops()
	tween.tween_property(smoke_rect, "position:y", -100.0, 10.0).from(0.0)

# _setup_trapito REMOVED because we use the existing node

func _animate_label() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_property(label, "modulate:a", 1.0, 0.8)

func _input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo():
		_transition_to_menu()

func _transition_to_menu() -> void:
	set_process_input(false)
	
	var vp_size = get_viewport_rect().size
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Smoke activates: moves up and fades out
	if smoke_rect:
		tween.tween_property(smoke_rect, "position:y", -200.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).as_relative()
		tween.tween_property(smoke_rect, "modulate:a", 0.0, 2.0)
	
	# Label fades
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	# Título "PUCHITO" se desvanece
	if nombre_juego:
		tween.tween_property(
			nombre_juego,
			"modulate:a",
			0.0,
			0.8
		)

	
	# Trapito moves to the right ("walks")
	if trapito_rect:
		# MAIN MOVEMENT: Move X to the right off-screen
		tween.tween_property(trapito_rect, "position:x", vp_size.x + 200, 3.0).set_trans(Tween.TRANS_LINEAR)
		
		# BOBBING (Walking Up/Down)
		# We use a separate loop for the bobbing so it repeats efficiently
		var bob_tween = create_tween().set_loops(15)
		# Jump UP relative
		bob_tween.tween_property(trapito_rect, "position:y", -1.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).as_relative()
		# Fall DOWN relative
		bob_tween.tween_property(trapito_rect, "position:y", 1.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).as_relative()
		
		# WOBBLE (Rotation)
		# Rotate slightly back and forth
		var rock_tween = create_tween().set_loops(15)
		rock_tween.tween_property(trapito_rect, "rotation", 0.05, 0.15).as_relative()
		rock_tween.tween_property(trapito_rect, "rotation", -0.1, 0.15).as_relative() # Back past center
		rock_tween.tween_property(trapito_rect, "rotation", 0.05, 0.15).as_relative() # Return to center
		
	
	# Wait for animation then change scene
	# We wait 3.0s for the main movement
	tween.chain().tween_callback(_change_scene)

func _change_scene() -> void:
	get_tree().change_scene_to_file("res://systems/main_menu.tscn")
