extends Camera2D

enum CameraState {
	BASE,
	REACTIVA,
	EVENTO,
	MINIJUEGO
}

@export var player_path: NodePath
var player: Node2D = null

@export var limite_izq := -1450.0
@export var limite_der := 4500.0


	




@export var base_zoom := Vector2(0.8, 0.8)
@export var reactive_zoom := Vector2(0.95, 0.95)
@export var event_zoom := Vector2(0.9, 0.9)

@export var transition_speed := 6.0
@export var reactive_duration := 0.3

var current_state: CameraState = CameraState.BASE
var target_zoom := Vector2.ONE
var reactive_timer := 0.0

func _ready():
	zoom = base_zoom
	target_zoom = base_zoom
	position_smoothing_enabled = true
	position_smoothing_speed = 8.0
	
	if player_path != NodePath():
		player = get_node(player_path)

	# Registrar esta cámara en el CameraManager
	CameraManager.register_camera(self)

func _process(delta):
	_update_state(delta)
	_update_zoom(delta)
	

func _update_state(delta):
	if current_state == CameraState.REACTIVA:
		reactive_timer -= delta
		if reactive_timer <= 0:
			set_base_camera()

func _update_zoom(delta):
	zoom = zoom.lerp(target_zoom, transition_speed * delta)

func set_base_camera():
	current_state = CameraState.BASE
	target_zoom = base_zoom

func trigger_reactive_camera():
	if current_state != CameraState.BASE:
		return
	current_state = CameraState.REACTIVA
	target_zoom = reactive_zoom
	reactive_timer = reactive_duration

func trigger_event_camera():
	current_state = CameraState.EVENTO
	target_zoom = event_zoom

func enter_minigame_camera(custom_zoom := Vector2(0.85, 0.85)):
	current_state = CameraState.MINIJUEGO
	target_zoom = custom_zoom

func exit_minigame_camera():
	set_base_camera()

func is_locked() -> bool:
	return current_state == CameraState.MINIJUEGO

func _physics_process(delta):
	if player:
		global_position = player.global_position 
	var pos = global_position
	pos.x = clamp(pos.x, limite_izq, limite_der)
	global_position = pos
