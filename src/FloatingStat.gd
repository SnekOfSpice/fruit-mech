extends Node2D


const DISTANCE_Y = 200
const OFFSET_X_RANGE = 60
const ANIM_DURATION = 2.5

var value = 0
onready var tween = $Tween
onready var type_label = $HBoxContainer/Label
onready var value_label = $HBoxContainer/Label2
onready var tex = $HBoxContainer/TextureRect

func _ready() -> void:
	start_floating()

func set_value(val):
	value_label.text = str(value)

func set_color(col):
	value_label.modulate = col
	type_label.modulate = col

func set_type(value: String):
	match value:
		"heal":
			tex.texture = load("res://assets/sprites/player/slot_icon_heal.png")
			set_color(Color8(240, 48, 132))
			type_label.text = "Heal"
		"attack":
			tex.texture = load("res://assets/sprites/player/slot_icon_attack.png")
			set_color(Color8(234, 23, 44))
			type_label.text = "Attack"
		"armor":
			tex.texture = load("res://assets/sprites/player/slot_icon_armor.png")
			set_color(Color8(47, 116, 115))
			type_label.text = "Armor"
		"rot":
			tex.texture = load("res://assets/sprites/player/slot_icon_rot.png")
			set_color(Color8(240, 124, 26))
			type_label.text = "Rot"


func start_floating():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var target_x = rng.randi_range(position.x - OFFSET_X_RANGE, position.x + OFFSET_X_RANGE)
	var target_y = position.y - DISTANCE_Y
	var target_pos = Vector2(target_x, target_y)
	tween.interpolate_property(self, "position", position, target_pos, ANIM_DURATION)
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), ANIM_DURATION, Tween.TRANS_EXPO)
	
	tween.call_deferred("start")


func _on_Tween_tween_all_completed() -> void:
	queue_free()
