extends CharacterBody2D

@export var speed: int



func _physics_process(delta: float) -> void:
	position.x += Input.get_axis("left", "right") * speed
	
	
	move_and_slide()
