extends VBoxContainer
class_name IntentSingle

enum Intents{Buff, Attack, Debuff}

var intent: int = 0


func set_intent(value: int):
	intent = value
	match intent:
		Intents.Buff:
			$TextureRect.texture = load("res://assets/sprites/enemy/intent_buff2.png")
			$Label.text = "Buff"
		Intents.Attack:
			$TextureRect.texture = load("res://assets/sprites/enemy/intent_attack2.png")
			$Label.text = "Attack"
		Intents.Debuff:
			$TextureRect.texture = load("res://assets/sprites/enemy/intent_debuff2.png")
			$Label.text = "Debuff"
