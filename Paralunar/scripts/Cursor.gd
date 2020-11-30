extends Sprite

onready var anim = $RotationAnimator
onready var rot_stuff = $rotating_stuff

export var rotation_speed:float = 1.0

var last_position:Vector2 = Vector2.ZERO
onready var invisible_timer:Timer = $InvisibleTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = get_global_mouse_position()
	last_position = get_global_mouse_position()
	visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var gm = get_node("/root/GameManager")
	if gm != null:
		if !gm.visible_cursor:
			visible = false
			return
		
	rot_stuff.rotation += rotation_speed * 2.0 * PI * delta
	if rot_stuff.rotation_degrees > 360:
		rot_stuff.rotation_degrees -= 360.0
	
	global_position = get_global_mouse_position()
	if last_position != global_position:
		visible = true
		invisible_timer.start()
	last_position = global_position
	
	if Input.is_action_just_pressed("dash"):
		invisible_timer.start()
		visible = true
	
	if Input.is_action_pressed("shoot"):
		if anim.current_animation != "shooting":
			anim.play("shooting")				
		invisible_timer.start()
		visible = true
	elif !invisible_timer.is_stopped():
		if anim.current_animation != "idle":
			anim.play("idle")

func _on_InvisibleTimer_timeout():
	anim.play("fadeOut")