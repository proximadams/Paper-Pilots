extends Node3D

@export var playerArr: Array[CharacterBody3D]

func _process(_delta: float) -> void:
	var bottomY = 0.0
	for currPlayer in playerArr:
		if currPlayer.global_position.y < bottomY:
			bottomY = currPlayer.global_position.y
	global_position.y = bottomY - 5000.0
