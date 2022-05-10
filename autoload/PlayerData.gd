extends Node

enum CardLocations{
	Deck, Hand, Mech, Enemy, Compost
}
var player_deck_list = []
# {"fruit_id": 0, "upgrade_level": 0, "card_location": 0}
# fruit id is the id of the card used to pull the data from the json
# upgrade level is self-explanatory
# card_location denotes where the card currently is: in the player's Hand, Deck, Mech, or in stasis by an Enemy, or removed entirely

var event_deck_list = []

# takes in an array of ints and adds all the needed info
func set_player_deck_list(fruit_ids: Array):
	player_deck_list.clear()
	for i in fruit_ids:
		var card_data = {"fruit_id": i, "upgrade_level": 5, "card_location": CardLocations.Deck}
		player_deck_list.append(card_data)
