extends "Enemy.gd"

onready var anim:AnimationPlayer = $AnimationPlayer

onready var witch_arm1 = $witch_arm1
onready var witch_arm2 = $witch_arm2
onready var witch_arm1_anim:AnimationPlayer = $WitchArm1Animator
onready var witch_arm2_anim:AnimationPlayer = $WitchArm2Animator

onready var hurt_area:Area2D = $Area2D

var little_witch = preload("res://prefabs/LittleWitch1.tscn")
var direct_bullet_prefab = preload("res://prefabs/EnemyBullet.tscn")
var follow_bullet_prefab = preload("res://prefabs/FollowBullet.tscn")
var homing_bullet_prefab = preload("res://prefabs/HomingBullet.tscn")

var state = "idle"
var player = null

var current_speed = 20.0

onready var attack_timer = $AttackTimer
onready var spr = self
var target
var starting_point

signal life_changed(new_life)

var max_direct_shots = 5
var max_follow_shots = 3
var direct_shots_rate = 0.5
var follow_shots_rate = 1.0
var disappear_rate = 2.0
var max_homing_shots = 5

var action_options = [
	"disappear",
	"direct_shot",
	"follow_shot",
	"homing_shot"
]
var actions_bag = []

var valid_positions = [
	Vector2(200, 88),	
	Vector2(104, 88),
	Vector2(234, 88),
	Vector2(296, 96),
	Vector2(88, 120),
	Vector2(328, 120),
	Vector2(152, 120),
	Vector2(272, 120),
	Vector2(200, -16),
	Vector2(264, -16),
	Vector2(238, -16),
	Vector2(72, -16),
]
var positions_bag = valid_positions.duplicate(true)

var shoot_counter:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready() 
	material = material.duplicate()
	gravity = 0.0
	friction = 0.99
	starting_point = position
	target = starting_point

	attack_timer.start()

	var ui = get_tree().current_scene.get_node("UI")
	self.connect("life_changed", ui, "change_boss_life")

	var audioman = get_node("/root/AudioManager")
	if audioman != null:
		audioman.play_with_fade("FinalBoss")

func build_actions_bag():
	if max_life <= 0.0:
		return
	
	if life/max_life < 0.3:
		actions_bag = ["disappear", "disappear", "disappear", "disappear", "direct_shot", "follow_shot", "homing_shot"]
		max_homing_shots = 10
	elif life/max_life < 0.65:
		actions_bag = ["disappear", "disappear", "disappear", "disappear", "direct_shot", "follow_shot", "homing_shot"]
		max_direct_shots = 15
		direct_shots_rate = 0.15
		max_follow_shots = 5
		disappear_rate = 0.5
	elif life/max_life < 0.85:
		actions_bag = ["disappear", "disappear", "direct_shot", "follow_shot", "disappear"]
		max_direct_shots = 7
		direct_shots_rate = 0.35
		disappear_rate = 1.5
	else:
		actions_bag = ["disappear", "disappear", "direct_shot", "disappear"]	

func get_new_action():
	if len(actions_bag) == 0:
		build_actions_bag()
	
	var index = randi() % len(actions_bag)
	var action = actions_bag[index]
	actions_bag.remove(index)

	return action

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	._process(delta)
	if dead:
		return
	
	#if Input.is_action_just_pressed("shoot"):
	#	disappear()

	if inactive:
		state = "wander"

	speed *= friction
		
	if hurt:
		material.set_shader_param("blink_magnitude", 1.0)
	else:
		material.set_shader_param("blink_magnitude", 0.0)
	
	if state == "idle":
		speed += (target + Vector2(rand_range(-10, 10), rand_range(-10, 10)) - position).normalized() * current_speed * delta

	if speed.length() > current_speed:
		speed = speed.normalized() * current_speed
		
	position += speed * delta

func get_hurt(damage, knockback_direction = Vector2.ZERO):
	if inactive or dead:
		return
	.get_hurt(damage, knockback_direction)
	emit_signal("life_changed", life)

func _on_Area2D_body_entered(body):
	if inactive or dead:
		return
	if body.is_in_group("player_bullet"):
		var normal = body.speed.normalized()
		body.get_hit(body.position - normal * 7.0)	
		var knockback_direction = normal.normalized() * body.knockback_strength
		get_hurt(body.damage, knockback_direction)

func _on_FollowArea_body_entered(body):
	if dead:
		return
	if body.is_in_group("player"):
		state = "follow"
		player = body
		attack_timer.stop()

func _on_FollowArea_body_exited(body):
	if dead:
		return
	if body.is_in_group("player"):
		attack_timer.start()

