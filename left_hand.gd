# LeftController.gd
extends XRController3D

signal thumbstick_moved(direction: Vector2)
signal thumbstick_released

@export var deadzone: float = 0.15
@export var move_action: StringName = "primary"

func _process(_delta):
	# Usamos o método nativo get_vector2() do XRController3D
	var thumbstick_vec = super.get_vector2(move_action)
	
	if thumbstick_vec.length() < deadzone:
		if thumbstick_vec.length() > 0.01:
			emit_signal("thumbstick_released")
		return
	
	# Aplica deadzone e normaliza
	var normalized_vec = thumbstick_vec.normalized() * ((thumbstick_vec.length() - deadzone) / (1.0 - deadzone))
	emit_signal("thumbstick_moved", normalized_vec)

# Renomeamos nossa função auxiliar para evitar conflito
func get_input_vector(action: StringName) -> Vector2:
	match action:
		"primary":
			return Input.get_vector("primary_left", "primary_right", "primary_up", "primary_down")
		"secondary":
			return Input.get_vector("secondary_left", "secondary_right", "secondary_up", "secondary_down")
		_:
			return Vector2.ZERO
