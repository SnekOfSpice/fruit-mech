extends Control
class_name ComponentCard


var fruit_id: int = 0

# vars set by fruit_id
# base stats
var fruit_name = "Apple"
var fruit_starting_rot = 4
var fruit_attack = 1
var fruit_heal = 1
var fruit_armor = 0
# upgrade stats
var fruit_upgrade_chance = 0.1
var fruit_starting_rot_upgrade = 2
var fruit_attack_upgrade = 2
var fruit_heal_upgrade = 0
var fruit_armor_upgrade = 0

# dynamic stats
var current_rot = 0
var is_upgraded = false



# card movement
var mouse_offset = Vector2.ZERO
var is_picked = false
var on_component = false
var card_origin = Vector2.ZERO

onready var mouse_area = $Area2D/CollisionShape2D

var component_hovering_over = null
var hovered_over_slots = []

# fancy display
var card_stat_single = preload("res://src/player/CardStatSingle.tscn")
var floating_stat = preload("res://src/player/FloatingStat.tscn")
onready var fruit_stat_container = $FruitStats/FruitStats2
onready var fruit_name_label = $FruitStats/TopRow/LabelName
onready var fruit_tex = $FruitStats/FruitTexture
onready var fruit_stats_label = $FruitStats/Stats
onready var rot_label = $FruitStats/TopRow/Label

signal remove_card_from_hand

func _ready() -> void:
	set_fruit_id(1)
	upgrade_to_level(5)

func _process(delta: float) -> void:
	if is_picked:
		rect_global_position = get_global_mouse_position() - mouse_offset

func _input(event: InputEvent) -> void:
	#if rect_global_position != card_origin && !on_component:
	if !on_component:
		
		if event.is_action_pressed("mouse_right"):
			set_is_picked(false)
			#print("mouse r")
			# return to origin
			$Tween.interpolate_property(self, "rect_global_position", rect_global_position, card_origin, 0.2)
			$Tween.start()

func set_fruit_id(value: int):
	fruit_id = value
	var fruit_data = GameData.fruit_data.get(str(fruit_id))
	
	# base stats
	fruit_name = fruit_data.get("fruit_name")
	fruit_starting_rot = fruit_data.get("fruit_starting_rot")
	current_rot = fruit_starting_rot
	fruit_attack = fruit_data.get("fruit_attack")
	fruit_heal = fruit_data.get("fruit_heal")
	fruit_armor = fruit_data.get("fruit_armor")
	
	# upgrade stats
	fruit_upgrade_chance = float(fruit_data.get("fruit_upgrade_chance"))
	fruit_starting_rot_upgrade = float(fruit_data.get("fruit_starting_rot_upgrade"))
	fruit_attack_upgrade = fruit_data.get("fruit_attack_upgrade")
	fruit_heal_upgrade = fruit_data.get("fruit_heal_upgrade")
	fruit_armor_upgrade = fruit_data.get("fruit_armor_upgrade")
	
	# gamejam legacy
	# call_deferred("attempt_upgrade")
	#update_stats_label()
	
	
	fruit_tex.texture = load(str("res://assets/sprites/fruit/fruit", fruit_id, "_frame0.png"))
	

func set_current_rot(value: int):
	var diff = current_rot - value
	current_rot = value
	
	if is_instance_valid(component_hovering_over):
		#print(str("floating rot ", current_rot))
		# add floating text to parent since this is invis on a component
		var new_stat = floating_stat.instance()
		new_stat.call_deferred("set_value", diff)
		new_stat.call_deferred("set_type", "rot")
		new_stat.global_position = rect_global_position
		get_parent().add_child(new_stat)
		
		
		if current_rot <= 0:
			$DeleteTimer.start()
		
		

#func attempt_upgrade():
#	var rng = RandomNumberGenerator.new()
#	rng.randomize()
#	var roll = rng.randf_range(0.0, 1.0)
#	if roll < fruit_upgrade_chance:
#		#print("upgrade")
#		_upgrade_stats()
#	#print(roll)
	

#func set_is_upgraded(value: bool):
#	is_upgraded = value

func upgrade_to_level(level: int):
	# idk do we need this? just in case for now bc of legacy reasons lmao
	#set_is_upgraded(level > 0)
	
	# tracking variable to apply any n upgrades
	var upgrade_iteration = 0
	while upgrade_iteration < level:
		upgrade_iteration += 1
		# for some reason, the fruit sprite slides to the right if we update the visual label on every level
		# so the _upgrade_stats func gets a bool arg to update the label or not
		# and we only update the level on the last upgrade
		_upgrade_stats(upgrade_iteration == level)
		

