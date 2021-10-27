extends HBoxContainer


onready var tex = $TextureRect
onready var label = $Label

func set_type(value: String):
	match value:
		"heal":
			tex.texture = load("res://assets/sprites/player/slot_icon_heal.png")
			label.self_modulate = Color8(240, 48, 132)
		"attack":
			tex.texture = load("res://assets/sprites/player/slot_icon_attack.png")
			label.self_modulate = Color8(234, 23, 44)
		"armor":
			tex.texture = load("res://assets/sprites/player/slot_icon_armor.png")
			label.self_modulate = Color8(47, 116, 115)
		"rot":
			tex.texture = load("res://assets/sprites/player/slot_icon_rot.png")
			label.self_modulate = Color8(240, 124, 26)

func set_value(value):
	$Label.text = str(value)
