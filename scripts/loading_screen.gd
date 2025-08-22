extends Control

@export var assetArr   : Array[Resource]
@export var progressBar: ProgressBar

var assetIndex := 0
var nextScene  := ''
var previousInst = null

@onready var assetHolder  : Node3D = $AssetHolder
@onready var origSfxVolume: float  = Global.settingsData.sfxVolume

func _process(_delta: float) -> void:
	if nextScene != '':
		progressBar.set_value(progressBar.max_value * (float(assetIndex) / (float(assetArr.size()) +1.0)))
		if assetIndex < assetArr.size() or previousInst != null:
			if previousInst == null:
				previousInst = assetArr[assetIndex].instantiate()
				assetHolder.add_child(previousInst)
				assetIndex += 1
			else:
				previousInst.free()
				previousInst = null
		else:
			Global.settingsData.sfxVolume = origSfxVolume
			get_tree().change_scene_to_file(nextScene)
			nextScene = ''
	elif assetIndex != 0:
		assetIndex = 0
		visible = false
		for currChild in assetHolder.get_children():
			currChild.queue_free()

func load(scenePathGiven: String) -> void:
	nextScene = scenePathGiven
	assetIndex = 0
	visible = true
	Global.settingsData.sfxVolume = 0.0
