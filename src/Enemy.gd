extends Node2D
class_name Enemy

const ARMOR_DAMAGE_REDUCTION = 0.5
const INTENT_FADE_DURATION = 0.8

var enemy_id: int = 0
var enemy_name: String = ""
var enemy_actions:Array = []
var enemy_hp: int = 10
var enemy_armor: int = 10

var rng = RandomNumberGenerator.new()
var next_action: int = 0
var current_hp = 30
var current_armor = 0

onready var enemy_sprite = $Sprite
onready var tween = $Tween
onready var action_name_label = $ActionName
onready var hp_label = $StatsBox/StatsBox/HealthBox/Label
onready var armor_label = $StatsBox/StatsBox/ArmorBox/Label
onready var armor_box = $StatsBox/StatsBox/ArmorBox
onready var name_label = $StatsBox/Label

var floating_number = preload("res://src/player/FloatingNumber.tscn")
var intent_single = preload("res://src/arena/IntentSingle.tscn")
var floating_armor = preload("res://src/player/FloatingArmor.tscn")

signal enemy_has_attacked
signal attack
signal discard_n_cards
signal rot_components


func _ready() -> void:
	set_enemy_id(0)
	#use_action()
	set_next_action()

func set_enemy_id(value: int):
	enemy_id = value
	var enemy_data = GameData.enemy_data.get(str(enemy_id))
	#print(enemy_data)
	enemy_name = enemy_data.get("enemy_name")
	name_label.text = str(enemy_name)
	
	enemy_hp = int(enemy_data.get("enemy_hp"))
	enemy_armor = int(enemy_data.get("enemy_armor"))
	
	var actions = enemy_data.get("enemy_attacks")
	actions = actions.split(",")
	actions = Array(actions)
	enemy_actions = actions
	
	set_current_hp(enemy_hp, false)
	#set_current_hp(1, false)
	set_current_armor(enemy_armor)
	
	# set visuals
	var anim = SpriteFrames.new()
	anim.add_animation("idle")
	for i in range(3):
		anim.add_frame("idle", load(str("res://assets/sprites/enemy/enemy", enemy_id,"_frame", i,".png")))
	anim.set_animation_speed("idle", 2)
	anim.set_animation_loop("idle", true)
	enemy_sprite.frames = anim
	enemy_sprite.animation = "idle"
	enemy_sprite.playing = true

func set_current_hp(value: int, show_floating_number: bool):
	var damage = current_hp - value
	#var damage = value
	if current_armor > 0 && damage > 0: # check for damage > 0 since this function can also be used to heal
		set_current_armor(current_armor - damage)
		damage *= 1.0 - ARMOR_DAMAGE_REDUCTION
		# floating armor
		var new_armor = floating_armor.instance()
		new_armor.global_position = $FloatingNumberPos.global_position
		get_parent().call_deferred("add_child", new_armor)
	
	if damage > 0 && show_floating_number: 
		flicker()
	
	damage = stepify(damage, 1.0)
	
	if show_floating_number:
		if get_parent().is_in_group("ArenaController"):
			var new_number = floating_number.instance()
			new_number.global_position = $FloatingNumberPos.global_position
			new_number.set_value(damage)
			if damage < 0:
				new_number.set_color(Color(0, 1, 0))
			
			get_parent().add_child(new_number)
	
	
	current_hp -= damage
	current_hp = clamp(current_hp, 0, enemy_hp)
	hp_label.text = str(current_hp)
	

func flicker():
	for i in range(5):
		$Sprite.self_modulate.a = 0
		$FlickerTimer.start()
		yield($FlickerTimer, "timeout")
		$Sprite.self_modulate.a = 1
		if i < 5:
			$FlickerTimer.start()
			yield($FlickerTimer, "timeout")

func set_current_armor(value: int):
	current_armor = value
	current_armor = stepify(current_armor, 1.0)
	current_armor = max(0, current_armor)
	armor_label.text = str(current_armor)
	
	armor_box.visible = current_armor > 0

