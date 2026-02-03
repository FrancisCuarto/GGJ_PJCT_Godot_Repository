extends Area2D

#@export var camera_to_activate: Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
#func _on_body_entered(body):
	#if body.is_in_group("Player"):
		#camera_to_activate.make_current()

@export var camera_target: NodePath

func _on_body_entered(body):
	if body.is_in_group("Player"):
		var cam = get_tree().get_first_node_in_group("camera")
		cam.target_position = get_node(camera_target).global_position
