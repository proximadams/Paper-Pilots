extends Camera3D

@export var followTarget: Node3D
@export var lookAtTarget: Node3D

func _physics_process(_delta: float) -> void:
	global_position = lerp(global_position, followTarget.global_position, 0.05)
	look_at(lookAtTarget.global_position)
