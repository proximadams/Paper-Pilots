extends Camera3D

@export var followTarget: Node3D
@export var lookAtTarget: Node3D
@export var player      : CharacterBody3D
@export var enemyArrow  : Control

var enemyArrowOffset := Vector2(32.0, 32.0)

@onready var viewport = get_parent()

func _physics_process(_delta: float) -> void:
	global_position = lerp(global_position, followTarget.global_position, 0.15)
	look_at(lookAtTarget.global_position)
	if is_position_in_frustum(player.enemyPlayer.global_position):
		enemyArrow.hide()
	else:
		var viewportCentre    := Vector2(viewport.size) / 2.0
		var localToCamera     := to_local(player.enemyPlayer.global_position)
		var screenPosition    := Vector2(localToCamera.x, -localToCamera.y)
		var maxScreenPosition := viewportCentre - enemyArrowOffset
		if screenPosition.abs().aspect() > maxScreenPosition.abs().aspect():
			screenPosition.x *= maxScreenPosition.x / abs(screenPosition.x)
		else:
			screenPosition.y *= maxScreenPosition.y / abs(screenPosition.y)
		enemyArrow.show()
		enemyArrow.global_position = Vector2(viewportCentre + screenPosition - enemyArrowOffset)
		var angle = Vector2.LEFT.angle_to(screenPosition)
		enemyArrow.rotation = angle
