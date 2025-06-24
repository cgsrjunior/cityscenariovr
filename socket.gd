extends Node

# Configura a porta que o servidor vai escutar
const PORT = 9080
var _server := TCPServer.new()
var _client : StreamPeerTCP
var _proto_controller : Node

# Limiar de variação para ativar o movimento
const Z_THRESHOLD = 1.5
var _last_z = 0.0

func _ready():
	_proto_controller = get_node("/root/World/ProtoController") # Ajuste o caminho conforme sua cena
	# Inicia o servidor
	if _server.listen(PORT) == OK:
		print("Servidor iniciado. Escutando na porta ", PORT)
	else:
		printerr("Erro ao iniciar servidor")

func _process(_delta):
	# Aceita novas conexões
	if _server.is_connection_available():
		_client = _server.take_connection()
		print("Cliente conectado: ", _client.get_connected_host())
	
	# Processa dados recebidos
	if _client and _client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		var available_bytes = _client.get_available_bytes()
		if available_bytes > 0:
			var data = _client.get_utf8_string(available_bytes)
			if data:
				print("Dados recebidos: ", data)
				
				# Tenta parsear o JSON
				var json = JSON.new()
				var error = json.parse(data)
				
				if error == OK:
					var json_data = json.get_data()
					print("JSON parseado: ", json_data)
					_process_sensor_data(json_data)
				else:
					printerr("Erro ao parsear JSON: ", json.get_error_message())
					
func _process_sensor_data(parse_data):
	# Extrai valores do acelerômetro
	var z = float(parse_data.get('z', 0.0))
		
	# Calcula variação no eixo Z
	var z_variation = abs(z - _last_z)
	_last_z = z
		# Se a variação ultrapassar o limiar, ativa movimento
	if z_variation > Z_THRESHOLD:
		var intensity = clamp(z_variation / 2.0, 0.0, 1.0)  # Normaliza para 0-1
		_proto_controller.walk_forward(true)
	else:
		_proto_controller.walk_forward(false)

func _exit_tree():
	# Fecha a conexão ao sair
	if _client:
		_client.disconnect_from_host()
	_server.stop()
