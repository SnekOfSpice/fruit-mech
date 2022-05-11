extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"



func show_player_deck_list():
	pass


func show_event_deck_list():
	pass




func event_clicked(event_type):
	match event_type:
		GameData.EventTypes.Boss:
			pass
		GameData.EventTypes.Combat:
			pass
		GameData.EventTypes.Entropy:
			pass
		GameData.EventTypes.NormalEvent:
			pass
