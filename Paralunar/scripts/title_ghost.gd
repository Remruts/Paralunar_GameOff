extends Sprite

var starting_position
var offset_angle = 0.0
var speed = Vector2.ZERO
var max_speed = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	starting_position = position
	offset_angle = rand_range(0.0, 2 * PI)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	offset_angle += rand_range(-PI, PI) * 10.0 * delta
	#offset_angle += delta
	if offset_angle > 2 * PI:
		offset_angle -= 2*PI

	#var offset_radius = ((sin(OS.get_ticks_msec() + 1.0)) / 2.0) * 128.0
	var offset_radius = 4.0

	speed += (starting_position + Vector2(cos(offset_angle), sin(offset_angle)) * offset_radius - position).normalized() * delta * 0.5
	
	if speed.length() > max_speed:
		speed = speed.normalized() * max_speed

	position += speed
	pass
