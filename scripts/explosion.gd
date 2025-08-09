extends Node3D

func _on_animation_finished(animationName: StringName) -> void:
	if animationName == 'explode':
		queue_free()
