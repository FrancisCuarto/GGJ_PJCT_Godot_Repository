extends CharacterBody2D


@export var speed_normal := 200
@export var speed_lenta := 80
@onready var label_tarea = $LabelTarea
@onready var patience_bar = $PatienceBar
@onready var label_interactuar = $LabelInteractuar
var paciencia_activa := false
var current_speed: float
var stoped := 0



#--------------------------------------------------------------
#CONTROL DE ESTADOS
enum Estado {
	ESPERANDO,
	LIMPIANDO,
	ESTACIONADO,
	ENOJADO,
	YENDOSE
}

var estado := Estado.ESPERANDO
var paciencia := 20.0

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
	tarea = Tarea.values().pick_random()
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
	estado = Estado.YENDOSE
	#queue_free()




func _process(delta):
	
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		interactuar()
		
	#TIMER DE PACIENCIA
	if estado == Estado.ESPERANDO and paciencia_activa:
		paciencia -= delta
		patience_bar.value = paciencia
		actualizar_color_paciencia()

		if paciencia <= 0:
			set_service(false)
	

func _ready():
	current_speed = speed_normal
	patience_bar.max_value = paciencia
	patience_bar.value = paciencia
	patience_bar.visible = false
	label_interactuar.visible = false

func _physics_process(delta):
	#velocity.x = current_speed
	velocity.x = lerp(velocity.x, current_speed, 0.1)
	move_and_slide()
	
#--------------------------------------------
#LO HACE IR LENTO CUANDO ENTRA EN LA ESCENA
func set_slow(value: bool):
	current_speed = speed_lenta if value else speed_normal
	print("SLOW:", value, " | speed:", current_speed)
#-----------------------------------------------


#--------------------------------------------
#LO HACE PARAR CUANDO ENTRA EN LA SERVICE ZONE
func set_service(value: bool):
	estado = Estado.ESPERANDO
	current_speed = stoped if value else speed_normal
	print("SERVICE:", value, " | speed:", current_speed)
	paciencia_activa = true
	patience_bar.visible = true
#-----------------------------------------------



#INTERACCIÓN CON EL JUGADOR
#--------------------------------------------------------------
var jugador_cerca := false

func _on_interaction_area_body_entered(body):
	if body.is_in_group("Player"):
		jugador_cerca = true
	if body.is_in_group("Player") and estado == Estado.ESPERANDO:
		label_interactuar.visible = true
	print("entro")


func _on_interaction_area_body_exited(body):
	if body.is_in_group("Player"):
		jugador_cerca = false
	if body.is_in_group("Player"):
		label_interactuar.visible = false
	print("salio")
	
func interactuar():
	if estado != Estado.ESPERANDO:
		return

	set_service(true) # frena +  paciencia

	"""match tarea:
		Tarea.LIMPIAR:
			iniciar_limpieza()
		Tarea.ESTACIONAR:
			iniciar_estacionamiento()
		Tarea.PAGAR:
			iniciar_pago()
		Tarea.NADA:
			irse_enojado()"""

func finalizar_tarea():
	set_service(false)
