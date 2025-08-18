extends Control

var started = false

func _input(_event: InputEvent) -> void:
	if not started:
		started = true
		Music.stop()
		$InitialSong.play()

func start_game() -> void:
	Music.volume_db = -10.0
	if not Music.playing:
		Music.play()
	get_tree().change_scene_to_file('res://scenes/level.tscn')

func start_default_music() -> void:
	Music.play()
