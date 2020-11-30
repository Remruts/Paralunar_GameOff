extends AnimatedSprite

var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# make material unique
	if material != null:
		material = material.duplicate()
	play("explode")
	pass # Replace with function body.

func _on_ExplosionEffect_animation_finished():
	if !dead:
		dead = true
		queue_free()
