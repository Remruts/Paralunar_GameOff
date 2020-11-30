extends Node2D

var explosion_effect = preload("res://prefabs/ExplosionEffect.tscn")
var splatter = preload("res://prefabs/Splatter.tscn")
var coin_prefab = preload("res://prefabs/Coin.tscn")
var sparkle_prefab = preload("res://prefabs/Sparkle.tscn")

export(float) var max_life = 1.0
var life = 1.0
var dead = false
var hurt = false

export var damage:int = 1

var speed:Vector2 = Vector2.ZERO
export var max_speed:Vector2 = Vector2(400.0, 400.0)
export var accel:Vector2 = Vector2(600, 600)
export var friction:float = 1.0

export var gravity:float = 50

export(float) var knockback_multiplier = 1.0
onready var hurt_timer:Timer = $HurtTimer

export var coins_to_spawn:int = 7

var inactive = false

var cam

export var enemy_name:String = "Enemy"

func _ready():
	life = max_life
	set_new_color_for_blink()
	if get_tree().current_scene.has_node("Camera"):
		cam = get_tree().current_scene.get_node("Camera")
	pass

func _process(_delta):
	var gm = get_node("/root/GameManager")
	if gm == null:
		return
	if gm.cam != null:
		inactive = not Rect2(
			gm.cam.limit_left - 8.0, 
			gm.cam.limit_top - 8.0, 
			abs(gm.cam.limit_left) + abs(gm.cam.limit_right) + 8.0, 
			abs(gm.cam.limit_top) + abs(gm.cam.limit_bottom) + 8.0
			).has_point(global_position)
	if hurt:
		material.set_shader_param("blink_magnitude", 1.0)
	else:
		material.set_shader_param("blink_magnitude", 0.0)
	pass

func die():
	if !dead:
		if cam != null:
			cam.shake(1.0, 0.1)

		var exp_angle = 0.0
		var starting_angle = rand_range(0.0, 2 * PI)
		var explosion_num = rand_range(4, 7) + int(max_life / 5.0)
		for i in range(explosion_num):
			exp_angle = starting_angle + i/float(explosion_num) * 2 * PI + rand_range(-0.2, 0.2)
			var exp_offset = Vector2(cos(exp_angle), sin(exp_angle)) * (0.6 + explosion_num / 7.0)
			explosion(exp_offset)
		
		for i in range(coins_to_spawn):			
			exp_angle = starting_angle + i/float(coins_to_spawn) * 2 * PI + rand_range(-0.2, 0.2)
			spawn_coin(exp_angle, rand_range(30.0, 35.0))
		dead = true

		if max_life > 10:
			var gm = get_node("/root/GameManager")
			if gm != null:                
				gm.hit_stun(0.03)

		play_sfx("enemy_explosion")
			
		queue_free()

func spawn_coin(angle, force):
	var coin = coin_prefab.instance()
	get_tree().current_scene.call_deferred("add_child", coin)
	coin.global_position = global_position
	var coin_movement = Vector2(cos(angle) * force, (sin(angle) - 1.0) * force)	
	coin.apply_central_impulse(coin_movement)
	coin.permanent = false


func explosion(exp_offset):
	var gm = get_node("/root/GameManager")
	if gm == null:
		return
	var current_color = gm.get_random_color()
	
	var explosion = explosion_effect.instance()
	explosion.material.set_shader_param("blink_color", current_color)
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position + exp_offset * 12.0
	explosion.speed_scale = 1.0 + rand_range(-0.1, 0.1)
	
	var splat = splatter.instance()
	get_tree().current_scene.add_child(splat)
	splat.global_position = global_position + exp_offset * rand_range(10.0, 20.0)
	splat.material.set_shader_param("blink_color", current_color)

	var sparkle = sparkle_prefab.instance()
	get_tree().current_scene.add_child(sparkle)
	sparkle.global_position = global_position + exp_offset * rand_range(5.0, 10.0)
	sparkle.scale = Vector2(1.0, 1.0)
	

func get_hurt(hurt_damage, _knockback_direction = Vector2.ZERO):
	if dead:
		return
	if !hurt:
		hurt = true

		play_sfx("bullet_hit")		
		
		if hurt_timer != null:
			hurt_timer.start()
		life -= hurt_damage
		if life <= 0.0:
			die()            
	
func set_new_color_for_blink(): 
	var gm = get_node("/root/GameManager")
	if gm != null:
		material.set_shader_param("blink_color", gm.get_random_color())

func _on_HurtTimer_timeout():
	hurt = false
	set_new_color_for_blink()

func play_sfx(name, random_pitch_offset=0.05, volume_scale=1.0):
	var audioman = get_node("/root/AudioManager")
	if audioman != null:
		audioman.play_sfx(name, random_pitch_offset, volume_scale)
