extends Sprite2D

@export var min_interval: float = 5.0
@export var max_interval: float = 15.0
@export var min_duration: float = 3.0
@export var max_duration: float = 6.0
@export var min_x: float = -2000.0
@export var max_x: float = 5000.0
@export var fixed_y: float = 540.0 # Adjusted based on player Y (~594)

var timer: Timer

func _ready() -> void:
	# Setup timer
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	
	# Start hidden
	visible = false
	schedule_appearance()

func schedule_appearance() -> void:
	var interval = randf_range(min_interval, max_interval)
	timer.start(interval)

func _on_timer_timeout() -> void:
	if visible:
		# Hide and wait for next appearance
		visible = false
		schedule_appearance()
	else:
		# Show at random position
		position = Vector2(randf_range(min_x, max_x), fixed_y)
		# Flip randomly for variety?
		flip_h = randf() > 0.5
		visible = true
		
		# Schedule disappearance
		var duration = randf_range(min_duration, max_duration)
		timer.start(duration)

func _process(delta: float) -> void:
	# Simple animation loop if hframes > 1
	if hframes > 1:
		# Adjust speed as needed, e.g., 10 fps
		frame = int(Time.get_ticks_msec() / 100.0) % hframes
