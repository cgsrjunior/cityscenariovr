extends XRCamera3D

# Referências aos controles (conecte automaticamente)
@onready var left_hand := get_parent().get_node("LeftHand") as XRController3D
@onready var right_hand := get_parent().get_node("RightHand") as XRController3D

# Configurações
@export var rotation_speed: float = 1.5  # Velocidade em radianos/segundo
@export var rotation_smoothness: float = 5.0  # Suavização da rotação

var target_rotation: float = 0.0

func _process(delta: float):
	var rotation_input = 0.0
	
	# Verifica botão grip esquerdo
	if left_hand and left_hand.is_button_pressed("grip_click"):
		rotation_input -= 1.0  # Rotação anti-horária
	
	# Verifica botão grip direito
	if right_hand and right_hand.is_button_pressed("grip_click"):
		rotation_input += 1.0  # Rotação horária
	
	# Atualiza rotação suavemente
	target_rotation = rotation_input * rotation_speed
	var current_rotation = rotation.y
	rotation.y = lerp(current_rotation, current_rotation + target_rotation * delta, rotation_smoothness * delta)
