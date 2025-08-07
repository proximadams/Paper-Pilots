extends CharacterBody3D

const WING_DEGREES = 45.0

@export var wingsLeftRotation: Vector2
@export var wingsUpRotation  : Vector2

@export var leftMoveableWing : Node3D
@export var rightMoveableWing: Node3D

func _process(_delta: float) -> void:
	var inputDirection = Vector2()
	inputDirection.x = (Input.get_action_strength('move_left') - Input.get_action_strength('move_right'))
	inputDirection.y = (Input.get_action_strength('move_up') - Input.get_action_strength('move_down'))
	leftMoveableWing.rotation.x  = deg_to_rad(inputDirection.x + inputDirection.y) * WING_DEGREES
	rightMoveableWing.rotation.x = deg_to_rad(-inputDirection.x + inputDirection.y) * WING_DEGREES
