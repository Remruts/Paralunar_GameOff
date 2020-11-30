extends "EnemyBullet.gd"

var life = 4
var auto_shoot = -1
var thrown = false

onready var follow_timer:Timer = $FollowTimer

func _ready():
    #._ready()
    #friction = 0.95
    rotate_with_speed = false
    var players = get_tree().get_nodes_in_group("player")
    if len(players) > 0:		
        rotation = (players[0].global_position - global_position).angle() + PI/2.0
    
    if auto_shoot >= 0.0:
        follow_timer.start(auto_shoot)

func _physics_process(delta):
    ._physics_process(delta)

func _process(delta):	
    ._process(delta)
    if !thrown:
        var players = get_tree().get_nodes_in_group("player")
        if len(players) > 0:		
            rotation = (players[0].global_position - global_position).angle() + PI/2.0

func move_towards_player():
    instance_effects(global_position)
    if life == 0:		
        die()
    var players = get_tree().get_nodes_in_group("player")
    if len(players) > 0:
        thrown = true
        speed = (players[0].global_position - global_position).normalized() * 100.0
        rotation = speed.angle() + PI/2.0
    
    var audioman = get_node("/root/AudioManager")
    if audioman != null:
        audioman.play_sfx("throw_sword")
    life -= 1

func _on_FollowTimer_timeout():
    if dead:
        return
    move_towards_player()