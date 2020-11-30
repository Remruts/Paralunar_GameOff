extends Area2D

onready var anim = $AnimationPlayer
onready var save_text_anim = $SaveTextAnimator

func _ready():
	pass

func save():
	if anim.current_animation != "activated_floating":
		anim.play("activated_floating", anim.current_animation_position)
		var audioman = get_node("/root/AudioManager")
		if audioman != null:
			audioman.play_sfx("save", 0.0)
	
	print("saving...")
	var gm = get_node("/root/GameManager")
	if gm != null:
		gm.recover_lives(gm.max_lives)
		if !gm.transitioning:
			gm.player_starting_pos = global_position
			gm.save_game(gm.current_file)
	
	save_text_anim.play("appear")

func _on_Savepoint_body_entered(body):
	if body.is_in_group("player_bullet"):
		var normal = body.speed.normalized()
		body.get_hit(body.position - normal * 7.0)		
		save()