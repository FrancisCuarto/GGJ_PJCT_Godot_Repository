extends CharacterBody2D


@export var speed_normal := 400
@export var speed_lenta := 250
@export var paciencia := 10.0
@export var car_type: CarType
@onready var label_tarea = $LabelTarea
@onready var patience_bar = $PatienceBar
@onready var label_interactuar = $LabelInteractuar
@onready var screen_notifier = $ScreenNotifier
@onready var audio_motor := $AudioMotor
@onready var audio_motor_start := $AudioMotorStart
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
#@onready var audio_bocina := $AudioBocina
#@onready var audio_enojo := $AudioEnojo

var paciencia_activa := false
var current_speed: float
var stoped := 0
var slot_actual = null
var target_position: Vector2
var esperando_en_slot := false
var estado := Estado.ESPERANDO
var queue_manager = null
var player: Node2D = null
var dinero_a_pagar := 0
var motor_start_elegido: AudioStream = null
var motor_encendido := false








#--------------------------------------------------------------
#CONTROL DE ESTADOS
enum Estado {
	ESPERANDO,
	LIMPIANDO,
	ESTACIONADO,
	ESPERANDO_COBRO,
	ENOJADO,
	YENDOSE
}



#CONTROL DE TAREAS
enum Tarea {
	ESTACIONAR, 
	LIMPIAR,
	PAGAR,
	MESSI,
	NADA
}

var tarea := Tarea.LIMPIAR

#--------------------------------------------------------------
#ACTUALIZA EL COLOR DE LA BARRA DE PACIENCIA
func actualizar_color_paciencia():
	var ratio = paciencia / patience_bar.max_value

	if ratio > 0.6:
		patience_bar.modulate = Color.GREEN
	elif ratio > 0.3:
		patience_bar.modulate = Color.YELLOW
	else:
		patience_bar.modulate = Color.RED
#--------------------------------------------------------------


	
func asignar_tarea_random():
	if label_tarea == null:
		return

	if car_type.tareas_posibles.is_empty():
		tarea = Tarea.NADA
		return

	var tareas_validas: Array[int] = []

	for t in car_type.tareas_posibles:
		match t:
			Tarea.MESSI:
				# 👉 solo puede entrar si está desbloqueado
				if MiniGameManager.esta_desbloqueado("messi_minigame"):
					# 👉 probabilidad de aparición
					if randf() < 0.2: # 20%
						tareas_validas.append(t)
			_:
				tareas_validas.append(t)

	if tareas_validas.is_empty():
		tarea = Tarea.NADA
		return

	tarea = tareas_validas.pick_random()

	label_tarea.text = Tarea.keys()[tarea]

	match tarea:
		Tarea.LIMPIAR:
			label_tarea.modulate = Color.CYAN
		Tarea.ESTACIONAR:
			label_tarea.modulate = Color.GREEN
		Tarea.PAGAR:
			label_tarea.modulate = Color.YELLOW
		Tarea.MESSI:
			label_tarea.modulate = Color.ORANGE


#------------------------------------------------------------------
#ELIMINA EL AUTO CUANDO LA PACIENCIA SE ACABA
func irse_enojado():
	if estado == Estado.YENDOSE:
		return
	arrancar_motor()
	estado = Estado.YENDOSE

	paciencia_activa = false
	label_tarea.visible = false
	patience_bar.visible = false

	estado = Estado.YENDOSE

	# 🔑 ACÁ ESTÁ LA CLAVE
	if queue_manager:
		queue_manager.remover_auto(self)

	# liberar slot
	if queue_manager:
		queue_manager.liberar_slot(self)

	target_position = global_position + Vector2(2000, 0)
	current_speed = speed_normal
	
	
func ir_a_slot(pos: Vector2):
	target_position = pos
	estado = Estado.ESPERANDO
	current_speed = speed_lenta
	
