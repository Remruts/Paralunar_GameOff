extends KinematicBody2D

var dead = false
export var accel:Vector2 = Vector2.ZERO
export var speed:Vector2 = Vector2.RIGHT * 400.0
export var max_speed:float =  400.0
export var rotate_with_speed:bool = true
export var knockback_strength:float = 50.0

export(PackedScene) var effect1
export(PackedScene) var effect2

var damage = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	rotation = speed.angle()
	pass # Replace with function body.

func _process(_delta):
	var gm = get_node("/root/GameManager")
	if gm == null:
		return
	if gm.cam != null:
		if not Rect2(
			gm.cam.limit_left - 8.0, 
			gm.cam.limit_top - 8.0, 
			abs(gm.cam.limit_left) + abs(gm.cam.limit_right) + 8.0, 
			abs(gm.cam.limit_top) + abs(gm.cam.limit_bottom) + 8.0
		).has_point(position):
			die()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	speed += accel
	var speed_magnitude = speed.length()
	if speed_magnitude > max_speed:
		speed = speed.normalized() * max_speed
	elif speed_magnitude < 0.1:
		speed = Vector2.ZERO
	else:
		if rotate_with_speed:
			rotation = speed.angle()
	
	var collision = move_and_collide(speed * delta)
	if collision:
		if collision.collider.is_in_group("solid"):
			if not dead:
				get_hit(collision.position + collision.normal)
		elif collision.collider.is_in_group("enemy"):
			get_hit(collision.position + collision.normal)
			var knockback_direction = (position - collision.collider.position).normalized() * knockback_strength
			collision.collider.get_hurt(damage, knockback_direction)

func get_hit(pos):
	die()
	instance_effects(pos)

func instance_effects(pos):
	if effect1 != null:
		var new_effect = effect1.instance()
		get_tree().current_scene.add_child(new_effect)
		new_effect.global_position = pos
		new_effect.rotation = rand_range(0, 2 * PI)

	if effect2 != null:
		var starting_angle = rand_range(0, 2*PI)
		var max_effects = 3 + randi() % 1
		for i in range(max_effects):
			var new_effect = effect2.instance()
			get_tree().current_scene.add_child(new_effect)
			new_effect.rotation = rand_range(0, 2 * PI)
			new_effect.scale = Vector2.ONE
			var new_angle = (i/float(max_effects)) * 2 * PI + starting_angle + rand_range(-0.2, 0.2)
			new_effect.speed = Vector2(cos(new_angle), sin(new_angle)) * (30.0 + rand_range(0.0, 0.0))
			new_effect.accel = -new_effect.speed.normalized() * 1.0
			new_effect.global_position = pos + new_effect.speed.normalized() * 0.1
			
func die():
	if not dead:
		dead = true
		queue_free()

func _on_DeathTimer_timeout():
	die()
