extends Node

var _ws = WebSocketPeer.new()
var _proto_controller : Node

# Configurações de sensibilidade
const MOVEMENT_THRESHOLD := 1.0  # Valor inicial - ajuste conforme necessidade
const COOLDOWN_TIME := 0.2        # Tempo mínimo entre movimentos detectados
const REQUIRED_CONSECUTIVE_DETECTIONS := 2  # Número de detecções consecutivas para validar

var _last_accel := Vector3.ZERO
var _cooldown := 0.0
var _consecutive_detections := 0

func _ready():
	_proto_controller = get_node("/root/World/ProtoController")
	_ws.connect_to_url("ws://192.168.15.75:8080/sensor/connect?type=android.sensor.accelerometer")

func _process(delta):
	_ws.poll()
	
	if _ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while _ws.get_available_packet_count() > 0:
			var msg = _ws.get_packet().get_string_from_utf8()
			#print("Mensagem crua:", msg)
			if msg:
				# Now i gonna parse this and calculate everything i need
				var json = JSON.new()
				if json.parse(msg) != OK:
					return
				var sensor_data = json.get_data()
				#print(sensor_data)
				
				var sensor_values = sensor_data["values"]
				#print(sensor_values)
				
				if sensor_values != null:
					var current_accel = Vector3(sensor_values[0], sensor_values[1], sensor_values[2])
					var delta_variation = current_accel - _last_accel
					_last_accel = current_accel
					# Calcula a força do movimento combinando todos os eixos
					var movement_force = delta_variation.length()
					if movement_force > MOVEMENT_THRESHOLD:
						print("Atingiu o threshold")
						_consecutive_detections += 1
						if _consecutive_detections >= REQUIRED_CONSECUTIVE_DETECTIONS:
							_trigger_movement()
							_consecutive_detections = 0
							_cooldown = COOLDOWN_TIME

func _trigger_movement():
	print("MOVIMENTO DO JOELHO DETECTADO!")
	_proto_controller.walk_forward(true)
	
	# Cria um timer para desativar o movimento após um curto período
	var timer = get_tree().create_timer(0.3)
	await timer.timeout
	_proto_controller.walk_forward(false)
