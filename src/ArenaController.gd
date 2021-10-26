extends Node2D
#class_name ArenaController

const CAMERA_WIGGLE = 0.02
const HAND_LEFT_MARGIN = 100
const HAND_SIZE_LIMIT = 5
const ENTROPY_STAGES = [5, 8, 15]

var component_card = preload("res://src/ComponentCard.tscn")

var current_enemy: Enemy = null

const STARTING_HAND_SIZE = 4
var cards_in_hand = []

var kill_count: int = 0

onready var camera = $Camera2D
onready var tween = $Tween
onready var player = $Player
onready var enemy = $Enemy
onready var turn_step_timer = $TurnStepTimer
onready var kill_count_label = $Camera2D/KillCountLabel
onready var entropy_event_container = $EntropyEventContainer
onready var entropy_label = $EntropyEventContainer/Label
onready var entropy_sprite = $EntropyEventContainer/AnimatedSprite
onready var entropy_timer = $EventStepTimer
onready var pause_container = $Camera2D/PauseContainer

onready var sfx_player = $SFXPlayer
onready var game_over_kill_count_label = $Camera2D/GameOverContainer/VBoxContainer/KillCount
onready var game_over_container = $Camera2D/GameOverContainer


signal random_card_discarded

func _ready() -> void:
	pause_container.visible = false
	game_over_container.visible = false
	generate_cards(STARTING_HAND_SIZE)
	current_enemy = enemy # for playtest purposes only (maybe not lmao)
	set_kill_count(0)
	
	
	# play music
	var next_path = AudioData.get_next_combat_track()
	$MusicPlayer.stream = load(next_path)
	$MusicPlayer.volume_db = AudioData.db_level
	$MusicPlayer.playing = true

func _process(delta: float) -> void:
	# position camera
	var cen_x = OS.window_size.x / 2
	var cen_y = OS.window_size.y / 2
	var mouse_pos = get_local_mouse_position()
	var delta_x = float(cen_x - mouse_pos.x)
	var delta_y = float(cen_y - mouse_pos.y)
	delta_x = delta_x * CAMERA_WIGGLE
	delta_y = delta_y * CAMERA_WIGGLE
	
	var cam_origin = Vector2(-50, 76)
	camera.position = cam_origin + Vector2( cen_x -delta_x, cen_y - delta_y)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		pause_container.visible = !pause_container.visible

func restart_match():
	set_kill_count(0)
	for card in cards_in_hand:
		card.discard_card()
	regenerate_enemy()
	player.set_current_hp(player.MAX_HP, false, true)
	player.set_current_armor(player.STARTING_ARMOR)
	generate_cards(STARTING_HAND_SIZE)
	game_over_container.visible = false
	

func set_kill_count(value: int):
	kill_count = value
	# label things
	var entropy_string = ""
	var count_down = 0
	# only label entropy event after a few wins > that's boring
	if kill_count < ENTROPY_STAGES[0]:
		count_down = 5 - kill_count
		count_down += 1
	
	if kill_count > ENTROPY_STAGES[2]:
		# will be on every kill after this stage
		count_down = 1
	else:
		if kill_count >= ENTROPY_STAGES[0] + 1 && kill_count <= ENTROPY_STAGES[1]: # every 3 turns
			count_down = 3 - (kill_count % 3)

		if kill_count >= ENTROPY_STAGES[1] + 1 && kill_count <= ENTROPY_STAGES[2]: # every 2 turns
			count_down = 2 - (kill_count % 2)
			
	entropy_string = str("Entropic Event in: ", count_down, " kills")
	
	kill_count_label.text = str(
		"Kill Count: ", kill_count, "\n",
		entropy_string
	)

func generate_cards(amount: int):
	for i in range(amount):
		var new_card = component_card.instance()
		
		# generate random fruit index
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var rand_id = rng.randi_range(0, 7)
		new_card.call_deferred("set_fruit_id", rand_id)
		
		# determine position for that card
		#new_card.set_card_origin(card_position_at_index(i))
		new_card.set_card_origin(card_position_at_index(cards_in_hand.size()))
		
		add_child(new_card)
		cards_in_hand.append(new_card)

func card_position_at_index(index: int):
	var result = Vector2.ZERO
	var card_margin = (OS.window_size.x - (2 * HAND_LEFT_MARGIN)) / HAND_SIZE_LIMIT
	var y_margin = (OS.window_size.y * 0.75)
	result = Vector2(HAND_LEFT_MARGIN + card_margin * index, y_margin)
#	# push down on the left side
#	var e = 6 - index
#	result.y += e * 10
	
	return result


