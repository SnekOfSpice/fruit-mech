extends Node

const DEFAULT_VOLUME_DB = -10

var db_level = DEFAULT_VOLUME_DB

const MAIN_MENU_MUSIC_PATH = "res://assets/sounds/music/bensound-psychedelic.mp3"


const MUSIC_COMBAT_PATHS = [
	"res://assets/sounds/music/bensound-allthat.mp3",
	"res://assets/sounds/music/bensound-brazilsamba.mp3",
	"res://assets/sounds/music/bensound-dance.mp3",
	"res://assets/sounds/music/bensound-scifi.mp3"
]

const SFX_ENEMY_ACTION_PATHS = {
	0 : "res://assets/sounds/sfx/enemy_actions/265327__xkpl-klawz__big-room-kick-subby.wav", # slam
	1 : "res://assets/sounds/sfx/enemy_actions/30245__streety__sword2.wav", # time scalpel
	2 : "res://assets/sounds/sfx/enemy_actions/555060__magnuswaker__charge-up.wav", # leech
	3 : "res://assets/sounds/sfx/enemy_actions/320433__n-audioman__notification2(1).wav", # decay
	4 : "res://assets/sounds/sfx/enemy_actions/273864__beskhu__metallic-bottle-prc-3.wav", # defend
	5 : "res://assets/sounds/sfx/enemy_actions/205753__scorpion67890__surge-leech-1.wav", # mind rake
	6 : "res://assets/sounds/sfx/enemy_actions/433839__archos__slime-28.wav" # ooze
}

#const SFX_PLAYER_HEAL_ACTION_PATH = "res://assets/sounds/sfx/player_actions/444491__breviceps__short-choir.wav"
const SFX_PLAYER_HEAL_ACTION_PATH = "res://assets/sounds/sfx/player_actions/240745__majoranman__choir-one-shot.wav"
const SFX_PLAYER_ATTACK_ACTION_PATH = "res://assets/sounds/sfx/player_actions/151812__karma-ron__orch-002-boom.wav"
const SFX_PLAYER_ARMOR_ACTION_PATH = "res://assets/sounds/sfx/player_actions/367666__rutgermuller__sfx-thrilling-build-up-3-made-at-paradise-air.wav"

const SFX_UI_CARD_HOVER_PATH = "res://assets/sounds/sfx/ui/508597__drooler__crumple-06.ogg"
const SFX_UI_BUTTON_HOVER_PATH = "res://assets/sounds/sfx/ui/568594__thesoundbandit__bloodspit.wav"
const SFX_UI_BUTTON_PRESS_PATH = "res://assets/sounds/sfx/ui/542195__breviceps__cartoon-wobble.wav"
const SFX_UI_ENTROPY_POPUP_PATH = "res://assets/sounds/sfx/ui/556613__daniel-ms__synthetic-monster-growl.wav"
# so the fix to shit looping for no appearent reason is to mangle it through an online converter
# interesting
const SFX_UI_DEFEAT_PATH = "res://assets/sounds/sfx/ui/168606__setuniman__springy-o36b(1).wav"
const SFX_UI_PLAYER_END_TURN_PATH = "res://assets/sounds/sfx/ui/403001__kaosmakinesi__clock-tick-tik-tak.wav"

var last_combat_track_index = 0


func get_next_combat_track():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rand_index = rng.randi_range(0, MUSIC_COMBAT_PATHS.size() - 1)
	while rand_index == last_combat_track_index:
		rand_index = rng.randi_range(0, MUSIC_COMBAT_PATHS.size() - 1)
	
	var result = MUSIC_COMBAT_PATHS[rand_index]
	
	last_combat_track_index = rand_index
	return result
