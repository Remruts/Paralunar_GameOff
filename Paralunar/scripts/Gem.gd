extends Area2D

onready var spr = $Sprite

export(String, "red", "yellow", "blue", "") var gem_type = ""
var dead = false

func _ready():
	var gm = get_node("/root/GameManager")
	if gm == null:
		return
	
	if gem_type == "blue":
		spr.frame = 0
	elif gem_type == "red":
		spr.frame = 1
	elif gem_type == "yellow":
		spr.frame = 2

	if (spr.frame == 0 and (gm.has_blue_gem or gm.blue_gem_placed)) \
	or (spr.frame == 1 and (gm.has_red_gem or gm.red_gem_placed)) \
	or (spr.frame == 2 and (gm.has_yellow_gem or gm.yellow_gem_placed)):
		die()
	

func die():
	if dead:
		return
	dead = true
	queue_free()

func _on_Gem_body_entered(body):
	if dead:
		return
	if body.is_in_group("player"):
		var audioman = get_node("/root/AudioManager")
		if audioman != null:
			audioman.play_sfx("gem_grab", 0.0)
		
		var gm = get_node("/root/GameManager")
		if gm != null:
			if spr.frame == 0:
				gm.get_gem("blue")
			elif spr.frame == 1:
				gm.get_gem("red")
			else:
				gm.get_gem("yellow")
			die()