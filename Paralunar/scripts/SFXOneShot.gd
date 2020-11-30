extends AudioStreamPlayer

var sound_name = ""
var random_pitch_offset = 0.05
var volume_scale = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var audioman = get_node("/root/AudioManager")
	if audioman != null:
		if audioman.sfxbox.has(sound_name):
			stream = audioman.sfxbox[sound_name]
			volume_db = audioman.get_sfx_db(volume_scale)
			pitch_scale = rand_range(1.0 - random_pitch_offset, 1.0 + random_pitch_offset)
			play()
			return
	# if there's no AudioManager or the AudioManager hasn't got the sound, perform seppuku
	queue_free()	
	

func _on_SFXOneShot_finished():
	queue_free()