func remove_card_from_hand(card: ComponentCard, delete_card: bool):
	if delete_card:
		var invis = card.modulate
		invis.a = 0.0
		tween.interpolate_property(card, "modulate", card.modulate, invis, 0.5)
		tween.start()
	
		yield(tween, "tween_all_completed")
	
	var index = cards_in_hand.find(card)
	#print(index)
	# move all cards after this index 1 to the left
	var i = 0
	for card in cards_in_hand:
		if i > index:
			var new_pos = card_position_at_index(i - 1)
			#card.card_origin = new_pos # do not use set_card_origin because that func automatically sets the position but we wanna use the tween to have that go smooth
			tween.interpolate_property(card, "rect_global_position", card.rect_global_position, new_pos, 0.5)
			
		i += 1
	
	
	tween.start()
	# actually remove that card
	cards_in_hand.remove(index)
	yield(tween, "tween_all_completed")
	
	i = 0
	for card in cards_in_hand:
		if i >= index:
			var new_pos = card_position_at_index(i)
			card.set_card_origin(new_pos)
			#card.card_origin = new_pos
			i += 1
	
	if delete_card:
		card.call_deferred("delete_self")


func start_player_turn():
	StateData.set_current_state(StateData.States.PlayerTurnActive)
	# since this is where the enemy using their action signals to, we have to check here for rotted components as well
	remove_rotted_components()
	update_slot_labels()
	# reduce armor duration
	player.set_current_armor(player.current_armor - 1)
	
	# draw 1 card if cards in hand
	# draw 3 cards if no cards in hand
	var card_count = cards_in_hand.size()
	if card_count >= 1:
		generate_cards(1)
	else:
		generate_cards(3)
	pass

func discard_n_cards(number_of_cards: int):
	for i in range(number_of_cards):
		discard_random_card()
		yield(self, "random_card_discarded")

# enemy actions
func discard_random_card():
	if cards_in_hand.size() > 0:
		# remove_card_from_hand(card: ComponentCard, delete_card: bool):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var target_index = rng.randi_range(0, cards_in_hand.size() - 1)
		var target_card = cards_in_hand[target_index]
		remove_card_from_hand(target_card, true)
		
		# for multi-discard
		call_deferred("emit_signal", "random_card_discarded")

func deal_damage_to_player(damage: int):
	player.set_current_hp(player.current_hp - damage, true, false)

func rot_player_components(rot_range: int, rot_strength: int):
	player.rot_components(rot_range, rot_strength)
	update_slot_labels()

func remove_rotted_components():
	for slot in get_tree().get_nodes_in_group("ComponentSlot"):
		#print("iterat slot")
		if slot.has_card():
			#print("slot has card")
			#print(str("rot ", slot.component_card.current_rot))
			if slot.component_card.current_rot <= 0:
				#print("rot")
				slot.component_card.call_deferred("delete_self")
				slot.component_card.delete_self()

func update_slot_labels():
	for c in get_tree().get_nodes_in_group("ComponentSlot"):
		c.update_stats()

func end_player_turn():
	# play eot sound
	sfx_player.stream = load(AudioData.SFX_UI_PLAYER_END_TURN_PATH)
	sfx_player.volume_db = AudioData.db_level + 10
	sfx_player.play(0.0)
	
	StateData.set_current_state(StateData.States.PlayerTurnPassive)
	# auto-execute all components
	player.use_components()
	# since use_components has such a variable use duration, we split the end of turn into two parts
	
func cleanup_player_turn():
	
	# rot all components
	player.rot_components(-1, -1)
	remove_rotted_components()
	update_slot_labels()
	
	turn_step_timer.start()
	yield(turn_step_timer, "timeout")
	
	
	# discard all cards in hand if over limit, else do nothing
	if cards_in_hand.size() > HAND_SIZE_LIMIT:
		for card in cards_in_hand:
			card.discard_card()
	
	turn_step_timer.start()
	yield(turn_step_timer, "timeout")
	
	# if the enemy is alive, start its turn
	if enemy.current_hp > 0:
		start_enemy_turn()
	else:
		enemy_died()
	# else, regen the enemy

func start_enemy_turn():
	StateData.set_current_state(StateData.States.EnemyTurn)
	# deduct enemy armor
	enemy.set_current_armor(enemy.current_armor - 1)
	
	turn_step_timer.start()
	yield(turn_step_timer, "timeout")
	
	# have enemy attack
	if is_instance_valid(current_enemy):
		current_enemy.use_action()
	else:
		#print("enemy not valid")
		# wait for the signal to come through to call start_player_turn()
		pass

func attack_enemy(attack_damage):
	enemy.set_current_hp(enemy.current_hp - attack_damage, true)

func enemy_died():
	# fade enemy out
	tween.interpolate_property(enemy, "modulate", enemy.modulate, Color(1,1,1,0), 1.3)
	tween.start()
	yield(tween, "tween_all_completed")
	# increment kill count
	set_kill_count(kill_count + 1)
	# if we're at a kill count where an entropy event happens, call entropy event (which will regen the enemy at its end of turn), else we just call the regen raw
	
	if is_entropic_event(kill_count):
		entropy_event()
	else:
		regenerate_enemy()

