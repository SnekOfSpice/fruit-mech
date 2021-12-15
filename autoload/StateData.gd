extends Node


enum States {PlayerTurnActive, PlayerTurnPassive, EnemyTurn, GameOver, SelectingEvent}

var current_state = 0
var fast_forward_enabled = false

func set_current_state(value: int):
	current_state = value
	
	if current_state == States.PlayerTurnActive:
		for c in get_tree().get_nodes_in_group("PlayerTurnActiveOnly"):
			c.visible = true
	else:
		for c in get_tree().get_nodes_in_group("PlayerTurnActiveOnly"):
			c.visible = false
