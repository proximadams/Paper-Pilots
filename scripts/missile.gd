extends Node3D

const ACCELERATION_MULT := 100.0
const DISTANCE_EXPLODE  := 20.0
const MAX_SPEED         := 50000.0

var ratio := 1.0
var speed := 0.0
var sourcePlayer: CharacterBody3D
var targetPlayer: CharacterBody3D

@onready var model           : Node3D            = $Model
@onready var missileNearSound: AudioStreamPlayer = $MissileNearSound

func _physics_process(delta: float) -> void:
	if model.visible:
		if 0.0 < ratio:
			ratio = max(0.0, ratio - delta)
			if ratio == 0.0:
				missileNearSound.play()
		if speed == 0.0:
			if is_instance_valid(sourcePlayer):
				speed = sourcePlayer.propulsionSpeed * 0.01
		elif speed < MAX_SPEED:
			speed = min(MAX_SPEED, speed + delta * ACCELERATION_MULT)
		look_at(targetPlayer.global_position)
		if ratio == 0.0:
			global_position = global_position.move_toward(targetPlayer.global_position, speed * delta)
			var distanceFromTarget = global_position.distance_to(targetPlayer.global_position)
			if distanceFromTarget < DISTANCE_EXPLODE:
				targetPlayer.explode_missile()
				model.visible = false
				missileNearSound.queue_free()
			else:
				missileNearSound.pitch_scale = clamp(0.5 + 10/sqrt(distanceFromTarget), 0.5, 1.5)
		else:
			global_position = sourcePlayer.global_position
			global_position.y -= 6.0
