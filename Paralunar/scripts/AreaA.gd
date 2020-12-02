extends Node2D

func _ready():
	var audioman = get_node("/root/AudioManager")
	if audioman != null:
		audioman.play_with_fade("OtherArea", 0)
	
	var gm = get_node("/root/GameManager")
	if gm != null:
		gm.playing = true
	pass # Replace with function body.

