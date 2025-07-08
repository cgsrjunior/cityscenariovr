extends Node3D

@export var min_speed := 1.0
@export var max_speed := 30.0
@export var acceleration_rate := 4.0
@export var deceleration_rate := 8.0

var current_speed := 0.0
var target_speed := 0.0
var movement_intensity := 0.0
var camera : Camera3D  # Referência à câmera do jogador

func _ready():
	# Obtém a referência da câmera (ajuste o caminho conforme sua cena)
	camera = get_node("/root/World/XROrigin3D/XRCamera3D")  # Caminho típico para VR
	
	# Conecta ao WebSocket
	var sensor_connector = get_node("/root/World/Websocket")
	sensor_connector.movement_intensity_changed.connect(_on_movement_intensity_changed)

func _on_movement_intensity_changed(intensity: float):
	movement_intensity = intensity
	target_speed = min_speed + (max_speed - min_speed) * intensity

func _physics_process(delta):
	# Suavização da velocidade
	if current_speed < target_speed:
		current_speed = min(current_speed + acceleration_rate * delta, target_speed)
	else:
		current_speed = max(current_speed - deceleration_rate * delta, target_speed)
	
	# Movimento baseado na câmera
	if current_speed > 1.2:
		# Pega a direção frontal da câmera (ignorando inclinação vertical)
		var camera_forward = -camera.global_transform.basis.z
		camera_forward.y = 0  # Remove componente vertical
		camera_forward = camera_forward.normalized()
		
		# Aplica o movimento
		translate(camera_forward * current_speed * delta)
		
