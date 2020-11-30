extends AnimatedSprite

var dead = false
export var accel:Vector2 = Vector2.ZERO
export var speed:Vector2 = Vector2.ZERO
export var max_speed:float =  400.0
export var rotate_with_speed:bool = false

var kill_after_animation = true

func _ready():
	play()
	pass

func _process(delta):
	speed += accel
	var speed_magnitude = speed.length()
	if speed_magnitude > max_speed:
		speed = speed.normalized() * max_speed
	elif speed_magnitude < 0.1:
		speed = Vector2.ZERO
	else:
		if rotate_with_speed:
			rotation = speed.angle()
		
	position += speed * delta

func die():
	if not dead:
		dead = true
		queue_free()

func _on_animation_finished():
	if kill_after_animation:
		die()