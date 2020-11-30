extends Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	frame = randi() % 10
	rotation = rand_range(0.0, 2.0*PI)
	material = material.duplicate()	
	var gm = get_node("/root/GameManager")
	if gm != null:
		material.set_shader_param("blink_color", gm.get_random_color())
	#material.set_shader_param("angle", rand_range(0.0, 2.0*PI))
	pass
