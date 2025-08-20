extends AudioStreamPlayer

func _ready() -> void:
	if not Global.settingsData.musicOn:
		volume_db = -80.0
