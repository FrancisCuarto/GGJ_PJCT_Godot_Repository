extends Node

var camera: Camera2D = null

func register_camera(cam: Camera2D):
	camera = cam

func trigger_reactive():
	if camera == null:
		return
	if camera.is_locked():
		return
	camera.trigger_reactive_camera()

func trigger_event():
	if camera == null:
		return
	camera.trigger_event_camera()

func enter_minigame():
	if camera == null:
		return
	camera.enter_minigame_camera()

func exit_minigame():
	if camera == null:
		return
	camera.exit_minigame_camera()
