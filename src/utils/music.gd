extends Node

var streamer: AudioStreamPlayer

func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS
	streamer = AudioStreamPlayer.new()
	var stream: Resource = load("res://assets/music/famplan.ogg")
	streamer.set_stream(stream)
	streamer.volume_db = -10.0
	streamer.pitch_scale = 1
	streamer.play()
	add_child(streamer)


func set_volume(volume: float) -> void:
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(streamer, "volume_db",
					streamer.volume_db, volume, 0.5,
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
