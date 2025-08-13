extends Control

var started = false

func _input(event: InputEvent) -> void:
	if not started:
		started = true
		Music.play()

func start_game() -> void:
	Music.volume_db = -15.0
	get_tree().change_scene_to_file('res://scenes/level.tscn')
