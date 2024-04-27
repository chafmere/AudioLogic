extends Resource
class_name AudioLog

@export var log_name: String
@export var log_audio: AudioStream

@export_category("Optional Parameters")
@export var log_portrait: CompressedTexture2D
@export var speaker_name: String
@export_multiline var log_text: String

@export_category("Default Overrides")
@export var insert_audio: AudioStream
@export var end_audio: AudioStream
@export var background_audio: AudioStream
@export var bus_effect_profile: BusEffectProfile


