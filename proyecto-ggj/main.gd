extends Node2D

const PoliceScript = preload("res://systems/police_bg.gd")
const PoliceTexture = preload("res://assets/policia/POLICIA_ANIMACION.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DayManager.iniciar_dia()
	setup_police_bg()

func setup_police_bg() -> void:
	if not has_node("background"):
		print("Warning: 'background' node not found, adding police to Main")
		var police = create_police_node()
		add_child(police)
	else:
		var police = create_police_node()
		$background.add_child(police)

func create_police_node() -> Sprite2D:
	var police = Sprite2D.new()
	police.texture = PoliceTexture
	police.set_script(PoliceScript)
	
	# CONFIGURATION: Adjust these if the animation looks wrong
	police.hframes = 14 # 14 frames as per user request
	police.vframes = 1
	
	police.name = "BackgroundPolice"
	police.scale = Vector2(3, 3) # Scaled up to be visible and fit pixel art style
	police.z_index = 1 # Update z_index if needed to be in front/behind props
	
	return police

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
