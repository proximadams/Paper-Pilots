extends CharacterBody3D

const WING_DEGREES = 45.0

@export var leftMoveableWing : Node3D
@export var rightMoveableWing: Node3D

@export var propellor: MeshInstance3D

func _process(delta: float) -> void:
	handle_input_wing_angles()
	handle_spin_propellor(delta)
	handle_rotation(delta)

func handle_rotation(delta: float) -> void:
	var inputDirection = get_input_direction()
	rotate_object_local(Vector3.RIGHT, delta * inputDirection.y)
	rotate_object_local(Vector3.FORWARD, delta * inputDirection.x)

func handle_spin_propellor(delta: float) -> void:
	propellor.rotation.z += delta * 10.0

func handle_input_wing_angles() -> void:
	var inputDirection = get_input_direction()
	leftMoveableWing.rotation.x  = deg_to_rad(inputDirection.x - inputDirection.y) * WING_DEGREES
	rightMoveableWing.rotation.x = deg_to_rad(-inputDirection.x - inputDirection.y) * WING_DEGREES

func get_input_direction() -> Vector2:
	var result = Vector2()
	result.x = (Input.get_action_strength('move_left') - Input.get_action_strength('move_right'))
	result.y = (Input.get_action_strength('move_up') - Input.get_action_strength('move_down'))
	return result