func irse():
	arrancar_motor()
	audio_motor.pitch_scale = 1.1
	estado = Estado.YENDOSE
	paciencia_activa = false
	label_tarea.visible = false
	patience_bar.visible = false
	queue_manager.liberar_slot(self)
	
	if queue_manager:
		queue_manager.remover_auto(self)

	# liberar slot
	if queue_manager:
		queue_manager.liberar_slot(self)

	target_position = global_position + Vector2(5000, 0)
	current_speed = speed_normal

	# Move off-screen to be removed later
	target_position = global_position + Vector2(2000, 0)
	current_speed = speed_normal

	# después camina y se borra fuera de pantalla

func _on_screen_notifier_screen_exited():
	if estado == Estado.YENDOSE:
		queue_free()
		print("auto eliminado")


func _process(delta):

	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		interactuar()

	#TIMER DE PACIENCIA
	if esperando_en_slot and paciencia_activa:
		paciencia -= delta
		patience_bar.value = paciencia
		actualizar_color_paciencia()
	if paciencia <= 0:
			paciencia = 0
			irse_enojado()
	
	
func _ready():
	if car_type == null:
		push_error("Auto sin CarType asignado")
		return

	# 🎲 Elegir sonido de encendido random (una sola vez)
	if not car_type.motor_start_sounds.is_empty():
		motor_start_elegido = car_type.motor_start_sounds.pick_random()

	# 🔊 Audio motor start
	if audio_motor_start and motor_start_elegido:
		audio_motor_start.stream = motor_start_elegido
		audio_motor_start.volume_db = car_type.motor_start_volumen

	# 🔊 Audio motor loop
	if audio_motor and car_type.motor_loop:
		audio_motor.stream = car_type.motor_loop
		audio_motor.volume_db = car_type.motor_volumen

		if audio_motor.stream is AudioStreamWAV:
			audio_motor.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

	# 📊 Stats
	dinero_a_pagar = randi_range(
		car_type.dinero_min,
		car_type.dinero_max
	)

	speed_normal = car_type.speed_normal
	speed_lenta = car_type.speed_lenta
	paciencia = car_type.paciencia_max

	# 🎨 VISUAL (AnimatedSprite2D)
	if car_type.sprite_frames:
		sprite.sprite_frames = car_type.sprite_frames
		sprite.scale = car_type.sprite_scale
		sprite.play(car_type.anim_idle)
	else:
		push_warning("CarType sin sprite_frames")

	# 🧠 UI
	patience_bar.max_value = paciencia
	patience_bar.value = paciencia
	patience_bar.visible = false
	label_interactuar.visible = false
	label_tarea.visible = false

	current_speed = speed_normal
	target_position = global_position
	paciencia_activa = false





func _physics_process(delta):
	match estado:
		Estado.ESPERANDO, Estado.YENDOSE:
			mover_hacia_target()
			
	pass

	move_and_slide()
	
	

func cobrar():
	$AudioStreamPlayer2D.play()
	MoneyManager.agregar_dinero(dinero_a_pagar)
	print("Auto pagó $", dinero_a_pagar)
	irse()	
	
func mover_hacia_target():
	var dir = target_position - global_position
	
	if dir.length() > 5:
		velocity = dir.normalized() * current_speed
		if not motor_encendido:
			arrancar_motor()
			motor_encendido = true
			
		if sprite.animation != car_type.anim_move:
			sprite.play(car_type.anim_move)
			
	else:
		# llegó al marker
		velocity = Vector2.ZERO

		if estado == Estado.ESPERANDO and not paciencia_activa:
			al_llegar_al_slot()
		
		if sprite.animation != car_type.anim_idle:
			sprite.play(car_type.anim_idle)
			
		if estado == Estado.ESPERANDO and not paciencia_activa:
			al_llegar_al_slot
			
			
			
func al_llegar_al_slot():
	apagar_motor()
	motor_encendido = false
	velocity = Vector2.ZERO
	audio_motor.pitch_scale = 0.8
	CameraManager.trigger_reactive()
	sprite.play(car_type.anim_idle)

	paciencia_activa = true
	esperando_en_slot = true

	# activar UI
	label_tarea.visible = true
	patience_bar.visible = true

	# inicializar paciencia
	patience_bar.value = paciencia

	print("Auto detenido en slot. Tarea:", Tarea.keys()[tarea])

func entrar_en_espera():
	paciencia_activa = true

	# UI
	label_tarea.visible = true
	patience_bar.visible = true

	# Debug opcional
	print("Auto", self, "entró en espera con tarea:", Tarea.keys()[tarea])









