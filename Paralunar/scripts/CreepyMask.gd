extends "Enemy.gd"

onready var creepy_audio = $CreepyAudio

var state = "idle"
var player = null
var offset_radius = 128.0
var offset_angle = 0.0

var follow_speed = 40
var wander_speed = 20
var current_speed = wander_speed

onready var wander_timer = $WanderTimer
var target
var starting_point

onready var my_body = self
onready var spr = $Sprite
onready var follow_area = $FollowArea/CollisionShape2D

var starting_follow_radius

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()

	starting_follow_radius = follow_area.shape.radius

	material = material.duplicate()
	gravity = 0.0
	friction = 0.99
	starting_point = position
	target = starting_point

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	._process(delta)

	if inactive:
		state = "idle"

	speed *= friction
	
	offset_angle += delta
	if offset_angle > 2 * PI:
		offset_angle -= 2*PI
	
	if hurt:
		material.set_shader_param("blink_magnitude", 1.0)
	else:
		material.set_shader_param("blink_magnitude", 0.0)
		if state == "follow":
			follow_area.shape.radius = starting_follow_radius + 256
			
			var dist_to_target = (global_position - target).length()
			current_speed = follow_speed + clamp(dist_to_target -5.0, 0.0, 100.0) * 2.0

			if dist_to_target < 30.0:
				if cam != null:
					cam.shake(0.5, 0.1)

			if player != null:
				target = player.position
				offset_radius = ((sin(OS.get_ticks_msec() + 1.0)) / 2.0) * 32.0
				spr.position = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)).normalized() *  15.0 / max(dist_to_target, 30.0)
			else:
				state = "wander"
		elif state == "wander":
			spr.position = Vector2.ZERO

			offset_radius = max(offset_radius - delta, 0.0)			
			current_speed = wander_speed
			target = starting_point
			offset_angle += rand_range(-PI, PI) * 5.0 * delta
			if (global_position - starting_point).length() < 5.0:
				state = "idle"
		elif state == "idle":
			follow_area.shape.radius = starting_follow_radius
			spr.position = Vector2.ZERO
			current_speed = 0.0
		
		speed += (target + Vector2(cos(offset_angle), sin(offset_angle)) * offset_radius - position).normalized() * delta * current_speed
			
	if speed.length() > current_speed:
		speed = speed.normalized() * current_speed
		
	speed = my_body.move_and_slide(speed)

func get_hurt(damage, knockback_direction = Vector2.ZERO):
	if inactive:
		return
	.get_hurt(damage, knockback_direction)
	#speed = knockback_direction
	#current_speed = knockback_direction.length()

func creepy_sound():
	if state != "follow":
		creepy_audio.play()
		var audioman = get_node("/root/AudioManager")
		if audioman != null:
			var ui = get_tree().current_scene.get_node("UI")
			if ui != null and !ui.boss_lifebar.visible:
				audioman.stop()

func _on_Area2D_body_entered(body):
	if inactive:
		return
	if body.is_in_group("player_bullet"):
		var players = get_tree().get_nodes_in_group("player")
		if len(players) > 0:			
			player = players[0]
			creepy_sound()				
			state = "follow"
			wander_timer.stop()
			offset_angle = rand_range(0.0, 2 * PI)
		var normal = body.speed.normalized()
		body.get_hit(body.position - normal * 7.0)	
		var knockback_direction = normal.normalized() * body.knockback_strength
		get_hurt(body.damage, knockback_direction)

func _on_FollowArea_body_entered(body):
	if body.is_in_group("player"):
		wander_timer.stop()
		creepy_sound()
		state = "follow"
		player = body
		offset_angle = rand_range(0.0, 2 * PI)
			

func _on_FollowArea_body_exited(body):
	if body.is_in_group("player"):		
		wander_timer.start()
		player = null

func _on_WanderTimer_timeout():
	if state == "follow":
		state = "wander"

func _on_HurtTimer_timeout():
	._on_HurtTimer_timeout()

func die():
	if !dead:
		var audioman = get_node("/root/AudioManager")
		if audioman != null:
			audioman.play_sfx("scream")
	.die()