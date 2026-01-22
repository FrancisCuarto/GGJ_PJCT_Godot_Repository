extends CharacterBody2D


@export var speed_normal := 200
@export var speed_lenta := 80

var current_speed: float

func _ready():
	current_speed = speed_normal

func _physics_process(delta):
	#velocity.x = current_speed
	velocity.x = lerp(velocity.x, current_speed, 0.1)
	move_and_slide()
	
#func _physics_process(delta):
	#velocity = Vector2.ZERO
	#velocity.x = current_speed
	#move_and_slide()

func set_slow(value: bool):
	current_speed = speed_lenta if value else speed_normal
	print("SLOW:", value, " | speed:", current_speed)
	
