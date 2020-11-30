extends "EnemyBullet.gd"

var moving = false
var rot_i = 0

func _ready():
	#._ready()
	friction = 0.98
	rotate_with_speed = false	

func _physics_process(delta):
	._physics_process(delta)

func _process(delta):
	._process(delta)
	if dead:
		return
	
	rotation += delta * min(speed.length(), 30)
	rot_i += delta * min(speed.length(), 30)
	if rot_i > 2 * PI:
		rot_i -= 2 * PI
		var audioman = get_node("/root/AudioManager")
		if audioman != null:			
			audioman.play_sfx("homing_bullet_move", 0.0, 0.3)

	#instance_effects(global_position)
	if moving:
		var players = get_tree().get_nodes_in_group("player")
		if len(players) > 0:		
			speed += (players[0].global_position - global_position).normalized() * delta * 150.0



func _on_FollowTimer_timeout():
	moving = true
