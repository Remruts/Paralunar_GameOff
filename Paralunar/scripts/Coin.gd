extends RigidBody2D

onready var anim = $AnimatedSprite
onready var death_timer:Timer = $DeathTimer
var sparkle_prefab = preload("res://prefabs/Sparkle.tscn")
var chispitas_prefab = preload("res://prefabs/Chispitas.tscn")

var player = null
var picked_up = false
var spd = 120.0

export var permanent:bool = true
export var kinematic = false
var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if kinematic:
		mode = MODE_KINEMATIC
	else:
		anim.frame = randi() % anim.frames.get_frame_count("coin_spin")
		anim.get_node("Shadow").frame = anim.frame
	pass # Replace with function body.

func _process(_delta):
	if not (player == null):
		var dir = (player.position - position)
		var l = dir.length()
		dir = dir.normalized()
		apply_central_impulse((dir * spd / l))
	
	if !permanent:
		if death_timer.time_left <= 3:
			var modulate_flag = 1.0 if (sin((death_timer.time_left - fmod(death_timer.time_left, 1.0) * 8 * PI)) > 0.0) else 0.0
			anim.modulate = Color.white if modulate_flag else Color("696969")

func pickup():
	if !picked_up:
		picked_up = true
		# little explosion or something
		var sparkle_num = 3.0
		var start_angle = rand_range(0.0, 2 * PI)
		for i in range(sparkle_num):
			var sparkle = sparkle_prefab.instance()
			var sparkle_angle = start_angle + (i/float(sparkle_num)) * 2 * PI
			get_tree().current_scene.add_child(sparkle)
			sparkle.position = position + Vector2(cos(sparkle_angle), sin(sparkle_angle)) * rand_range(4.0, 6.0)
			sparkle.material.set_shader_param("new_color", Color("ffd96a"))
		
		var chispitas = chispitas_prefab.instance()
		get_tree().current_scene.add_child(chispitas)
		chispitas.position = position
		var gm = get_node("/root/GameManager")
		if gm != null:
			gm.add_coins(1)
		
		var audioman = get_node("/root/AudioManager")
		if audioman != null:
			audioman.play_sfx("coin", 0.0, 0.7)
		die()	

func die():
	if dead:
		return
	dead = true
	queue_free()

func _on_MagnetArea_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_MagnetArea_body_exited(body):
	if body.is_in_group("player"):
		player = null

func _on_PickableArea_body_entered(body):
	if body.is_in_group("player"):
		pickup()
	#elif body.is_in_group("player_bullet"):
	#	var normal = body.speed.normalized()
	#	body.get_hit(position - normal * 4.0)
	#	apply_central_impulse(normal * 30.0)

func _on_DeathTimer_timeout():
	if !permanent:
		die()
