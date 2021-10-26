extends Node


enum States {PlayerTurnActive, PlayerTurnPassive, EnemyTurn, GameOver}

var current_state = 0

func set_current_state(value: int):
	current_state = value
	
	if current_state == States.PlayerTurnActive:
		for c in get_tree().get_nodes_in_group("PlayerTurnActiveOnly"):
			c.visible = true
	else:
		for c in get_tree().get_nodes_in_group("PlayerTurnActiveOnly"):
			c.visible = false