#INTERACCIÓN CON EL JUGADOR
#--------------------------------------------------------------
var jugador_cerca := false

func _on_interaction_area_body_entered(body):
	if body.is_in_group("Player"):
		jugador_cerca = true
	if body.is_in_group("Player") and (
		estado == Estado.ESPERANDO
		or estado == Estado.ESPERANDO_COBRO
	):
		label_interactuar.visible = true


func _on_interaction_area_body_exited(body):
	if body.is_in_group("Player"):
		jugador_cerca = false
		player = null
		label_interactuar.visible = false
	print("salio")
	
	
func iniciar_limpieza():
	print("Iniciando minijuego de limpieza")
	var escena = preload("res://minigames/limpieza/limpieza_minigame.tscn")
	var minijuego = escena.instantiate()
	get_tree().current_scene.add_child(minijuego)
	get_tree().paused = true

#Test

	



	# Conectamos la señal 'terminado' del minijuego a nuestra función de callback
	var root = minijuego.get_node("Root UI")
	root.connect("terminado", Callable(self, "_on_limpieza_terminada"))

func iniciar_estacionamiento():
	print("Iniciando minijuego de ESTACIONAMIENTO")
	# Cargamos la escena principal del minijuego, no el área individual
	var escena = preload("res://minigames/estacionar/estacionar_minigame.tscn")
	var minijuego = escena.instantiate()
	get_tree().current_scene.add_child(minijuego)
	get_tree().paused = true
	
	# Conectamos la señal 'minijuego_terminado' a nuestra nueva función de callback
	
	
	minijuego.connect("minijuego_terminado", Callable(self, "_on_estacionamiento_terminado"))
	

func iniciar_messi_minijuego():
	var escena = preload("res://minigames/messi/messi_minigame.tscn")
	var minijuego = escena.instantiate()
	get_tree().current_scene.add_child(minijuego)
	get_tree().paused = true

	minijuego.connect(
		"minijuego_terminado",
		Callable(self, "_on_messi_minijuego_terminado")
	)

func _on_messi_minijuego_terminado(exito: bool):
	get_tree().paused = false

	if exito:
		tarea_completada()
	else:
		paciencia -= 5


func _on_limpieza_terminada(exito: bool) -> void:
	print("Resultado limpieza:", exito)
	get_tree().paused = false

	if exito:
		tarea_completada()
	else:
		paciencia -= 3
		# irse_enojado() # Podríamos querer un castigo menor

func _on_estacionamiento_terminado(exito: bool) -> void:
	print("AUTO: señal recibida. Exito =", exito)
	get_tree().paused = false

	if exito:
		tarea_completada()
	else:
		# Aquí podrías poner una penalización si el minijuego de estacionar tuviera una condición de fracaso
		paciencia -= 5 
	
func tarea_completada():
	estado = Estado.ESPERANDO_COBRO

	# reiniciar paciencia para el cobro
	paciencia = patience_bar.max_value
	patience_bar.value = paciencia
	paciencia_activa = true

	label_tarea.text = "COBRAR"
	label_tarea.modulate = Color.YELLOW

	print("Tarea completada, esperando cobro")
	
func interactuar():
	match estado:
		Estado.ESPERANDO:
			match tarea:
				Tarea.LIMPIAR:
					iniciar_limpieza()
				Tarea.ESTACIONAR:
					iniciar_estacionamiento()
				Tarea.MESSI:
					iniciar_messi_minijuego()
				# después agregamos ESTACIONAR, etc.

		Estado.ESPERANDO_COBRO:
			cobrar()
			
			
#AUDIO
func arrancar_motor():
	print("ARRANCAR MOTOR")
	print("motor_start_elegido:", motor_start_elegido)
	print("audio_motor_start:", audio_motor_start)

	if audio_motor_start and motor_start_elegido:
		audio_motor_start.play()
		print("PLAY motor start")

	if audio_motor:
		audio_motor.play()
		print("PLAY motor loop")

func apagar_motor():
	if audio_motor and audio_motor.playing:
		audio_motor.stop()

	
	
