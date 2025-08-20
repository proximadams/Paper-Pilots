extends Control

var started = false

@onready var musicToggle: Button = $SubViewportContainer/SubViewport/SettingsMenu/SettingsOptions/MusicToggle

func _input(_event: InputEvent) -> void:
	if not started:
		started = true
		Music.stop()
		if Global.settingsData.musicOn:
			$InitialSong.play()
		else:
			on_music_toggled(false)
			musicToggle.set_pressed_no_signal(false)

func start_game() -> void:
	Music.volume_db = -10.0
	get_tree().change_scene_to_file('res://scenes/level.tscn')

func start_default_music() -> void:
	if Global.settingsData.musicOn:	
		Music.play()

func on_music_toggled(toggledOn: bool) -> void:
	if toggledOn:
		Music.play()
		musicToggle.text = 'Music = ON'
		Global.settingsData.musicOn = true
		Global.save_settings()
	else:
		Music.stop()
		$InitialSong.stop()
		musicToggle.text = 'Music = OFF'
		Global.settingsData.musicOn = false
		Global.save_settings()
