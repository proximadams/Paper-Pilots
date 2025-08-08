extends Camera3D

@export var followTarget: Node3D
@export var lookAtTarget: CharacterBody3D

func _process(_delta: float) -> void:
	global_position = followTarget.global_position
	look_at(lookAtTarget.global_position)
