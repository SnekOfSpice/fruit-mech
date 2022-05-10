extends ScrollContainer

var component_card = preload("res://src/player/ComponentCard.tscn")

onready var vbox = $VBoxContainer
var row_size = 3

var separation_x = 13
var separation_y = 27

func _ready() -> void:
	update_spacing_vars()
	show_deck_list()
	vbox.add_constant_override("separation", separation_y)

func update_spacing_vars():
	# func that adjusts row_size, separation_x and separation_y based on window size
	var window_size = OS.window_size
	separation_x = max(13, 13/1280 * window_size.x)
	separation_y = max(27, 27/720 * window_size.y)
	row_size = int(window_size.x / 426)
	# magic numbers galore lmao
	

func show_deck_list():
	var row_container = HBoxContainer.new()
	var card_count_row = 0
	var card_count_global = 0
	
	# iterate over every card the player has in their deck
	for card_info in PlayerData.player_deck_list:
		# add the card to the view container
		var card = component_card.instance()
		row_container.add_child(card)
		# set the card object info to the values of the dict in the deck list
		card.call_deferred("set_fruit_id", card_info.get("fruit_id"))
		# TODO: set upgrade params
		card.call_deferred("upgrade_to_level", card_info.get("upgrade_level"))
		
		card_count_row += 1
		card_count_global += 1
		# if the row is filled or an incomplete last row is done, add the container to the larger container
		if card_count_row >= row_size || card_count_global >= PlayerData.player_deck_list.size():
			row_container.add_constant_override("separation", separation_x)
			vbox.add_child(row_container)
			row_container = HBoxContainer.new()
			card_count_row = 0


func _on_Timer_timeout() -> void:
	show_deck_list()
