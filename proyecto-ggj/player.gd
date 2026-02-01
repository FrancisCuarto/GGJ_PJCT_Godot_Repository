extends CharacterBody2D

@export var speed := 200
@export var run_speed := 500
@export var estamina_gasto_por_segundo := 20
@export var estamina_regen_por_segundo := 70.0
@export var tiempo_para_regenerar := 1.5 # segundos
@onready var animated_sprite := $AnimatedSprite2D
var mask_offset_base: Vector2
var tiempo_frenado := 0.0
@export var sonidos_golpe: Array[AudioStream] = []
@onready var audio_golpe: AudioStreamPlayer2D = $AudioGolpe





@export var mask_offset_right := Vector2(60, 0)
@export var mask_offset_left := Vector2(20, 0)


@onready var sprite := $Sprite2D
@onready var mask_sprite := $MaskSprite




func _ready():
	mask_offset_base = mask_sprite.position
	actualizar_mascara()





func _physics_process(delta: float) -> void:
	var dir := Input.get_axis("left", "right")
	var corriendo := false
	
		
	

	# --- CORRER ---
	if Input.is_action_pressed("run") and StatsManager.estamina > 0 and dir != 0:
		corriendo = true
		animated_sprite.play("run")
		tiempo_frenado = 0.0
		velocity.x = dir * run_speed
		StatsManager.estamina -= estamina_gasto_por_segundo * delta
	else:
		velocity.x = dir * speed
		animated_sprite.play("walk")

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
	if dir == 0:
		animated_sprite.play("idle")
	move_and_slide()
		
	# Flip horizontal
	if dir != 0:
		sprite.flip_h = dir < 0
		animated_sprite.flip_h = dir > 0
	
	if Input.is_action_pressed("pegar"):
		animated_sprite.play("pegar")
		reproducir_golpe()
	
	actualizar_mascara()

	#if dir > 0:
		#mask_sprite.position = mask_offset_base + Vector2(-10, 0)
	#else:
		#mask_sprite.position = mask_offset_base + Vector2(20, 0)
	#if dir == 0 and mask_sprite.flip_h:
		#mask_sprite.position = mask_offset_base + Vector2(20,0)
	#elif dir == 0 and !mask_sprite.flip_h:
		#mask_sprite.position = mask_offset_base + Vector2(0,0)
	
	
func _process(_delta):
	if MaskManager.mascara_equipada:
		mask_sprite.texture = MaskManager.mascara_equipada.sprite
	else:
		mask_sprite.texture = null


func actualizar_mascara():
	if sprite.flip_h:
		# Mirando a la izquierda
		mask_sprite.position = mask_offset_base + mask_offset_left
	else:
		# Mirando a la derecha
		mask_sprite.position = mask_offset_base + mask_offset_right

func reproducir_golpe():
	if sonidos_golpe.is_empty():
		return

	var sonido: AudioStream = sonidos_golpe.pick_random()
	audio_golpe.stream = sonido
	audio_golpe.play()
