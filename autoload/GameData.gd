extends Node

enum EventTypes{
	Combat,
	Boss,
	Entropy,
	NormalEvent
}

var fruit_data = {}
var enemy_data = {}
var enemy_action_data = {}
var entropy_data = {}
var deck_lists = {}

func _ready() -> void:
	var data_file = File.new()
	data_file.open("res://data/FruitMech.json", File.READ)
	var data_json = JSON.parse(data_file.get_as_text())
	data_file.close()
	data_json = data_json.result
	fruit_data = data_json.get("fruits")
	enemy_data = data_json.get("enemies")
	enemy_action_data = data_json.get("enemy_actions")
	entropy_data = data_json.get("entropy_events")
	deck_lists = data_json.get("deck_lists")
	
	# make deck list into an array of ints
	#print(deck_lists)
	var i = 0
	for d in deck_lists:
		var list_item = deck_lists.get(d)
		var raw_list = list_item.get("list_content")
		var conv_list = raw_list.split(",")
		conv_list = Array(conv_list)
		var list_size = conv_list.size()
		for index in range(list_size):
			conv_list[index] = int(conv_list[index])
		deck_lists[d]["list_content"] = conv_list
		i += 1
	#print(deck_lists)
	# placeholder
	
	PlayerData.set_player_deck_list(deck_lists.get("0").get("list_content"))
	print(PlayerData.player_deck_list)