func set_is_picked(value: bool):
	is_picked = value
	# if we're on top of a component slot, slot into that component slot
	# that component slot has to be free, aka not already have a card in it
	if hovered_over_slots.size() > 0:
		var target_slot = hovered_over_slots[hovered_over_slots.size() - 1]
		component_hovering_over = target_slot
		if on_component && !target_slot.has_card():
			target_slot.set_component_card(self)
			mouse_area.set_deferred("disabled", true)
			
			# tell the arena to remove this card from the hand view
			if connect("remove_card_from_hand", get_parent(), "remove_card_from_hand") == OK:
				emit_signal("remove_card_from_hand", self, false)
				disconnect("remove_card_from_hand", get_parent(), "remove_card_from_hand")
			
		# else, return to its origin
		else:
			$Tween.interpolate_property(self, "rect_global_position", rect_global_position, card_origin, 0.2)
			$Tween.start()
			#rect_global_position = card_origin
	else:
		$Tween.interpolate_property(self, "rect_global_position", rect_global_position, card_origin, 0.2)
		$Tween.start()

func set_on_component(value: bool):
	on_component = value


func set_card_origin(value: Vector2):
	card_origin = value
	rect_global_position = card_origin

func _upgrade_stats(update_stats_label: bool):
	current_rot += fruit_starting_rot_upgrade
	fruit_attack += fruit_attack_upgrade
	fruit_heal += fruit_heal_upgrade
	fruit_armor += fruit_armor_upgrade
#	print(str(
#		"upgrading ", fruit_name, " id ", fruit_id, "\n",
#		"upgr attack ", fruit_attack_upgrade, "\n",
#		"upgr heal ", fruit_heal_upgrade, "\n",
#		"upgr armor ", fruit_armor_upgrade, "\n"
#	))
	#set_is_upgraded(true)
	if update_stats_label:
		call_deferred("update_stats_label")

func update_stats_label():
	fruit_name_label.text = str(fruit_name)
	fruit_stats_label.text = str(
		"Rot: ", current_rot, "\n",
		"Attack: ", fruit_attack, "\n",
		"Heal: ", fruit_heal, "\n",
		"Armor: ", fruit_armor, "\n",
		"Upgraded: ", is_upgraded, "\n"
	)
	for c in fruit_stat_container.get_children():
		c.queue_free()
	
	# rot
	rot_label.text = str(current_rot)
	
	# attack
	if fruit_attack > 0:
		var new_stat = card_stat_single.instance()
		fruit_stat_container.add_child(new_stat)
		new_stat.set_value(fruit_attack)
		new_stat.set_type("attack")
	
	
	# armor
	if fruit_armor > 0:
		var new_stat = card_stat_single.instance()
		fruit_stat_container.add_child(new_stat)
		new_stat.set_value(fruit_armor)
		new_stat.set_type("armor")
	
	
	# heal
	if fruit_heal > 0:
		var new_stat = card_stat_single.instance()
		fruit_stat_container.add_child(new_stat)
		new_stat.set_value(fruit_heal)
		new_stat.set_type("heal")
	
	#$AnimatedSprite.visible = is_upgraded

func discard_card(): # from hand
	# signal arena that this card is getting discarded
	# the arena will call queue free
	# first it will hide this card, then rearrange all cards after this one one slot to the left
	if connect("remove_card_from_hand", get_parent(), "remove_card_from_hand") == OK:
		emit_signal("remove_card_from_hand", self, true)
		disconnect("remove_card_from_hand", get_parent(), "remove_card_from_hand")
	
	# then delete this
#
#func use_component():
#	pass


func delete_self():
	#print("deleting card ")
	if component_hovering_over != null: # if this is part of a component slot, tell that slot this information
		component_hovering_over.set_component_card(null)
	call_deferred("queue_free")

func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if StateData.current_state == StateData.States.PlayerTurnActive:
		if event is InputEventMouseButton:
			#print("Mouse Click/Unclick at: ", event.position)
			if event.is_action_pressed("mouse_left"):
				# just hard-code this shit, it looks good enough for me and actually reliably works
				mouse_offset = Vector2(50, 100)
				#mouse_offset = (event.position  - rect_global_position) / 57
#				var mouse_x = mouse_offset.x * (1.0 / 1.25)
#				var mouse_y = mouse_offset.y * (1.0 / 1.25)
#				# multiplied by the reciprocal of the camera zoom
#				mouse_offset = Vector2(mouse_x, mouse_y)
				set_is_picked(true)
			if event.is_action_released("mouse_left"):
				set_is_picked(false)



func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("ComponentSlot"):
		set_on_component(true)
		#component_hovering_over = area
		hovered_over_slots.append(area)
		


func _on_Area2D_area_exited(area: Area2D) -> void:
	if area.is_in_group("ComponentSlot"):
		#set_on_component(false)
		#component_hovering_over = null
		#print("exiting slot")
		hovered_over_slots.erase(area)
		if hovered_over_slots.size() > 0:
			set_on_component(true)
		else:
			set_on_component(false)


func _on_Area2D_mouse_entered() -> void:
	rect_scale = Vector2(1.1, 1.1)
	$SFXPlayer.stream = load(AudioData.SFX_UI_CARD_HOVER_PATH)
	$SFXPlayer.volume_db = AudioData.db_level
	$SFXPlayer.play(0.0)


func _on_Area2D_mouse_exited() -> void:
	rect_scale = Vector2(1.0, 1.0)


func _on_DeleteTimer_timeout() -> void:
	delete_self()
