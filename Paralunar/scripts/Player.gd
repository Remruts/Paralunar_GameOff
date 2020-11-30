extends KinematicBody2D

onready var spr:Sprite = $Top
onready var spr_bot:Sprite = $Top/Bottom
onready var gun_spr:Sprite = $Top/Gun

onready var anim:AnimationPlayer = $AnimationPlayer
onready var anim_bot:AnimationPlayer = $LegsAnimator

onready var dash_timer:Timer = $DashTimer
onready var hurt_timer:Timer = $HurtTimer
onready var shoot_timer:Timer = $ShootTimer

var bullet_prefab = preload("res://prefabs/RegularBullet.tscn")
var explosion_prefab = preload("res://prefabs/ExplosionEffect.tscn")
var hurt_effect_prefab = preload("res://prefabs/HurtEffect.tscn")
var dash_effect_prefab = preload("res://prefabs/DashTrail.tscn")
var flash_effect_prefab = preload("res://prefabs/MuzzleFlash.tscn")
var dust_effect_prefab = preload("res://prefabs/dust.tscn")

#########################

var angular_velocity:float = 0.0
var max_angular_velocity:float = 30.0
var angular_damping:float = 0.99

var bounce_damping:float = 0.4

var max_speed:float = 400
var run_speed:float = 600
var air_speed:float = 300
var friction = 0.9

var dash_cooldown = 0.1

var speed:Vector2 = Vector2.ZERO

var gravity:float = 50

var input_vector:Vector2 = Vector2.ZERO
var last_input_vector:Vector2 = Vector2.RIGHT

var joy_vector:Vector2 = Vector2.ZERO
var last_joy_vector:Vector2 = Vector2.RIGHT

var on_ground = false
var bouncing = false

var state = "air"
var attacking_state = "ready"

var cam

var hurt:bool = false
var dead:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	cam = get_tree().current_scene.get_node("Camera")
	cam.update_position(position)
	pass # Replace with function body.

func _draw():
	pass
	#draw_dotted_line(Vector2.ZERO, (get_global_mouse_position() - global_position).normalized() * 48.0, Color.white, 1.1, 4.0, 3.0, false)
	#draw_line(Vector2.ZERO, get_global_mouse_position() - global_position, Color.white)

func draw_dotted_line(start, end, color, width=1.0, dash_length=4.0, separation=2.0, antialias=false):
	var length = (end - start).length()
	var normal = (end - start).normalized()
	var step_size = (dash_length + separation)
	var step_num = int(length / step_size)
	
	for i in range(step_num):
		if i < step_num:
			draw_line(start + normal * i * step_size, start + normal * (i+1) * step_size - separation * normal, color, width, antialias)
		else:
			draw_line(start + normal * i * step_size, end - normal * separation, color, width, antialias)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()

	if hurt_timer.time_left > hurt_timer.wait_time - 0.2:
		spr.material.set_shader_param("blink_magnitude", 1.0)
	else:
		spr.material.set_shader_param("blink_magnitude", 0.0)

	cam.update_position(position)
	if input_vector.length_squared() > 0.0:
		last_input_vector = input_vector

	if joy_vector.length_squared() > 0.0:
		last_joy_vector = joy_vector
	
	input_vector = Vector2(Input.get_action_strength("move_right") - \
		Input.get_action_strength("move_left"), \
		Input.get_action_strength("move_down") - \
		Input.get_action_strength("move_up")
	).normalized()

	joy_vector = Vector2(Input.get_action_strength("target_right") - \
		Input.get_action_strength("target_left"), \
		Input.get_action_strength("target_down") - \
		Input.get_action_strength("target_up")
	).normalized()
	
	if Input.is_action_pressed("shoot"):
		if shoot_timer.is_stopped():
			shoot()
	
	if Input.is_action_pressed("jetpack"):
		jetpack(delta)
	
	if Input.is_action_just_pressed("dash"):
		dash(delta)
	
	if Input.is_action_pressed("stop_dash"):		
		stop_dash(delta)

	if state in ["idle", "running"]:
		if abs(input_vector.x) > 0.0:
			if anim.current_animation in ["idle", "run"]:
				spr.flip_h = last_input_vector.x < 0.0
			spr_bot.flip_h = last_input_vector.x < 0.0
		
		if state == "idle":
			if anim_bot.current_animation != "idle":
				anim_bot.play("idle")				
				spr_bot.flip_h = spr.flip_h
				if shoot_timer.is_stopped():
					spr.flip_h = last_input_vector.x < 0.0
					anim.play("idle")
		elif state == "running":
			if anim_bot.current_animation != "run":
				anim_bot.play("run")
			if anim.current_animation != "run":
				if shoot_timer.is_stopped():
					anim.play("run")
	elif state in ["air", "dash"]:
		if shoot_timer.is_stopped():
			anim.play("ball")
		anim_bot.play("air")

