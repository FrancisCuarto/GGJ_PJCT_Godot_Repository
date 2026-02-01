extends CharacterBody2D

@export var speed := 200
@export var run_speed := 500
@export var estamina_gasto_por_segundo := 20
@export var estamina_regen_por_segundo := 70.0
@export var tiempo_para_regenerar := 1.5 # segundos
var tiempo_frenado := 0.0


@onready var sprite := $Sprite2D
@onready var mask_sprite := $MaskSprite


func _physics_process(delta: float) -> void:
	var dir := Input.get_axis("left", "right")
	var corriendo := false

	# --- CORRER ---
	if Input.is_action_pressed("run") and StatsManager.estamina > 0 and dir != 0:
		corriendo = true
		tiempo_frenado = 0.0
		velocity.x = dir * run_speed
		StatsManager.estamina -= estamina_gasto_por_segundo * delta
	else:
		velocity.x = dir * speed

		# --- CONTAR TIEMPO QUIETO ---
		if dir == 0:
			tiempo_frenado += delta
		else:
			tiempo_frenado = 0.0

		# --- REGENERAR SOLO SI CUMPLE EL TIEMPO ---
		if tiempo_frenado >= tiempo_para_regenerar:
			StatsManager.estamina += estamina_regen_por_segundo * delta

	# Clamp estamina
	StatsManager.estamina = clamp(
		StatsManager.estamina,
		0,
		StatsManager.estamina_max
	)

	move_and_slide()

	# Flip horizontal
	if dir != 0:
		sprite.flip_h = dir < 0



func _process(_delta):
	if MaskManager.mascara_equipada:
		mask_sprite.texture = MaskManager.mascara_equipada.sprite
	else:
		mask_sprite.texture = null
