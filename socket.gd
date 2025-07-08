extends Node

signal movement_intensity_changed(intensity: float)  # Novo sinal: 0.0 a 1.0

var _ws = WebSocketPeer.new()
const MAX_ACCELERATION := 10.0  # Valor máximo considerado para normalização
const REQUIRED_CONSECUTIVE_DETECTIONS := 2

var _last_accel := Vector3.ZERO
var _consecutive_detections := 0

func _ready():
	_ws.connect_to_url("ws://192.168.0.192:8080/sensor/connect?type=android.sensor.accelerometer")

func _process(_delta):
	_ws.poll()
	
	if _ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while _ws.get_available_packet_count() > 0:
			var msg = _ws.get_packet().get_string_from_utf8()
			if msg:
				var json = JSON.new()
				if json.parse(msg) == OK:
					_process_sensor_data(json.get_data())

func _process_sensor_data(data):
	var sensor_values = data.get("values", [])
	if sensor_values.size() >= 3:
		var current_accel = Vector3(sensor_values[0], sensor_values[1], sensor_values[2])
		var delta_variation = current_accel - _last_accel
		_last_accel = current_accel
		
		var movement_force = delta_variation.length()
		# print(movement_force)
		
		if movement_force > 0.1:  # Threshold mínimo
			_consecutive_detections += 1
			if _consecutive_detections >= REQUIRED_CONSECUTIVE_DETECTIONS:
				# Normaliza a intensidade (0.0 a 1.0)
				var normalized_intensity = min(movement_force / MAX_ACCELERATION, 1.0)
				print(normalized_intensity)
				movement_intensity_changed.emit(normalized_intensity)
		else:
			_consecutive_detections = 0
			movement_intensity_changed.emit(0.0)
