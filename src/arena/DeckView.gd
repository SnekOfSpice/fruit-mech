extends ScrollContainer

var component_card = preload("res://src/player/ComponentCard.tscn")

onready var vbox = $VBoxContainer
const ROW_SIZE = 3

const SEPARATION_X = 13
const SEPARATION_Y = 27

func _ready() -> void:
	show_deck_list()
	vbox.add_constant_override("separation", SEPARATION_Y)
	
func show_deck_list():
	var row_container = HBoxContainer.new()
	var card_count_row = 0
	var card_count_global = 0
	
	for card_info in PlayerData.player_deck_list:
		var card = component_card.instance()
		row_container.add_child(card)
		
		card.call_deferred("set_fruit_id", card_info.get("fruit_id"))
		
		
		card_count_row += 1
		card_count_global += 1
		if card_count_row >= ROW_SIZE || card_count_global >= PlayerData.player_deck_list.size():
			row_container.add_constant_override("separation", SEPARATION_X)
			vbox.add_child(row_container)
			row_container = HBoxContainer.new()
			card_count_row = 0


func _on_Timer_timeout() -> void:
	show_deck_list()
