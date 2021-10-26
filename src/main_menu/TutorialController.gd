extends Control


onready var how_to_tab = $TabContainer/HowToTab
onready var fruit_tab = $TabContainer/FruitTab
onready var fruit_container = $FruitContainer
onready var how_to_container = $HowToContainer

var current_tab: int = 0

enum TutorialTabs {HowTo, Fruit}

func _ready() -> void:
	set_current_tab(TutorialTabs.HowTo)


func set_current_tab(value: int):
	current_tab = value
	var is_fruit = current_tab == TutorialTabs.Fruit
	var is_how_to = current_tab == TutorialTabs.HowTo
	
	fruit_container.visible = is_fruit
	how_to_container.visible = is_how_to
	
	# set tab textures
	if is_fruit:
		how_to_tab.texture_normal = load("res://assets/sprites/ui/cardboard_button_small.png")
		fruit_tab.texture_normal = load("res://assets/sprites/ui/cardboard_button_small_hover.png")
	if is_how_to:
		how_to_tab.texture_normal = load("res://assets/sprites/ui/cardboard_button_small_hover.png")
		fruit_tab.texture_normal = load("res://assets/sprites/ui/cardboard_button_small.png")
		
		
func _on_CloseButton_pressed() -> void:
	visible = false


func _on_HowToTab_pressed() -> void:
	set_current_tab(TutorialTabs.HowTo)


func _on_FruitTab_pressed() -> void:
	set_current_tab(TutorialTabs.Fruit)
