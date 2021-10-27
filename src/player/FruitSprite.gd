extends AnimatedSprite

func play_fruit_anim(fruit_id):
	var anim = SpriteFrames.new()
	anim.add_animation("idle")
	for i in range(2):
		anim.add_frame("idle", load(str("res://assets/sprites/fruit/fruit", fruit_id, "_frame", i, ".png")))
	anim.set_animation_speed("idle", 1)
	anim.set_animation_loop("idle", true)
	frames = anim
	animation = "idle"
	playing = true
