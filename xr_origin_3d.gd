# VRPlayer.gd
extends XROrigin3D

@export var move_speed: float = 1.5
@export var turn_speed: float = 120  # Em graus por segundo
@export var snap_turn_angle: float = 45.0  # Snap turn em graus

var left_controller: XRController3D
var right_controller: XRController3D

func _ready():
	left_controller = get_node("LeftController") as XRController3D
	right_controller = get_node("RightController") as XRController3D
	
	if left_controller:
		left_controller.thumbstick_moved.connect(_on_left_thumbstick_moved)
		left_controller.thumbstick_released.connect(_on_left_thumbstick_released)
	
	if right_controller:
		right_controller.thumbstick_moved.connect(_on_right_thumbstick_moved)

func _on_left_thumbstick_moved(direction: Vector2):
	# Movimento baseado na direção do HMD
	var camera = $XRCamera3D
	var forward = -camera.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	
	var right = camera.global_transform.basis.x
	right.y = 0
	right = right.normalized()
	
	var move_dir = (forward * direction.y + right * direction.x)
	global_position += move_dir * move_speed * get_process_delta_time()

func _on_right_thumbstick_moved(direction: Vector2):
	# Rotação suave ou snap turn
	if abs(direction.x) > 0.7:  # Threshold para snap turn
		var turn_direction = sign(direction.x)
		rotate_y(deg_to_rad(-turn_direction * snap_turn_angle))
	# Para rotação contínua:
	# rotate_y(direction.x * deg_to_rad(turn_speed) * get_process_delta_time())

func _on_left_thumbstick_released():
	# Feedback ou lógica adicional quando solta o analógico
	pass
