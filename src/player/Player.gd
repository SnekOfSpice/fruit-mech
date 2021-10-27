extends Node2D

const MAX_HP = 30
const STARTING_ARMOR = 10
const ARMOR_DAMAGE_REDUCTION = 0.5

var current_hp = MAX_HP
var current_armor = 0

var floating_number = preload("res://src/player/FloatingNumber.tscn")
var floating_stat = preload("res://src/player/FloatingStat.tscn")
var floating_armor = preload("res://src/player/FloatingArmor.tscn")

onready var use_component_timer = $UseComponentTimer
onready var sfx_player = $SFXPlayer
onready var component_set_timer = $ComponentStepTimer
onready var label_hp = $StatsBox/HealthBox/Label
onready var label_armor = $StatsBox/ArmorBox/Label
onready var armor_box = $StatsBox/ArmorBox
onready var status_sprite = $StatusSprite

signal cleanup_player_turn
signal attack_enemy
signal game_over

func _ready() -> void:
	#set_current_hp(1, false, true)
	set_current_hp(MAX_HP, false, true)
	set_current_armor(STARTING_ARMOR)

func set_current_hp(value: int, show_floating_number: bool, ignore_armor: bool):
	var starting_hp = current_hp
	
	var damage = current_hp - value
	damage = stepify(damage, 1.0)
	#var damage = value
	if !ignore_armor:
		if current_armor > 0 && damage > 0: # check for damage > 0 since this function can also be used to heal
			set_current_armor(current_armor - damage)
			damage *= 1.0 - ARMOR_DAMAGE_REDUCTION
			
			# floating armor
			var new_armor = floating_armor.instance()
			new_armor.global_position = $FloatingNumberPos.global_position
			get_parent().call_deferred("add_child", new_armor)
		
	if damage > 0 && show_floating_number: 
		flicker()
	
	current_hp -= damage
	current_hp = clamp(current_hp, 0, MAX_HP)
	current_hp = stepify(current_hp, 1.0)
	label_hp.text = str(current_hp)
	
	damage = stepify(damage, 1.0)
	if show_floating_number && starting_hp != current_hp: # compare to starting hp to only show a number if a change actually happened
		if get_parent().is_in_group("ArenaController"):
			var new_number = floating_number.instance()
			new_number.global_position = $FloatingNumberPos.global_position
			new_number.set_value(damage)
			if damage < 0:
				new_number.set_color(Color(0, 1, 0))
			
			# scale new number for big values
			var scalie = float(damage - 1) / 10.0
			if scalie > 0:
				new_number.scale = Vector2(1 + scalie, 1 + scalie)
			
			get_parent().call_deferred("add_child", new_number)
	
	if current_hp <= 0:
		#print("dead")
		StateData.set_current_state(StateData.States.GameOver)
		# emit signal to arena to show game over popup
		if connect("game_over", get_parent(), "game_over") == OK:
			emit_signal("game_over")
			disconnect("game_over", get_parent(), "game_over")
	
	# set status sprite
	var ratio = float(current_hp) / float(MAX_HP)
	if ratio > 0.75:
		status_sprite.play("stat100")
	elif ratio > 0.5:
		status_sprite.play("stat75")
	elif ratio > 0.25:
		status_sprite.play("stat50")
	else:
		status_sprite.play("stat25")

func flicker():
	for i in range(5):
		$AnimatedSprite.self_modulate.a = 0
		$FlickerTimer.start()
		yield($FlickerTimer, "timeout")
		$AnimatedSprite.self_modulate.a = 1
		if i < 5:
			$FlickerTimer.start()
			yield($FlickerTimer, "timeout")

func set_current_armor(value: int):
	#print("setting armor to " + str(value))
	current_armor = value
	current_armor = stepify(current_armor, 1.0)
	current_armor = max(0, current_armor)
	label_armor.text = str(current_armor)
	
	armor_box.visible = current_armor > 0

func use_components():
	# iterate over all slots
	for c in get_children():
		if c.is_in_group("ComponentSlot"):
			# if that slot has a card, get that card's data
			# don't look it up in GameData.fruit_data because cards can be upgraded and we need to use the correct stats
			if c.has_card():
				c.slot_sprite.play("use")
				var card_name = c.component_card.fruit_name
				var card_attack = c.component_card.fruit_attack
				var card_heal = c.component_card.fruit_heal
				var card_armor = c.component_card.fruit_armor
				
