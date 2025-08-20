extends Control

var started = false

@onready var musicToggle = $SubViewportContainer/SubViewport/SettingsMenu/SettingsOptions/MusicToggle

func _input(_event: InputEvent) -> void:
	if not started:
		started = true
		Music.stop()
		$InitialSong.play()

func start_game() -> void:
	Music.volume_db = -10.0
	get_tree().change_scene_to_file('res://scenes/level.tscn')

func start_default_music() -> void:
	Music.play()

func on_music_toggled(toggledOn: bool) -> void:
	if toggledOn:
		Music.play()
		musicToggle.text = 'Music = ON'
	else:
		Music.stop()
		$InitialSong.stop()
		musicToggle.text = 'Music = OFF'
