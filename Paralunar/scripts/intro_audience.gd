extends Sprite

var starting_position
var starting_time

var speed_y = 1.0
var speed_x = 1.0

var height = 16.0
var width = 16.0

# Called when the node enters the scene tree for the first time.
func _ready():
    starting_position = position
    starting_time = rand_range(0, 1000)
    speed_x += rand_range(-0.1, 0.1)
    speed_y += rand_range(-0.1, 0.1)

func move_faster():
    height = 48.0
    width = 128.0
    speed_x = 5.0
    speed_y = 5.0
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var pi_time = ((OS.get_ticks_msec() + starting_time) / 1000.0) * 2 * PI
    position = starting_position + Vector2(cos(pi_time * speed_x) * width, sin(pi_time * speed_y) * height) * delta	
    pass
