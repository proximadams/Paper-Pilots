extends Camera3D

@export var followTarget  : Node3D
@export var lookAtTarget  : Node3D
@export var player        : CharacterBody3D
@export var enemyOffscreen: Control
@export var enemyOnscreen : Control

var gameOver      := false
var reticleOffset := Vector2(32.0, 32.0)

@onready var viewport = get_parent()

func _ready() -> void:
	followTarget.look_at(lookAtTarget.global_position)

func _get_rotation_lerp(from: float, to:float, minWeight: float):
	var weight = clamp(pow(abs(player.global_rotation.x), 2.0) + minWeight, minWeight, 1.0)
	return lerp_angle(from, to, weight)

func _physics_process(_delta: float) -> void:
	global_position = lerp(global_position, followTarget.global_position, 0.3)
	global_rotation.x = _get_rotation_lerp(global_rotation.x, followTarget.global_rotation.x, 0.08)
	global_rotation.y = _get_rotation_lerp(global_rotation.y, followTarget.global_rotation.y, 0.08)
	global_rotation.z = _get_rotation_lerp(global_rotation.z, followTarget.global_rotation.z, 0.03)

	if gameOver:
		enemyOffscreen.visible = false
		enemyOnscreen.visible = false
	else:
		enemyOnscreen.set_shielded(player.enemyPlayer.shield.visible)
		if is_position_in_frustum(player.enemyPlayer.global_position):
			var screenPosition    := unproject_position(player.enemyPlayer.global_position)
			enemyOnscreen.global_position = Vector2(screenPosition - reticleOffset)
			enemyOnscreen.set_hitable(player.enemyPlayer.isHitable)
			enemyOffscreen.hide()
			enemyOnscreen.show()
		else:
			var viewportCentre    := Vector2(viewport.size) / 2.0
			var localToCamera     := to_local(player.enemyPlayer.global_position)
			var screenPosition    := Vector2(localToCamera.x, -localToCamera.y)
			var maxScreenPosition := viewportCentre - reticleOffset
			if screenPosition.abs().aspect() > maxScreenPosition.abs().aspect():
				screenPosition.x *= maxScreenPosition.x / abs(screenPosition.x)
			else:
				screenPosition.y *= maxScreenPosition.y / abs(screenPosition.y)
			enemyOffscreen.global_position = Vector2(viewportCentre + screenPosition - reticleOffset)
			var angle = Vector2.LEFT.angle_to(screenPosition)
			enemyOffscreen.rotation = angle
			enemyOffscreen.show()
			enemyOnscreen.hide()
