extends ParallaxBackground

const CLOUDS_SCROLL_SCALE = 5.0
const MAX_CLOUD_SPEED = 3


var x_motion = 0

onready var cloud_layer = $CloudLayer

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	x_motion = rng.randi_range(-MAX_CLOUD_SPEED, MAX_CLOUD_SPEED)

func _process(delta: float) -> void:
		cloud_layer.motion_offset.x += x_motion * delta * CLOUDS_SCROLL_SCALE