func regenerate_enemy():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rand = rng.randi_range(0, 2)
	enemy.set_enemy_id(rand)
	# generate the next action based on that id, so that the previous action doesn't carry over
	enemy.set_next_action()
	
	# fade enemy in
	tween.interpolate_property(enemy, "modulate", enemy.modulate, Color(1,1,1,1), 1.3)
	tween.start()
	yield(tween, "tween_all_completed")
	
	# that's the enemy turn, start player turn
	start_player_turn()

func entropy_event():
	toggle_card_visibility(false)
	#print("entropic event")
	# determine which event
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rand = rng.randi_range(0, 3)
	var ent_data = GameData.entropy_data.get(str(rand))
	#print(ent_data)
	
	# set stats
	var hand_destroy = int(ent_data.get("event_card_hand_destroy"))
	var event_damage = int(ent_data.get("event_damage"))
	var event_name = ent_data.get("event_name")
	var event_rot_range = int(ent_data.get("event_rot_range"))
	var event_rot_strength = int(ent_data.get("event_rot_strength"))
	
	entropy_label.text = str(event_name)
	entropy_sprite.play(str("event", rand))
	entropy_label.rect_global_position.y = 100
	
	# play sound
	sfx_player.stream = load(AudioData.SFX_UI_ENTROPY_POPUP_PATH)
	sfx_player.volume_db = AudioData.db_level
	sfx_player.play(0.0)
	
	# show event
	tween.interpolate_property(entropy_event_container, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.3)
	tween.start()
	yield(tween, "tween_all_completed")
	
	turn_step_timer.start()
	yield(turn_step_timer, "timeout")
	turn_step_timer.start()
	yield(turn_step_timer, "timeout")
	
	toggle_card_visibility(true)
	
	if event_damage > 0:
		entropy_timer.start()
		yield(entropy_timer, "timeout")
		deal_damage_to_player(event_damage)
		
	
	if hand_destroy > 0:
		entropy_timer.start()
		yield(entropy_timer, "timeout")
		discard_n_cards(hand_destroy)
	
	if event_rot_range != 0:
		entropy_timer.start()
		yield(entropy_timer, "timeout")
		rot_player_components(event_rot_range, event_rot_strength)
	
	
	# hide container
	tween.interpolate_property(entropy_event_container, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.3)
	tween.start()
	yield(tween, "tween_all_completed")
	# spawn enemy
	regenerate_enemy()
	
func is_entropic_event(request: int):
	if request <= ENTROPY_STAGES[0]:
		return false
	
	if request >= ENTROPY_STAGES[0] + 1 && request <= ENTROPY_STAGES[1]: # every 3 turns
		if request % 3 == 0:
			return true
	
	if request >= ENTROPY_STAGES[1] + 1 && request<= ENTROPY_STAGES[2]: # every 2 turns
		if request % 2 == 0:
			return true
	
	if request > ENTROPY_STAGES[2]: # every turn
		return true

func toggle_card_visibility(value: bool):
	for card in cards_in_hand:
		card.visible = value

func game_over():
	game_over_container.visible = true
	game_over_kill_count_label.text = str("KILL COUNT: ", kill_count)
	
	# hide all cards
	toggle_card_visibility(false)
	
	# play sound
	sfx_player.stream = load(AudioData.SFX_UI_DEFEAT_PATH)
	sfx_player.volume_db = AudioData.db_level + 10
	sfx_player.play(0.0)


func _on_TextureButton_pressed() -> void:
	if StateData.current_state == StateData.States.PlayerTurnActive:
		end_player_turn()


func _on_MusicPlayer_finished() -> void:
	var next_path = AudioData.get_next_combat_track()
	$MusicPlayer.stream = load(next_path)
	$MusicPlayer.volume_db = AudioData.db_level
	$MusicPlayer.play(0.0)
	


func _on_BackButton_pressed() -> void:
	pause_container.visible = false


func _on_MainMenuButton_pressed() -> void:
	get_tree().change_scene("res://src/main_menu/MainMenuController.tscn")


func _on_RestartButton_pressed() -> void:
	restart_match()

func play_button_down_sfx():
	# play button sound
	sfx_player.stream = load(AudioData.SFX_UI_BUTTON_PRESS_PATH)
	sfx_player.volume_db = AudioData.db_level + 10
	sfx_player.play(0.0)
	# sounds kinda stupid ngl

func _on_RestartButton_button_down() -> void:
	#play_button_down_sfx()
	pass

func _on_MainMenuButton_button_down() -> void:
	#play_button_down_sfx()
	pass


func _on_BackButton_button_down() -> void:
	#play_button_down_sfx()
	pass


func _on_VolumeSlider_value_changed(value: float) -> void:
	AudioData.db_level = value
	$MusicPlayer.volume_db = value
	sfx_player.volume_db = value
