extends Node3D

@export var min_speed := 1.0
@export var max_speed := 30.0
@export var acceleration_rate := 5.0
@export var deceleration_rate := 12.0

var current_speed := 0.0
var target_speed := 0.0
var movement_intensity := 0.0
var camera : Camera3D  # Referência à câmera do jogador
var smartphone_dir : Vector3

# Configurações exportáveis
@export var rotation_speed: float = 1.0  # Velocidade em radianos/segundo
@export var smoothness: float = 5.0      # Suavização do movimento
# Referências automáticas
@onready var left_hand: XRController3D = $LeftHand
@onready var right_hand: XRController3D = $RightHand
@onready var foot_step_sfx: AudioStreamPlayer3D = $"../FootStepSFX"

var target_rotation: float = 0.0
var current_rotation: float = 0.0

# Region with data to gather logs
var experiment_data = {
	"start_time": 0.0,
	"end_time": 0.0,
	"movement_events": [],
	"reset_events": [],
	"max_speed_reached": 0.0,
	"average_speed": 0.0,
	"total_distance": 0.0
}

var last_position := Vector3.ZERO
var total_samples := 0
var speed_sum := 0.0
var log_file_path := "user://experiment_log.json"

func _ready():
	# Obtém a referência da câmera (ajuste o caminho conforme sua cena)
	camera = get_node("/root/World/XROrigin3D/XRCamera3D")  # Caminho típico para VR
	left_hand = get_node("/root/World/XROrigin3D/LeftHand")  # Caminho típico para VR
	right_hand = get_node("/root/World/XROrigin3D/RightHand")  # Caminho típico para VR
	
	# Conecta ao WebSocket
	var sensor_connector = get_node("/root/World/Websocket")
	sensor_connector.movement_intensity_changed.connect(_on_movement_intensity_changed)

func _on_movement_intensity_changed(intensity: float, direction: Vector3):
	movement_intensity = intensity
	smartphone_dir = direction
	target_speed = min_speed + (max_speed - min_speed) * intensity

func _physics_process(delta):
	# Suavização da velocidade
	if current_speed < target_speed:
		current_speed = min(current_speed + acceleration_rate * delta, target_speed)
	else:
		current_speed = max(current_speed - deceleration_rate * delta, target_speed)
	# Movimento baseado na câmera - SEMPRE calcula a direção atual
	if current_speed > 1.2:
		# Pega a direção frontal ATUAL da câmera
		# var camera_forward = -camera.global_transform.basis.z
		var camera_forward = smartphone_dir
		camera_forward.y = 0  # Remove componente vertical
		camera_forward = camera_forward.normalized()
		global_translate(camera_forward * current_speed * delta)
		foot_step_sfx.play()
		
	# Coleta de dados de movimento
	var current_position = global_transform.origin
	var frame_distance = last_position.distance_to(current_position)
	experiment_data["total_distance"] += frame_distance
	last_position = current_position
	
	# Atualiza estatísticas de velocidade
	speed_sum += current_speed
	total_samples += 1
	experiment_data["max_speed_reached"] = max(experiment_data["max_speed_reached"], current_speed)
	# Registra evento de movimento significativo
	if current_speed > min_speed:
		experiment_data["movement_events"].append({
			"timestamp": Time.get_unix_time_from_system(),
			"speed": current_speed,
			"position": {
				"x": current_position.x,
				"y": current_position.y,
				"z": current_position.z
			},
			"intensity": movement_intensity
			})

func _process(delta: float):
	if right_hand.is_button_pressed("ax_button"):
		reset_to_origin()
	if Input.is_key_pressed(KEY_Z):
		_exit_tree()
	## Resetar rotação
	#target_rotation = 0.0
	## Verificar grips
	#if left_hand.is_button_pressed("grip_click"):
		#target_rotation += rotation_speed
	#if right_hand.is_button_pressed("grip_click"):
		#target_rotation -= rotation_speed
		## Aplicar rotação suavizada
	#current_rotation = lerp(current_rotation, target_rotation, smoothness * delta)
	#rotate_object_local(Vector3(0, 1, 0), current_rotation * delta)

# Adicione este novo método à classe
func reset_to_origin() -> void:
	# Reseta a posição para (0,0,0)
	global_transform.origin = Vector3.ZERO
	# Reseta a velocidade para evitar movimento indesejado
	current_speed = 0.0
	print("Personagem retornou à origem")
	
func _exit_tree():
	finalize_experiment_data()

func finalize_experiment_data():
	experiment_data["end_time"] = Time.get_unix_time_from_system()
	experiment_data["duration_seconds"] = experiment_data["end_time"] - experiment_data["start_time"]
	experiment_data["average_speed"] = speed_sum / total_samples if total_samples > 0 else 0.0
	
	# Salva em arquivo JSON
	var file = FileAccess.open(log_file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(experiment_data, "\t"))
	file.close()
	print("Dados do experimento salvos em: ", log_file_path)
