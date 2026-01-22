extends CharacterBody2D

@export var speed: int
@onready var sprite := $Sprite2D

func _physics_process(delta: float) -> void:
	var dir := Input.get_axis("left", "right")

	velocity.x = dir * speed
	move_and_slide()

	# Flip horizontal
	if dir != 0:
		sprite.flip_h = dir < 0