#				print(str(
#					"name ", card_name, " \n",
#					"card_attack ", card_attack, " \n",
#					"card_heal ", card_heal, " \n",
#					"card_armor ", card_armor, " \n"
#				))
				
				# things happen
				if card_attack > 0:
					if connect("attack_enemy", get_parent(), "attack_enemy") == OK:
						emit_signal("attack_enemy", card_attack)
						disconnect("attack_enemy", get_parent(), "attack_enemy")
					
					
						#show floating stat
						var new_stat = floating_stat.instance()
						new_stat.call_deferred("set_value", card_attack)
						new_stat.call_deferred("set_type", "attack")
						new_stat.global_position = c.global_position
						get_parent().add_child(new_stat)
						
						# play sound
						sfx_player.stream = load(AudioData.SFX_PLAYER_ATTACK_ACTION_PATH)
						sfx_player.volume_db = AudioData.db_level + 10
						sfx_player.play(0.0)
						yield(sfx_player, "finished")
					
				
				component_set_timer.start()
				yield(component_set_timer, "timeout")
				
				if card_heal > 0:
					set_current_hp(current_hp + card_heal, true, true)
					
					
					#show floating stat
					var new_stat = floating_stat.instance()
					new_stat.call_deferred("set_value", card_heal)
					new_stat.call_deferred("set_type", "heal")
					new_stat.global_position = c.global_position
					get_parent().add_child(new_stat)
					
					# play sound
					sfx_player.stream = load(AudioData.SFX_PLAYER_HEAL_ACTION_PATH)
					sfx_player.volume_db = AudioData.db_level + 10
					sfx_player.play(0.0)
					yield(sfx_player, "finished")
				
				component_set_timer.start()
				yield(component_set_timer, "timeout")
				
				#print(str("card_armor ", card_armor))
				if card_armor > 0:
					set_current_armor(current_armor + card_armor)
						
					#show floating stat
					var new_stat = floating_stat.instance()
					new_stat.call_deferred("set_value", card_armor)
					new_stat.call_deferred("set_type", "armor")
					new_stat.global_position = c.global_position
					get_parent().add_child(new_stat)
					
					# play sound
					sfx_player.stream = load(AudioData.SFX_PLAYER_ARMOR_ACTION_PATH)
					sfx_player.volume_db = AudioData.db_level + 10
					sfx_player.play(0.0)
					yield(sfx_player, "finished")
				
#				# wait a bit
#				use_component_timer.start()
#				print("waiting")
#				yield(use_component_timer, "timeout")
					
				
				# animate the slot
				c.slot_sprite.play("full")
			
			
			# wait a bit
			use_component_timer.start()
			yield(use_component_timer, "timeout")
	
	if connect("cleanup_player_turn", get_parent(), "cleanup_player_turn") == OK:
		emit_signal("cleanup_player_turn")
		disconnect("cleanup_player_turn", get_parent(), "cleanup_player_turn")


func rot_components(rot_range: int, rot_strength: int):
	# range -1 == exactly all components
	# positive ranges == that many components, with direct damage if not enough components are present
	# strength -n: for each affected component, deduct n rot, no trample damage
	# strength n: same shit, but if not enough rot is present, excess rot gets dealt as damage
	var slots_with_components = []
	for c in get_children():
		if c.is_in_group("ComponentSlot"):
			if c.has_card():
				slots_with_components.append(c)
	#print(str("calling rot_component with range ", rot_range, " and strength ", rot_strength))
	#print(str("rot_components found ", slots_with_components.size(), " slots w comps"))
	
	if rot_range == -1:
		for slot in slots_with_components:
			slot.rot_component(abs(rot_strength))
	else:
		#print("range - excess damage")
		# excess damage
		var diff = slots_with_components.size() - rot_range
		diff = min(diff, 0) # max to 0 so we can just emit that damage signal with simple multiplication
		var direct_damage = diff * rot_strength
		set_current_hp(current_hp + direct_damage, true, true)
		#print(str("dealing ", direct_damage, " damage"))
	
	if rot_strength < 0: # no excess damage
		#print("strength - no excess damage")
		pass
	else: # excess damage
		#print("strength - excess damage")
		for slot in slots_with_components:
			var current_rot = slot.component_card.current_rot
			if rot_strength > current_rot:
				var dmg = current_rot - rot_strength
				set_current_hp(current_hp + dmg, true, true)
			
			slot.rot_component(rot_strength)
