extends Control


var event_type: int = 0

onready var select_button = $SelectButton
onready var sfx_player = $SFXPlayer

var is_clickable = false

signal event_clicked

func set_event_type(value: int):
	event_type = value


func select_event():
	print(str("selected event ", event_type))

func set_is_clickable(value: bool):
	is_clickable = value
	select_button.disabled = !is_clickable
	select_button.visible = is_clickable
	

#
#func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
#	if StateData.current_state == StateData.States.SelectingEvent:
#		if event is InputEventMouseButton:
#			if event.is_action_released("mouse_left"):
#				select_event()
#
#
#
#func _on_Area2D_mouse_entered() -> void:
#	rect_scale = Vector2(1.1, 1.1)
#	sfx_player.stream = load(AudioData.SFX_UI_CARD_HOVER_PATH)
#	sfx_player.volume_db = AudioData.db_level
#	sfx_player.play(0.0)
#
#
#func _on_Area2D_mouse_exited() -> void:
#	rect_scale = Vector2(1.0, 1.0)


func _on_SelectButton_button_up() -> void:
	print("pressed event selection")
	var controllers = get_tree().get_nodes_in_group("GameController")
	if controllers.size() > 0:
		var controller = controllers[0]
		connect("event_clicked", controller, "event_clicked")
		emit_signal("event_clicked", event_type)
		disconnect("event_clicked", controller, "event_clicked")
