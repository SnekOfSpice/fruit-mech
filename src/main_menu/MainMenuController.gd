extends Control

onready var volume_slider = $Camera2D/CanvasLayer/MainMenuControls/VolumeSlider
onready var camera = $Camera2D
onready var cloud_layer = $ParallaxBackground/CloudsLayer
onready var tutorial = $TutorialController
onready var credits = $CreditsController

const CAMERA_WIGGLE = 0.4

func _ready() -> void:
	$MusicPlayer.stream = load(AudioData.MAIN_MENU_MUSIC_PATH)
	$MusicPlayer.volume_db = AudioData.db_level
	$MusicPlayer.play(0.0)
	
	# to keep consistency when going here from the arena
	volume_slider.value = AudioData.db_level
	
	tutorial.visible = false
	credits.visible = false


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
	var cam_pos = cam_origin + Vector2( cen_x -delta_x, cen_y - delta_y)
	
	# clamp so the camera doesn't go too far
	cam_pos.x = clamp(cam_pos.x, 750, 1200)
	cam_pos.y = clamp(cam_pos.y, 500, 950)
	
	camera.position = cam_pos
	
	
	cloud_layer.motion_offset.x += 20 * delta


func _on_VolumeSlider_value_changed(value: float) -> void:
	AudioData.db_level = value
	$MusicPlayer.volume_db = value
	$SFXPlayer.volume_db = value


func _on_StartButton_pressed() -> void:
	get_tree().change_scene("res://src/ArenaController.tscn")

func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_FullscreenButton_pressed() -> void:
	OS.window_fullscreen = !OS.window_fullscreen


func _on_TutorialButton_pressed() -> void:
	tutorial.visible = !tutorial.visible
	credits.visible = false


func _on_CreditsButton_pressed() -> void:
	credits.visible = !credits.visible
	tutorial.visible = false
