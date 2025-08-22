extends Control

@export var controllerCountLabel   : Label
@export var visibleControllerCount2: Array[Label]
@export var visibleControllerCount1: Array[Label]
@export var visibleControllerCount0: Array[Label]

var oldNumDevicesConnected := 0
var screenIndex := 0

@onready var screenArr: Array[Control] = _get_screen_children()

func _ready() -> void:
	for currScreen in screenArr:
		currScreen.visible = false
	if 0 < screenArr.size():
		screenArr[0].visible = true
	_refresh_visible_labels()

func _process(_delta: float) -> void:
	if screenIndex == 0:
		if oldNumDevicesConnected != Global.numDevicesConnected:
			if Global.numDevicesConnected == 2:
				on_next_button_pressed()
			else:
				if Global.numDevicesConnected == 1:
					controllerCountLabel.text = str(Global.numDevicesConnected) + ' controller\ndetected.'
				else:
					controllerCountLabel.text = str(Global.numDevicesConnected) + ' controllers\ndetected.'
	if oldNumDevicesConnected != Global.numDevicesConnected:
		oldNumDevicesConnected = Global.numDevicesConnected
		_refresh_visible_labels()

func _refresh_visible_labels():
	var visibleArr: Array[bool] = [false, false, false]
	var visibleIndex: int = clamp(Global.numDevicesConnected, 0, 2)
	visibleArr[visibleIndex] = true
	for currLabel in visibleControllerCount0:
		currLabel.visible = visibleArr[0]
	for currLabel in visibleControllerCount1:
		currLabel.visible = visibleArr[1]
	for currLabel in visibleControllerCount2:
		currLabel.visible = visibleArr[2]

func _get_screen_children() -> Array[Control]:
	var result: Array[Control] = []
	for currChild in get_children():
		if currChild is Control and not currChild is Button:
			result.append(currChild)
	return result

func on_next_button_pressed() -> void:
	screenArr[screenIndex].visible = false
	screenIndex += 1
	if screenIndex < screenArr.size():
		screenArr[screenIndex].visible = true
	else:
		get_tree().change_scene_to_file('res://scenes/level.tscn')