func _on_AttackTimer_timeout():
	if dead:
		return
	if state == "idle":
		if anim.current_animation == "idle":
			shoot_counter = 0
			var current_action = get_new_action()
			if current_action == "disappear":
				attack_timer.start(disappear_rate)
				disappear()
			elif current_action == "direct_shot":
				witch_arm1_anim.play("appear")
				state = "direct_shot"
			elif current_action == "follow_shot":
				witch_arm2_anim.play("appear")
				state = "follow_shot"
			elif current_action == "homing_shot":
				state = "homing_shot"
	elif state == "direct_shot":
		if shoot_counter < max_direct_shots:
			shoot_direct_bullet()
			attack_timer.start(direct_shots_rate)
			shoot_counter += 1
		else:
			#attack_timer.start(1.0)
			#witch_arm1_anim.play("disappear")			
			state = "idle"
			attack_timer.start(3.0)
			disappear()
	elif state == "follow_shot":
		if shoot_counter < max_follow_shots:
			shoot_follow_bullet()
			attack_timer.start(follow_shots_rate)
			shoot_counter += 1
		else:
			state = "idle"
			attack_timer.start(3.0)
			disappear()
	elif state == "homing_shot":
		shoot_homing_bullets()
		attack_timer.start(follow_shots_rate)
		state = "idle"
		attack_timer.start(3.0)
		disappear()

func shoot_homing_bullets():
	if dead:
		return
	
	play_sfx("homing_bullet_spawn")
	var start_angle = rand_range(0, 2*PI)
	for i in range(max_homing_shots):
		var bullet_angle = start_angle + (float(i)/float(max_homing_shots)) * 2 * PI
		var bullet = homing_bullet_prefab.instance()
		get_tree().current_scene.call_deferred("add_child", bullet)
		bullet.global_position = global_position + Vector2(-16, 0.0)
		bullet.speed = Vector2(cos(bullet_angle), sin(bullet_angle)) * 30.0
	
	for _i in range(rand_range(3, 5)):
		var sparkle = sparkle_prefab.instance()
		get_tree().current_scene.add_child(sparkle)	
		sparkle.global_position = global_position + Vector2(-16, 0.0) + Vector2(rand_range(-5.0, 5.0),rand_range(-5.0, 5.0))

func shoot_direct_bullet():
	if dead:
		return

	var bullet = direct_bullet_prefab.instance()
	get_tree().current_scene.call_deferred("add_child", bullet)
	var new_pos = witch_arm1.global_position + Vector2(-8, -4)
	bullet.global_position = new_pos
	var players = get_tree().get_nodes_in_group("player")
	if len(players) > 0:	
		bullet.speed = (players[0].global_position + Vector2(0.0, 30.0 + shoot_counter * -10.0) - new_pos).normalized() * 60.0
	else:
		bullet.speed = Vector2(60, 0)

	if life/max_life < 0.65:
		var bullet2 = direct_bullet_prefab.instance()
		get_tree().current_scene.call_deferred("add_child", bullet2)		
		bullet2.global_position = new_pos
		if len(players) > 0:	
			bullet2.speed = (players[0].global_position + Vector2(0.0, 30.0 + shoot_counter * -10.0) - new_pos).normalized() * -60.0
		else:
			bullet2.speed = Vector2(-60, 0)

	if life/max_life < 0.3:
		var bullet3 = direct_bullet_prefab.instance()
		get_tree().current_scene.call_deferred("add_child", bullet3)
		bullet3.global_position = new_pos
		if len(players) > 0:
			var bullet_angle = (players[0].global_position + Vector2(0.0, 30.0 + shoot_counter * -10.0) - new_pos).angle() - PI/2.0
			bullet3.speed = Vector2(cos(bullet_angle), sin(bullet_angle))  * 60.0
		else:
			bullet3.speed = Vector2(-60, 0)
	
	for _i in range(rand_range(3, 5)):
		var sparkle = sparkle_prefab.instance()
		get_tree().current_scene.add_child(sparkle)	
		sparkle.global_position = new_pos + Vector2(rand_range(-5.0, 5.0),rand_range(-5.0, 5.0))

func shoot_follow_bullet():
	if dead:
		return
	var bullet = follow_bullet_prefab.instance()
	get_tree().current_scene.call_deferred("add_child", bullet)
	var new_pos = witch_arm2.global_position + Vector2(8, -4)
	bullet.global_position = new_pos
	#bullet.call_deferred("move_towards_player")
	
	for _i in range(rand_range(3, 5)):
		var sparkle = sparkle_prefab.instance()
		get_tree().current_scene.call_deferred("add_child", sparkle)
		sparkle.global_position = new_pos + Vector2(rand_range(-5.0, 5.0),rand_range(-5.0, 5.0))

