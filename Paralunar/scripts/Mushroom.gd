extends "Enemy.gd"

onready var wander_timer = $WanderTimer
onready var anim = $AnimationPlayer
onready var spr = $Sprite
onready var my_body = get_node(".")

var spore_prefab = preload("res://prefabs/Spore.tscn")

var state = "wander"
var player = null

var wander_speed = 50
var current_speed = wander_speed
var direction = 1.0

var starting_point

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	material = material.duplicate()
	gravity = 49.0
	friction = 0.98
	starting_point = position
	direction = 1.0 if rand_range(0.0, 1.0) > 0.5 else -1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	._process(delta)
		
	if inactive:
		state = "idle"
		
	if !my_body.is_on_floor():
		state = "wander"
	
	if state == "wander":
		anim.play("run")

func _physics_process(delta):
	if hurt:
		return

	speed.x *= friction
	if state == "wander":
		current_speed = wander_speed
	elif state in ["idle", "spore_spread"]:
		current_speed = 0.0
		speed.x = 0.0
	
	speed.x += direction * current_speed * delta
			
	speed.y += gravity * delta

	spr.flip_h = speed.x < 0.0

	speed = my_body.move_and_slide(speed, Vector2.UP)
	
	if my_body.is_on_wall():
		direction = -direction

func get_hurt(damage, knockback_direction = Vector2.ZERO):
	if inactive:
		return
	.get_hurt(damage, knockback_direction)
	#speed = knockback_direction
	#current_speed = knockback_direction.length()

func _on_Area2D_body_entered(body):
	if inactive:
		return
	if body.is_in_group("player_bullet"):
		var normal = body.speed.normalized()
		body.get_hit(body.position - normal * 7.0)	
		var knockback_direction = normal.normalized() * body.knockback_strength
		get_hurt(body.damage, knockback_direction)

func _on_WanderTimer_timeout():
	if inactive:
		anim.play("idle")
		state = "idle"
		wander_timer.start()
		return
		
	var coin = rand_range(0.0, 1.0)
	if coin < 0.8:
		anim.play("run")
		state = "wander"
		direction = 1.0 if rand_range(0.0, 1.0) > 0.5 else -1.0
		wander_timer.start()
	elif coin < 0.9:
		state = "spore_spread"
		anim.play("spore_spread")
		current_speed = 0.0
		speed.x = 0.0
	else:
		anim.play("idle")
		state = "idle"
		wander_timer.start()

func _on_HurtTimer_timeout():
	._on_HurtTimer_timeout()	

func spread_spores():
	if inactive:
		return
	play_sfx("spores", 0.05, 0.5)
	var start_angle = rand_range(0.0, 2 * PI)
	for i in range(10):
		var angle = start_angle + i/10.0 * 2 * PI
		var spore = spore_prefab.instance()
		get_tree().current_scene.add_child(spore)
		spore.position = position + Vector2(cos(angle), sin(angle)) * 4.0
		spore.speed = Vector2(cos(angle), sin(angle)) * 30.0

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "spore_spread":
		anim.play("idle")
		state = "idle"
		wander_timer.start()
