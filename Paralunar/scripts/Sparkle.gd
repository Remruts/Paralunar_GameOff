extends AnimatedSprite

var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# make material unique
	material = material.duplicate()
	play("sparkle")
	var gm = get_node("/root/GameManager")
	if gm != null:
		material.set_shader_param("new_color", gm.get_random_color())
	
	speed_scale = 1.0 + rand_range(-0.1, 0.1)
	var s = rand_range(0.25, 0.1)
	scale = Vector2(s, s)
	pass # Replace with function body.

func _on_Sparkle_animation_finished():
	if !dead:
		dead = true
		queue_free()
