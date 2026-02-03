extends Camera2D


var target_position: Vector2

func _ready():
	target_position = global_position

func _process(delta):
	global_position = global_position.lerp(target_position, 0.1)
