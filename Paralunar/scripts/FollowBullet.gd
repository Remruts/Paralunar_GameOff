extends "EnemyBullet.gd"

var life = 4

func _ready():
	#._ready()
	
	friction = 0.95
	rotate_with_speed = false
	var players = get_tree().get_nodes_in_group("player")
	if len(players) > 0:		
		rotation = (players[0].global_position - global_position).angle() + PI/2.0

func _physics_process(delta):
	._physics_process(delta)

func _process(delta):
	._process(delta)

func move_towards_player():
	instance_effects(global_position)
	
	var audioman = get_node("/root/AudioManager")
	if audioman != null:
		audioman.play_sfx("follow_bullet_follow", 0.0)

	if life == 0:		
		die()
	var players = get_tree().get_nodes_in_group("player")
	if len(players) > 0:		
		speed = (players[0].global_position - global_position).normalized() * 200.0
		rotation = speed.angle() + PI/2.0
	
	life -= 1

func _on_FollowTimer_timeout():
	if dead:
		return
	move_towards_player()
	
	