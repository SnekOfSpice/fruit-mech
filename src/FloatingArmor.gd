extends Sprite


const DISTANCE_Y = 30
const OFFSET_X_RANGE = 20
const ANIM_DURATION = 2.5

var value = 0
onready var tween = $Tween

func _ready() -> void:
	start_floating()

func start_floating():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var target_x = rng.randi_range(position.x - OFFSET_X_RANGE, position.x + OFFSET_X_RANGE)
	var target_y = position.y - DISTANCE_Y
	var target_pos = Vector2(target_x, target_y)
	$Tween.interpolate_property(self, "position", position, target_pos, ANIM_DURATION)
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), ANIM_DURATION, Tween.TRANS_EXPO)
	
	$Tween.call_deferred("start")


func _on_Tween_tween_all_completed() -> void:
	queue_free()
