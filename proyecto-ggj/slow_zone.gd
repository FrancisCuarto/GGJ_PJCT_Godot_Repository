extends Area2D


# Called when the node enters the scene tree for the first time.
func _on_body_entered(body):
	#print("ENTRÓ:", body, " | tipo:", body.get_class())
	if body.is_in_group("auto"):
		body.set_slow(true)

#func _on_body_exited(body):
	#print("salio")
	#if body.is_in_group("auto"):
		#body.set_slow(false)
