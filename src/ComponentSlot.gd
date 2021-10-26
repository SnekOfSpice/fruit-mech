extends Node2D
class_name ComponentSlot

var component_card: ComponentCard = null


onready var rot_label = $Label
onready var slot_sprite = $SlotSprite
onready var sprite_upgrade = $SpriteUpgrade
onready var stats_box = $StatsBox

var slot_stat_single = preload("res://src/SlotStatSingle.tscn")

func set_component_card(value: ComponentCard):
	component_card = value
	#print(str("received card ", component_card.fruit_name))
	
	
	if component_card != null:
		component_card.visible = false
		$FruitSprite.visible = true
		$FruitSprite.play_fruit_anim(component_card.fruit_id)
		rot_label.text = str("current rot: ", component_card.current_rot)
		stats_box.visible = true
		update_stats()
		#print("yes fruit sprite")
		slot_sprite.play("full")
		
	else:
		#print("no fruit sprite")
		$FruitSprite.visible = false
		stats_box.visible = false
		rot_label.text = ""
		sprite_upgrade.visible = false
		
		slot_sprite.play("empty")
	
	#slot_sprite.visible = component_card == null


func has_card() -> bool:
	return component_card != null && is_instance_valid(component_card)

func rot_component(rot_strength):
	if has_card():
		component_card.set_current_rot(component_card.current_rot - rot_strength)
		rot_label.text = str("current rot: ", component_card.current_rot)

func update_stats():
	if has_card():
		var fruit_rot = component_card.current_rot
		var fruit_attack = component_card.fruit_attack
		var fruit_armor = component_card.fruit_armor
		var fruit_heal = component_card.fruit_heal
		var is_upgrade = component_card.is_upgraded
		
		for c in stats_box.get_children():
			c.queue_free()
		
	
		# rot
		if fruit_rot > -1:
			var new_stat = slot_stat_single.instance()
			stats_box.add_child(new_stat)
			new_stat.set_value(fruit_rot)
			new_stat.set_type("rot")
	
		# attack
		if fruit_attack > 0:
			var new_stat = slot_stat_single.instance()
			stats_box.add_child(new_stat)
			new_stat.set_value(fruit_attack)
			new_stat.set_type("attack")
		
		
		
		# heal
		if fruit_heal > 0:
			var new_stat = slot_stat_single.instance()
			stats_box.add_child(new_stat)
			new_stat.set_value(fruit_heal)
			new_stat.set_type("heal")
			
		sprite_upgrade.visible = is_upgrade
		
		# armor
		if fruit_armor > 0:
			var new_stat = slot_stat_single.instance()
			stats_box.add_child(new_stat)
			new_stat.set_value(fruit_armor)
			new_stat.set_type("armor")
		
		#stats_box.margin_top = -60

#func use_component():
#	if has_card():
#		component_card.use_component()
