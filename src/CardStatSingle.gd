extends VBoxContainer

onready var tex = $TextureRect

func set_type(value: String):
	match value:
		"heal":
			tex.texture = load("res://assets/sprites/player/card_icon_heal.png")
		"attack":
			tex.texture = load("res://assets/sprites/player/card_icon_attack.png")
		"armor":
			tex.texture = load("res://assets/sprites/player/card_icon_armor.png")

func set_value(value):
	$Label.text = str(value)
