extends Control

@onready var hitableTexture  : TextureRect = $HitableTexture
@onready var unhitableTexture: TextureRect = $UnhitableTexture

func set_hitable(valueGiven: bool) -> void:
	hitableTexture.visible   = valueGiven
	unhitableTexture.visible = !valueGiven

func set_shielded(valueGiven: bool) -> void:
	if valueGiven:
		hitableTexture.scale.x = 0.0
		unhitableTexture.scale.x = 0.0
	else:
		hitableTexture.scale.x = 1.0
		unhitableTexture.scale.x = 1.0
