extends Camera2D

onready var env = $Environment
var current_position
var shake_intensity = 0.0
var shaking = false

var shake_timer:Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	current_position = position
	shake_timer = Timer.new()
	shake_timer.wait_time = 1.0
	shake_timer.one_shot = true
	shake_timer.autostart = false
	var _meh = shake_timer.connect("timeout", self, "end_shake")
	add_child(shake_timer)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !shaking:
		shake_intensity *= 0.9
	offset = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)) * shake_intensity
	position = current_position + offset

func shake(intensity=1.0, time = 1.0):	
	shake_intensity = intensity
	shaking = true
	shake_timer.start(time)

func end_shake():
	shaking = false

func update_position(pos:Vector2):
	current_position = pos

func blur(amount:float=0.1):
	env.environment.dof_blur_near_enabled = amount > 0.0
	env.environment.dof_blur_near_amount = amount
