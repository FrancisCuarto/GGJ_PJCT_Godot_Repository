extends Area2D
class_name Estacionamiento

# --- Señales ---
signal carro_estacionado(carro)
signal carro_se_fue(carro)
signal carro_perfectamente_estacionado(carro) # La nueva señal para el éxito

# --- Estado ---
var is_occupied: bool = false
var car_parked: PlayerCar = null # Usamos el class_name que definimos en el jugador
var has_parked_successfully: bool = false

# Referencia al CollisionShape2D de este mismo nodo.
# Asegúrate de que tu CollisionShape2D se llame "CollisionShape2D" y sea hijo de este Area2D.
@onready var parking_spot_shape: CollisionShape2D = $CollisionShape2D

func _physics_process(_delta: float) -> void:
	# Si hay un auto en el área y aún no hemos registrado un estacionamiento perfecto...
	if car_parked and not has_parked_successfully:
		check_if_perfectly_parked()

func check_if_perfectly_parked():
	# 1. Verificamos que tanto el parking como el auto tengan sus nodos de colisión listos
	if not is_instance_valid(parking_spot_shape) or not parking_spot_shape.shape:
		return
	if not is_instance_valid(car_parked) or not is_instance_valid(car_parked.car_collider) or not car_parked.car_collider.shape:
		return

	# 2. Obtenemos los rectángulos de las formas de colisión
	var parking_rect := parking_spot_shape.shape.get_rect()
	var car_rect := car_parked.car_collider.shape.get_rect()
	
	# 3. Transformamos los rectángulos a coordenadas del mundo (globales)
	var global_parking_rect := parking_spot_shape.global_transform * parking_rect
	var global_car_rect := car_parked.car_collider.global_transform * car_rect
	
	# --- INICIO DE DEPURACIÓN ---
	print("--- Chequeando Estacionamiento ---")
	print("Parking Rect Global: ", global_parking_rect)
	print("Car Rect Global: ", global_car_rect)
	print("¿Parking encierra a Car?: ", global_parking_rect.encloses(global_car_rect))
	print("----------------------------------")
	# --- FIN DE DEPURACIÓN ---
	
	# 4. LA MAGIA: Comprobamos si el rectángulo del parking encierra completamente al del auto
	if global_parking_rect.encloses(global_car_rect):
		has_parked_successfully = true # Marcamos como éxito para no repetir la señal
		emit_signal("carro_perfectamente_estacionado", car_parked)
		print("¡ÉXITO! Auto perfectamente estacionado en: ", self.name)


func _on_body_entered(body: Node2D) -> void:
	# Comprobamos que el cuerpo que entra sea un PlayerCar y que el lugar no esté ya ocupado
	if body is PlayerCar and not is_occupied:
		is_occupied = true
		car_parked = body
		has_parked_successfully = false # Reseteamos el estado de éxito
		emit_signal("carro_estacionado", car_parked)
		print("Un auto ha entrado al área ", self.name)


func _on_body_exited(body: Node2D) -> void:
	# Si el auto que sale es el que teníamos registrado...
	if body == car_parked:
		is_occupied = false
		car_parked = null
		has_parked_successfully = false # Reseteamos el estado
		emit_signal("carro_se_fue", body)
		print("El auto ha salido del área ", self.name)
