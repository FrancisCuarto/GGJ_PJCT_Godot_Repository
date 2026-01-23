extends CharacterBody2D


@export var speed_normal := 200
@export var speed_lenta := 80
@onready var label_tarea = $LabelTarea
var current_speed: float

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
var paciencia := 10.0

#CONTROL DE TAREAS
enum Tarea {
	ESTACIONAR,
	LIMPIAR,
	PAGAR,
	NADA
}

var tarea := Tarea.LIMPIAR


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
	queue_free()


func _process(delta):
	#TIMER DE PACIENCIA
	if estado == Estado.ESPERANDO:
		paciencia -= delta
		if paciencia <= 0:
			irse_enojado()

func _ready():
	current_speed = speed_normal

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