func shoot():
	shoot_timer.start()
	var mouse_vector = (get_global_mouse_position() - global_position).normalized()
	var gm = get_node("/root/GameManager")	
	if gm != null and gm.has_joystick:
		mouse_vector = last_joy_vector
	#Input.warp_mouse_position(get_global_transform_with_canvas().get_origin())
	var rot_vector = mouse_vector.rotated(-spr.rotation)
		
	if abs(rot_vector.y) < 0.2:
		anim.play("shoot_side")
		spr.flip_h = rot_vector.x < 0.0
		gun_spr.position = Vector2(int(9 * sign(rot_vector.x)), 1)
	elif abs(rot_vector.x) < 0.2:
		spr.flip_h = false
		if rot_vector.y < 0.01:
			gun_spr.position = Vector2(1.0, -2.8)
			anim.play("shoot_up")
		else:
			gun_spr.position = Vector2(1.0, 4)
			anim.play("shoot_down")
	else:
		spr.flip_h = rot_vector.x < 0.0
		if rot_vector.y < 0.01:
			gun_spr.position = Vector2(int(8 * sign(rot_vector.x)), -1)
			anim.play("shoot_side_up")
		else:
			gun_spr.position = Vector2(int(8 * sign(rot_vector.x)), 4)
			anim.play("shoot_side_down")
		
	gun_spr.flip_h = spr.flip_h

	# play sound
	play_sfx("player_shot")
	
	# spawn muzzle flash effect
	var flash_effect = flash_effect_prefab.instance()
	spr.call_deferred("add_child", flash_effect)
	flash_effect.position = gun_spr.position
	flash_effect.rotation = rot_vector.angle() - PI/2.0
	
	# instance bullet
	var my_bullet = bullet_prefab.instance()
	my_bullet.speed = mouse_vector * 300.0
	get_tree().current_scene.call_deferred("add_child", my_bullet)
	my_bullet.global_position = gun_spr.global_position + mouse_vector * 4.0
	#cam.shake(0.1, 0.1)

	if state in ["air", "dash"]:
		speed -= mouse_vector * my_bullet.knockback_strength * 0.6
		angular_velocity -= Vector2.RIGHT.dot(mouse_vector)
		state = "air"
		spr_bot.flip_h = spr.flip_h		
	elif state in ["running", "idle"]:
		if mouse_vector.y > 0.5:
			speed -= mouse_vector * my_bullet.knockback_strength
			angular_velocity -= Vector2.RIGHT.dot(mouse_vector)
			state = "air"

func stop_dash(delta):
	if !shoot_timer.is_stopped() or (!dash_timer.is_stopped() and (dash_timer.wait_time - dash_timer.time_left) < dash_cooldown):
		return
	if state in ["running", "idle"]:
		return
	if Input.is_action_just_pressed("stop_dash"):
		play_sfx("dash")
	
	spawn_dash_effects()
	speed *= 0.6
	angular_velocity += (sign(angular_velocity) if sign(angular_velocity) != 0.0 else 1.0)* 30.0 * delta
	state = "dash"
	#anim.play("ball")
	dash_timer.start()

func dash(delta):
	if !shoot_timer.is_stopped() or (!dash_timer.is_stopped() and (dash_timer.wait_time - dash_timer.time_left) < dash_cooldown):
		return
	var mouse_vector = (get_global_mouse_position() - global_position)
	var vec_len = mouse_vector.length()

	var gm = get_node("/root/GameManager")	
	if gm != null and gm.has_joystick:
		mouse_vector = input_vector
		vec_len = mouse_vector.length()	
		if vec_len < 0.1:
			mouse_vector = Vector2.ZERO
			vec_len = 0.0
	else:
		vec_len = mouse_vector.length()
		if vec_len < 12:
			mouse_vector = Vector2.ZERO
			vec_len = 0.0
		
	mouse_vector = mouse_vector.normalized()

	speed =  mouse_vector* 200.0
	
	
	if vec_len > 0.0:
		spr.rotation = mouse_vector.angle() + PI/2.0
		angular_velocity += Vector2.RIGHT.dot(mouse_vector)		
		
		var dash_effect = dash_effect_prefab.instance()
		spr.call_deferred("add_child", dash_effect)
		dash_effect.position = Vector2(0, 12.0)

		var dash_effect_left = dash_effect_prefab.instance()
		spr.call_deferred("add_child", dash_effect_left)
		dash_effect_left.position = Vector2(-3, 12.0)
		dash_effect_left.rotation = PI/10.0
		
		var dash_effect_right = dash_effect_prefab.instance()
		spr.call_deferred("add_child", dash_effect_right)
		dash_effect_right.position = Vector2(3, 12.0)
		dash_effect_right.rotation = -PI/10.0		
	else:
		angular_velocity += 30.0 * delta
		spawn_dash_effects()

	state = "dash"
	#anim.play("ball")
	play_sfx("dash")
	dash_timer.start()

