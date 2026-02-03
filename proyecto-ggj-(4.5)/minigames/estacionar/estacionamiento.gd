extends Area2D
class_name Estacionamiento

# --- Señales ---
signal carro_estacionado(carro)
signal carro_se_fue(carro)
signal carro_perfectamente_estacionado(carro)

# --- Estado ---
var is_occupied: bool = false
var car_parked: PlayerCar = null
var has_parked_successfully: bool = false






@onready var parking_spot_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Log para confirmar que el área de estacionamiento se carga en la escena.
	print("Área de estacionamiento '", self.name, "' inicializada.")

func _physics_process(_delta: float) -> void:
	# Si ya se estacionó perfectamente, no necesitamos hacer más chequeos.
	if has_parked_successfully:
		return
   
	# Usamos get_overlapping_bodies() para una detección más directa y robusta que las señales.
	var bodies = get_overlapping_bodies()
	var current_car_inside: PlayerCar = null
	
	for body in bodies:
		if body is PlayerCar:
			current_car_inside = body
			break # Encontramos un auto, es suficiente.

	# Detectamos si un auto acaba de entrar o salir comparando con el estado anterior.
	var car_just_entered = current_car_inside and not car_parked
	var car_just_exited = not current_car_inside and car_parked

	if car_just_entered:
		is_occupied = true
		car_parked = current_car_inside
		has_parked_successfully = false # Reseteamos el éxito para el nuevo auto.
		emit_signal("carro_estacionado", car_parked)
		print("Auto [", car_parked.name, "] ha entrado al área ", self.name)
	elif car_just_exited:
		is_occupied = false
		emit_signal("carro_se_fue", car_parked)
		print("Auto [", car_parked.name, "] ha salido del área ", self.name)
		car_parked = null
	
	# Si hay un auto dentro, continuamos chequeando si ha logrado el estacionamiento perfecto.
	if car_parked:
		check_if_perfectly_parked()

func check_if_perfectly_parked():
	# 1. Verificaciones de seguridad para evitar errores si algo no está listo.
	if not is_instance_valid(parking_spot_shape) or not parking_spot_shape.shape:
		return
	if not is_instance_valid(car_parked) or not "car_collider" in car_parked or not is_instance_valid(car_parked.car_collider) or not car_parked.car_collider.shape:
		return

	# 2. Obtenemos los rectángulos de las formas de colisión.
	var parking_rect := parking_spot_shape.shape.get_rect()
	var car_rect := car_parked.car_collider.shape.get_rect()
	
	# 3. Transformamos los rectángulos a coordenadas globales.
	var global_parking_rect := parking_spot_shape.global_transform * parking_rect
	var global_car_rect := car_parked.car_collider.global_transform * car_rect
	
	var intersection = global_parking_rect.intersection(global_car_rect)
	
	var car_area = global_car_rect.size.x * global_car_rect.size.y
	var intersection_area = intersection.size.x * intersection.size.y

	var progreso = clamp(intersection_area / car_area, 0.0, 1.0)


	
	# 4. Comprobamos si el rectángulo del parking encierra completamente al del auto.
	if global_parking_rect.encloses(global_car_rect):
		has_parked_successfully = true # Marcamos como éxito para no repetir la señal.
		emit_signal("carro_perfectamente_estacionado", car_parked)
		print("¡ÉXITO! Auto perfectamente estacionado en: ", self.name)
		
		

# Las funciones originales _on_body_entered y _on_body_exited ya no son necesarias
# porque la lógica ahora está centralizada en _physics_process.
func calcular_progreso(car: PlayerCar) -> float:
	if not is_instance_valid(car):
		return 0.0

	if not is_instance_valid(parking_spot_shape):
		return 0.0
	if parking_spot_shape.shape == null:
		return 0.0
	if not is_instance_valid(car.car_collider):
		return 0.0
	if car.car_collider.shape == null:
		return 0.0

	var parking_rect = parking_spot_shape.shape.get_rect()
	var car_rect = car.car_collider.shape.get_rect()

	var global_parking = parking_spot_shape.global_transform * parking_rect
	var global_car = car.car_collider.global_transform * car_rect

	var intersection = global_parking.intersection(global_car)
	if intersection == Rect2():
		return 0.0

	var car_area = global_car.size.x * global_car.size.y
	if car_area <= 0.0:
		return 0.0

	var intersection_area = intersection.size.x * intersection.size.y
	return clamp(intersection_area / car_area, 0.0, 1.0)
