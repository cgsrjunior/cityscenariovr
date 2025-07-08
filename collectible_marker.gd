extends Area3D

@export var player_path : NodePath
var player_node : Node3D

func _ready():
	player_node = get_node(player_path) if player_path else get_node("/root/XRSetup/XROrigin3D")
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body == player_node or body.is_in_group("player"):
		var parent = get_parent()
		parent.visible = false
		parent.set_process(false)
		parent.set_physics_process(false)
		await get_tree().process_frame  # Garante que todos os callbacks terminem
		parent.queue_free()
