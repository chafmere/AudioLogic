extends Node

var audio_log_effect_stake: BusEffectProfile : set = set_audio_log_effect
var audio_log_menu_theme: Theme : set = set_audio_log_menu_theme

func _ready() -> void:
	##TODO replace with a the last bus effect
	var bus_effect_profile = load("res://addons/audiologic/BusEffectProfiles/bus_effects/high_pass_crunch.tres")
	set_audio_log_effect(bus_effect_profile)

func set_audio_log_effect(_bus_effect: BusEffectProfile) -> void:
	print(_bus_effect)
	audio_log_effect_stake = _bus_effect
	var bus = AudioServer.get_bus_index("AudioLog")
	# remove effects
	for e in AudioServer.get_bus_effect_count(bus):
		AudioServer.remove_bus_effect(bus, e)
	for b in _bus_effect.bus_effects:
		AudioServer.add_bus_effect(bus,b)

func set_audio_log_menu_theme(_theme: Theme) -> void:
	audio_log_menu_theme = _theme
