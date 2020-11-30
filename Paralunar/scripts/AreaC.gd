extends Node2D

func _ready():
	var audioman = get_node("/root/AudioManager")
	if audioman != null:
		audioman.play_with_fade("OtherArea", 0.5)
	pass # Replace with function body.