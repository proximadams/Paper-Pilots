extends 'res://scripts/sound_effect.gd'

@export var player1: CharacterBody3D
@export var player2: CharacterBody3D

var pitchTarget = 1.0

func _process(_delta: float):
	var direction = player1.global_position - player2.global_position
	var distance = direction.length()
	direction = direction.normalized()
	var relative_velocity = player1.velocity - player2.velocity
	var dot = direction.dot(relative_velocity)
	pitchTarget = 1.0 - clamp(0.002 * dot, -0.3, 0.3)
	pitch_scale = lerp(pitch_scale, pitchTarget, 0.02)
	volumeOffset = clamp(5.0 - 0.1 * distance, -10.0, 5.0)
	set_volume_and_respect_setting()
