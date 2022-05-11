extends Node2D


var event_card = preload("res://src/events/EventCard.tscn")

onready var event_card_container = $EventCardContainer

var choice_max = 3
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_options()


func show_options():
	rng.randomize()
	var deck_list : Array = PlayerData.event_deck_list
	var choices : Array = []
	
	# pick a random card from the event deck for choice_max or until no card remains
	var current_picked_card_count = 0
	while current_picked_card_count < 3 && deck_list.size() > 0:
		current_picked_card_count += 1
		var rand_choice = rng.randi_range(0, deck_list.size() - 1)
		choices.append(deck_list[rand_choice])
		deck_list.remove(rand_choice)
	
	# now show those choices
	for c in choices:
		var new_card = event_card.instance()
		new_card.call_deferred("set_is_clickable", true)
		# print(new_card.rect_size.x)
		# for some reason this returns 0, so magic numbers it is
		event_card_container.add_constant_override("separation", 216)
		event_card_container.add_child(new_card)


