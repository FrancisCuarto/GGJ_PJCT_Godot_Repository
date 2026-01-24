extends Area2D

var slot_ocupado := false

func _on_body_entered(body):
	if slot_ocupado == false:
		print("ENTRÓ A SERVICIO:")
		if body.is_in_group("auto"):
			body.set_service(true)
			slot_ocupado = true
		else:
			print("Ocupado")

func _on_body_exited(body):
	slot_ocupado = false
