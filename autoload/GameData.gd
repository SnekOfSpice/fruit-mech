extends Node

var fruit_data = {}
var enemy_data = {}
var enemy_action_data = {}
var entropy_data = {}

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
