extends Sprite

var starting_position:Vector2
var angle = 0.5 * PI
var rotation_speed = 0.5
var radius = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	starting_position = position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	angle += delta * rotation_speed
	if angle > 2 *PI:
		angle -= 2*PI
	
	position = starting_position + Vector2(cos(angle), sin(angle)) * radius
	pass
