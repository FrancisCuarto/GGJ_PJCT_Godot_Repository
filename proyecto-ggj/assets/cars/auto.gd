extends CharacterBody2D


@export var speed_normal := 400
@export var speed_lenta := 250
@export var paciencia := 10.0
@export var car_type: CarType
@onready var label_tarea = $LabelTarea
@onready var patience_bar = $PatienceBar
@onready var label_interactuar = $LabelInteractuar
@onready var screen_notifier = $ScreenNotifier
var paciencia_activa := false
var current_speed: float
var stoped := 0
var slot_actual = null
var target_position: Vector2
var esperando_en_slot := false
var estado := Estado.ESPERANDO
var queue_manager = null
var player: Node2D = null







#--------------------------------------------------------------
#CONTROL DE ESTADOS
enum Estado {
	ESPERANDO,
	LIMPIANDO,
	ESTACIONADO,
	ENOJADO,
	YENDOSE
}



#CONTROL DE TAREAS
enum Tarea {
	ESTACIONAR, 
	LIMPIAR,
	PAGAR,
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
		
#Toma la tarea del resource car_type
	tarea = car_type.tareas_posibles.pick_random()
	
	label_tarea.text = Tarea.keys()[tarea]
	
	
	#CAMBIA EL COLOR DEL TEXTO SEGUN LA TAREA
	match tarea:
		Tarea.LIMPIAR:
			label_tarea.modulate = Color.CYAN
		Tarea.ESTACIONAR:
			label_tarea.modulate = Color.GREEN
		Tarea.PAGAR:
			label_tarea.modulate = Color.YELLOW
	print("Auto", self, "tarea asignada:", Tarea.keys()[tarea])

#------------------------------------------------------------------
#ELIMINA EL AUTO CUANDO LA PACIENCIA SE ACABA
func irse_enojado():
	if estado == Estado.YENDOSE:
		return

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
	estado = Estado.YENDOSE

	# Remove from queue manager if exists
	if queue_manager:
		queue_manager.remover_auto(self)

	# Free the slot properly using the queue manager
	if queue_manager and slot_actual:
		queue_manager.liberar_slot(self)

	slot_actual = null

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

	# stats desde el resource
	speed_normal = car_type.speed_normal
	speed_lenta = car_type.speed_lenta
	paciencia = car_type.paciencia_max

	# visual
	$Sprite2D.texture = car_type.sprite
	$Sprite2D.flip_h = true
	scale = Vector2(1.0, 1.0)
	

	# UI
	patience_bar.max_value = paciencia
	patience_bar.value = paciencia
	patience_bar.visible = false
	label_interactuar.visible = false
	label_tarea.visible = false

	current_speed = speed_normal
	target_position = global_position
	
	
	
	
	
	target_position = global_position
	current_speed = speed_normal
	patience_bar.max_value = paciencia
	patience_bar.value = paciencia
	patience_bar.visible = false
	label_interactuar.visible = false
	paciencia_activa = false
	label_tarea.visible = false

func _physics_process(delta):
	match estado:
		Estado.ESPERANDO, Estado.YENDOSE:
			mover_hacia_target()
			
	pass

	move_and_slide()
	
	

	
	
func mover_hacia_target():
	var dir = target_position - global_position

	if dir.length() > 5:
		velocity = dir.normalized() * current_speed
	else:
		# llegó al marker
		velocity = Vector2.ZERO

		if estado == Estado.ESPERANDO and not paciencia_activa:
			al_llegar_al_slot()
			
			
			
func al_llegar_al_slot():
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
		player = body
		if estado == Estado.ESPERANDO:
			label_interactuar.visible = true
			print("Player entered interaction area")


func _on_interaction_area_body_exited(body):
	if body.is_in_group("Player"):
		jugador_cerca = false
		player = null
		label_interactuar.visible = false
		print("Player exited interaction area")
	
func interactuar():
	if estado != Estado.ESPERANDO:
		return

	set_service(true) # frena +  paciencia

	match tarea:
		Tarea.LIMPIAR:
			iniciar_limpieza()
		Tarea.ESTACIONAR:
			iniciar_estacionamiento()
		Tarea.PAGAR:
			iniciar_pago()
		Tarea.NADA:
			irse_enojado()

func set_service(in_servicio: bool):
	if in_servicio:
		# Stop the car and start service
		estado = Estado.LIMPIANDO
		current_speed = 0
		velocity = Vector2.ZERO
		# Change appearance to indicate service state
		$Sprite2D.modulate = Color(0.7, 0.7, 1.0)  # Light blue tint
		label_interactuar.text = "Servicio..."
		print("Car is now in service mode - being cleaned")
	else:
		# Resume normal operation
		estado = Estado.ESPERANDO
		current_speed = speed_lenta
		# Restore normal appearance
		$Sprite2D.modulate = Color.WHITE
		label_interactuar.text = "Presioná E"

func iniciar_limpieza():
	print("Starting cleaning service for car")
	label_interactuar.text = "Limpiando..."
	# For now, just complete the cleaning task and make the car leave
	await get_tree().create_timer(2.0).timeout  # Simulate cleaning time
	irse()

func iniciar_estacionamiento():
	print("Starting parking service for car")
	label_interactuar.text = "Estacionando..."
	# For now, just complete the parking task and make the car leave
	await get_tree().create_timer(2.0).timeout  # Simulate parking time
	irse()

func iniciar_pago():
	print("Starting payment service for car")
	label_interactuar.text = "Pagando..."
	# For now, just complete the payment task and make the car leave
	await get_tree().create_timer(2.0).timeout  # Simulate payment time
	irse()