func _on_HurtTimer_timeout():
	._on_HurtTimer_timeout()	

func die():
	if !dead:
		var audioman = get_node("/root/AudioManager")
		if audioman != null:
			audioman.stop()
		var ui = get_tree().current_scene.get_node("UI")
		if ui != null:
			ui.hide_boss_bar()

		if cam != null:
			cam.shake(2.0, 3.0)

		witch_arm1_anim.play("hidden")
		witch_arm2_anim.play("hidden")

		var exp_angle = 0.0
		var starting_angle = rand_range(0.0, 2 * PI)
		var explosion_num = rand_range(4, 7) + int(max_life / 5.0)
		for i in range(explosion_num):
			exp_angle = starting_angle + i/float(explosion_num) * 2 * PI + rand_range(-0.2, 0.2)
			var exp_offset = Vector2(cos(exp_angle), sin(exp_angle))
			exp_offset += exp_offset * (explosion_num / 20.0)
			explosion(exp_offset)
		
		# for i in range(coins_to_spawn):			
		#     exp_angle = starting_angle + i/float(coins_to_spawn) * 2 * PI + rand_range(-0.2, 0.2)
		#     spawn_coin(exp_angle, rand_range(30.0, 35.0))
				
		var gm = get_node("/root/GameManager")
		if gm != null:                
			gm.hit_stun(0.03)
			gm.transition_to("scenes/EndingCutscene.tscn", "blackOut", false)
		
		hurt_area.set_deferred("monitorable", false)
		hurt_area.set_deferred("monitoring", false)        

		dead = true
		anim.play("die")
		play_sfx("enemy_explosion")

		# destroy all bullets
		var my_bullets = get_tree().get_nodes_in_group("EnemyBullet")
		for b in my_bullets:
			b.die()
		
		var witch1 = little_witch.instance()
		get_tree().current_scene.call_deferred("add_child", witch1)
		witch1.global_position = global_position + Vector2(0, 10.0)
		witch1.speed = Vector2(50, -50)
		witch1.get_node("Sprite").frame = 0

		var witch2 = little_witch.instance()
		get_tree().current_scene.call_deferred("add_child", witch2)
		witch2.global_position = global_position + Vector2(0, 20.0)
		witch2.speed = Vector2(40, -50)
		witch2.get_node("Sprite").frame = 1

		var witch3 = little_witch.instance()
		get_tree().current_scene.call_deferred("add_child", witch3)
		witch3.global_position = global_position + Vector2(0, 30.0)
		witch3.speed = Vector2(30, -50)
		witch3.get_node("Sprite").frame = 2

func disappear():
	if dead:
		return

	play_sfx("teleport")

	hurt_area.set_deferred("monitorable", false)
	hurt_area.set_deferred("monitoring", false)
	anim.play("disappear")
	witch_arm1_anim.play("hidden")
	witch_arm2_anim.play("hidden")
	
	for _i in range(4):
		var players = get_tree().get_nodes_in_group("player")
		if len(positions_bag) == 0:
			positions_bag = valid_positions.duplicate(true)
		var ind = rand_range(0, len(positions_bag))
		
		target = positions_bag[ind]
		positions_bag.remove(ind)		
		if len(players) > 0:
			if (players[0].global_position - target).length() > 100:
				break
		else:
			break
	# FIXME: Debería chequear que no aparezca encima de le jugadore
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "die":
		queue_free()
	elif anim_name == "appear":
		anim.play("idle")
	elif anim_name == "disappear":
		anim.play("appear")
		play_sfx("teleport")
		hurt_area.set_deferred("monitorable", true)
		hurt_area.set_deferred("monitoring", true)
		position = target
	pass


func _on_WitchArm1Animator_animation_finished(anim_name):
	if anim_name == "appear":
		witch_arm1_anim.play("idle")
		if state == "direct_shot":
			attack_timer.start(direct_shots_rate)
			shoot_direct_bullet()
			shoot_counter += 1
	elif anim_name == "disappear":
		witch_arm1_anim.play("hidden")

func _on_WitchArm2Animator_animation_finished(anim_name):
	if anim_name == "appear":
		witch_arm2_anim.play("idle")
		if state == "follow_shot":
			attack_timer.start(follow_shots_rate)
			shoot_follow_bullet()
			shoot_counter += 1
	elif anim_name == "disappear":
		witch_arm2_anim.play("hidden")
