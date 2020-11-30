extends RigidBody2D

onready var anim:AnimationPlayer = $AnimationPlayer
onready var down_cast:RayCast2D = $DownCast
onready var side_cast:RayCast2D = $SideCast

export(PhysicsMaterial) var physics_material
var physics_state:Physics2DDirectBodyState
var input_vector = Vector2.RIGHT

var max_speed = 100.0
var current_speed = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if physics_material != null:
		physics_material_override = physics_material
	pass # Replace with function body.

func _draw():
	draw_line(Vector2.ZERO, input_vector.rotated(-rotation) * 32.0, Color.rebeccapurple, 2.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update()
	var raw_input = Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))

	if raw_input.length_squared() > 0.1:
		input_vector = raw_input.normalized()
	else:
		input_vector = Vector2.ZERO

	down_cast.global_rotation = 0.0
	side_cast.global_rotation = 0.0
	side_cast.cast_to = Vector2.RIGHT * input_vector.x * 12.0

	if Input.is_action_just_pressed("ui_quit"):
		get_tree().quit()

	if Input.is_action_pressed("jetpack"):
		mode = MODE_RIGID
		apply_impulse((Vector2.DOWN * 8.0).rotated(rotation), (Vector2.UP * 100.0).rotated(rotation))
		anim.play("idle")
	elif Input.is_action_just_released("shoot"):
		anim.play("ball")
	
	if Input.is_action_just_pressed("shoot"):
		var shoot_vector = Vector2.RIGHT
		if input_vector.length_squared() > 0.1:
			shoot_vector = input_vector
		
		mode = MODE_RIGID		
		apply_impulse(shoot_vector.rotated(deg2rad(180)) * 8.0, shoot_vector.rotated(deg2rad(180)) * 100.0)
		anim.play("idle")
	pass

func _integrate_forces(state):
	# state.step # physics delta
	physics_state = state
	var velocity = state.linear_velocity.length()
	if velocity > 250:
		state.linear_velocity = state.linear_velocity.normalized() * 250.0
	
	
func _physics_process(delta):
	if physics_state != null:
		var velocity = physics_state.linear_velocity.length()
		if down_cast.is_colliding():
			if mode == MODE_RIGID:
				if velocity > 0 and velocity < 5:
					anim.play("idle")
					stop_body()
				if down_cast.is_colliding():
					if abs(input_vector.x) > 0.5:
						anim.play("idle")
						if mode != MODE_KINEMATIC:
							stop_body()
		if mode == MODE_KINEMATIC:
			current_speed =  clamp(current_speed + input_vector.x * 100.0 * delta, -max_speed, max_speed)
			current_speed *= 0.98
			var new_position = Vector2.RIGHT * current_speed * delta
			if !side_cast.is_colliding():
				position += new_position
			else:
				current_speed = 0.0
				print("COLLISION at new position" + str(position + new_position))
			
				
func stop_body(mode=MODE_KINEMATIC):
	set_deferred("mode", mode)
	rotation = 0.0				
	applied_torque = 0.0						
	applied_force = Vector2.ZERO
	#input_vector = Vector2.RIGHT