func spawn_dash_effects():
	for i in range(5):
		var dash_effect = dash_effect_prefab.instance()
		var effect_angle =  (i/5.0) * 2 * PI
		spr.call_deferred("add_child", dash_effect)			
		dash_effect.position = Vector2(cos(effect_angle), sin(effect_angle)) * 12.0
		dash_effect.rotation = effect_angle - PI/2.0

func jetpack(delta):
	var new_vector = Vector2(cos(spr.rotation + PI/2.0), sin(spr.rotation + PI/2.0))
	speed -= new_vector * 500.0 * delta
	state = "air"
	#anim.play("ball")

func _physics_process(delta):

	if state != "dash":
		speed.y += gravity * delta
	
	if speed.length() > max_speed:
		speed = speed.normalized() * max_speed
		
	if state in ["idle", "running"]:
		speed.x += input_vector.x * run_speed * delta
		speed.x *= friction
		
		if abs(input_vector.x) > 0.01:
			state = "running"
		else:
			state = "idle"

		if abs(spr.rotation) > 0.1:
			spr.rotation += angle_difference(spr.rotation, 0.0) / (2.0 * PI) * 100.0 * delta
		else:
			spr.rotation = 0.0	
	# elif state == "air":
	# 	if (sign(input_vector.x) > 0.0 and speed.x < 10.0) or (sign(input_vector.x) < 0.0 and speed.x > -10.0):
	# 		speed.x += input_vector.x * air_speed * delta

	
	angular_velocity *= angular_damping
	
	if state in ["idle", "running"]:
		speed = move_and_slide(speed, Vector2.UP, true)
		if not is_on_floor():
			state = "air"
			#anim.play("ball")
	elif state in ["air", "dash"]:
		# si estás en el aire
		var collision = move_and_collide(speed * delta)
		if collision:
			if speed.length_squared() < 200 and speed.y > 0.0:
				if not state in ["idle", "running"]:
					state = "idle"
					anim.play("idle")
				angular_velocity = 0.0
				#spr.rotation = 0.0
			else:
				speed = speed.bounce(collision.normal) * bounce_damping
				angular_velocity -= collision.normal.y
				var rotated_normal = collision.normal
				rotated_normal.x = -collision.normal.y
				rotated_normal.y = collision.normal.x

				if speed.length() > 0.1:
					spawn_dust(collision.position + rotated_normal * 10.0, collision.normal.angle() - PI/2.0)
					spawn_dust(collision.position - rotated_normal * 10.0, collision.normal.angle() - PI/2.0, true)
					play_sfx("collision", 0.05, 0.6)
	
	# handle rotations
	angular_velocity = clamp(angular_velocity, -max_angular_velocity, max_angular_velocity)	
	spr.rotation += angular_velocity * delta

func angle_difference(angle1, angle2):
	var diff = angle2 - angle1
	return diff if abs(diff) < PI else diff + (2 * PI * -sign(diff))

func _on_DashTimer_timeout():
	if state == "dash":
		state = "air"

func die():
	if dead:
		return
	dead = true
	if cam != null:
		cam.shake(3.0, 0.1)

	var audioman = get_node("/root/AudioManager")
	if audioman != null:
		audioman.stop()

	var explosion = explosion_prefab.instance()
	get_tree().current_scene.call_deferred("add_child", explosion)
	explosion.global_position = global_position
	explosion.material.set_shader_param("blink_magnitude", 0.0)

	var gm = get_node("/root/GameManager")
	if gm != null:
		gm.restart()
		#gm.load_game(gm.current_file)
	play_sfx("player_die")
	queue_free()

func get_hurt(damage = 1):
	if !hurt:
		hurt = true
		hurt_timer.start()
		
		if cam != null:
			cam.shake(2.0, 0.05)
	
		var hurt_effect = hurt_effect_prefab.instance()
		self.call_deferred("add_child", hurt_effect)
		hurt_effect.position = Vector2.ZERO        
		hurt_effect.rotation = rand_range(0.0, 2.0 * PI)

		play_sfx("player_hurt")
	
		var gm = get_node("/root/GameManager")
		if gm != null:
			gm.hit_stun()
			gm.lose_lives(damage)
			if gm.lives <= 0:
				die()

func _on_Area2D_area_entered(area):
	if area.is_in_group("enemy"):		
		get_hurt(area.get_parent().damage)

func _on_HurtTimer_timeout():
	hurt = false

func play_sfx(name, random_pitch_offset=0.05, volume_scale=1.0):
	var audioman = get_node("/root/AudioManager")
	if audioman != null:
		audioman.play_sfx(name, random_pitch_offset, volume_scale)

func spawn_dust(pos, angle, flip=false):
	var dust = dust_effect_prefab.instance()
	get_tree().current_scene.call_deferred("add_child", dust)
	dust.global_position = pos
	dust.rotation = angle
	dust.flip_h = flip