func use_action():
	# get data of action
	var action_data = GameData.enemy_action_data.get(str(next_action))
	var action_name = String(action_data.get("action_name"))
	var action_armor = int(action_data.get("action_armor"))
	var action_card_hand_destroy = int(action_data.get("action_card_hand_destroy"))
	var action_damage = int(action_data.get("action_damage"))
	var action_heal = int(action_data.get("action_heal"))
	var action_rot_range = int(action_data.get("action_rot_range"))
	var action_rot_strength = int(action_data.get("action_rot_strength"))
	
	# show action name
	$ActionName.text = action_name
	tween.interpolate_property(action_name_label, "modulate", action_name_label.modulate, Color(1,1,1,1), 0.5)
	tween.start()
	yield(tween, "tween_all_completed")
	
	#print(str("enemy using action ", next_action))
	# hide the intent
	var invis = $IntentContainer.modulate
	invis.a = 0.0
	tween.interpolate_property($IntentContainer, "modulate", $IntentContainer.modulate, invis, INTENT_FADE_DURATION)
	tween.start()
	yield(tween, "tween_all_completed")
	
	# wiggle enemy forwards
	var enemy_x = enemy_sprite.position.x
	var enemy_y = enemy_sprite.position.y
	tween.interpolate_property(enemy_sprite, "position", Vector2(enemy_x, enemy_y), Vector2(enemy_x - 100, enemy_y), 1.5, Tween.TRANS_EXPO)
	tween.start()
	yield(tween, "tween_all_completed")
	
	# use the action
	$SFXPlayer.stream = load(AudioData.SFX_ENEMY_ACTION_PATHS.get(next_action))
	$SFXPlayer.volume_db = AudioData.db_level + 10
	$SFXPlayer.play(0.0)
	
	if action_armor > 0:
		
		# play sound and yield
		gain_armor(action_armor)
		$ActionStepTimer.start()
		yield($ActionStepTimer, "timeout")
	
	if action_card_hand_destroy > 0:
		
		# play sound and yield
		discard_n_cards(action_card_hand_destroy)
		$ActionStepTimer.start()
		yield($ActionStepTimer, "timeout")
	
	if action_damage > 0:
		
		# play sound and yield
		attack(action_damage)
		$ActionStepTimer.start()
		yield($ActionStepTimer, "timeout")
	
	if action_heal > 0:
		
		# play sound and yield
		heal(action_heal)
		$ActionStepTimer.start()
		yield($ActionStepTimer, "timeout")
	
	if action_rot_range != 0:
		
		# play sound and yield
		rot_components(action_rot_range, action_rot_strength)
	
	# return enemy to original position
	tween.interpolate_property(enemy_sprite, "position", enemy_sprite.position, Vector2(enemy_x, enemy_y), 1.5, Tween.TRANS_CUBIC)
	tween.start()
	yield(tween, "tween_all_completed")
	
	# hide action name
	$ActionName.text = action_name
	tween.interpolate_property(action_name_label, "modulate", action_name_label.modulate, Color(1,1,1,0), 0.5)
	tween.start()
	yield(tween, "tween_all_completed")
	
	# set next action
	set_next_action()
	
	
	# show intent
	invis = $IntentContainer.modulate
	invis.a = 1.0
	tween.interpolate_property($IntentContainer, "modulate", $IntentContainer.modulate, invis, INTENT_FADE_DURATION)
	tween.start()
	yield(tween, "tween_all_completed")
	
	# emit signal to arena that enemy has attacked
	if connect("enemy_has_attacked", get_parent(), "start_player_turn") == OK:
		emit_signal("enemy_has_attacked")
		disconnect("enemy_has_attacked", get_parent(), "start_player_turn")

func heal(heal_amount):
	set_current_hp(current_hp + heal_amount, true)

func gain_armor(armor_gain):
	set_current_armor(current_armor + armor_gain)

func attack(damage: int): # deal damage
	if connect("attack", get_parent(), "deal_damage_to_player") == OK:
		emit_signal("attack", damage)
		disconnect("attack", get_parent(), "deal_damage_to_player")

func rot_components(rot_range: int, rot_strength: int):
	#rot_player_components(rot_range: int, rot_strength: int)
	if connect("rot_components", get_parent(), "rot_player_components") == OK:
		emit_signal("rot_components", rot_range, rot_strength)
		disconnect("rot_components", get_parent(), "rot_player_components")

func discard_n_cards(number_of_cards: int):
	if connect("discard_n_cards", get_parent(), "discard_n_cards") == OK:
		emit_signal("discard_n_cards", number_of_cards)
		disconnect("discard_n_cards", get_parent(), "discard_n_cards")

func set_next_action():
	var action_count = enemy_actions.size()
	if action_count > 0:
		rng.randomize()
		var action_index = 0
		var roll = rng.randf_range(0.0, 1.0)
		if roll <= 0.5: # first action: 50 %
			action_index = 0
		elif roll <= 0.85: # second action: 35 %
			action_index = 1
		else: # third action: 15 %
			action_index = 2
		var next = int(enemy_actions[action_index])
		next_action = next
		show_intent(next_action)
		
		#print(str("next action: ", next_action))

func show_intent(action_id):
	for i in $IntentContainer.get_children():
		i.queue_free()
	
	var action_data = GameData.enemy_action_data.get(str(action_id))
	var action_armor = int(action_data.get("action_armor"))
	var action_card_hand_destroy = int(action_data.get("action_card_hand_destroy"))
	var action_damage = int(action_data.get("action_damage"))
	var action_heal = int(action_data.get("action_heal"))
	var action_rot_range = int(action_data.get("action_rot_range"))
	
	# buff
	if action_armor > 0 || action_heal > 0:
		var intent = intent_single.instance()
		intent.set_intent(IntentSingle.Intents.Buff)
		$IntentContainer.add_child(intent)
	
	# attack
	if action_damage > 0:
		var intent = intent_single.instance()
		intent.set_intent(IntentSingle.Intents.Attack)
		$IntentContainer.add_child(intent)
	
	# debuff
	if action_rot_range > 0 || action_card_hand_destroy > 0:
		var intent = intent_single.instance()
		intent.set_intent(IntentSingle.Intents.Debuff)
		$IntentContainer.add_child(intent)



func _on_Heal_pressed() -> void:
	heal(3)


func _on_Rot_pressed() -> void:
	rot_components(2, 3)

func _on_Armor_pressed() -> void:
	gain_armor(5)


func _on_Discard_pressed() -> void:
	discard_n_cards(1)


func _on_Damage_pressed() -> void:
	attack(5)
