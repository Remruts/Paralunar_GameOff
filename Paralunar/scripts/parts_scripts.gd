extends Particles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	emitting = true
	pass # Replace with function body.


func _on_DeathTimer_timeout():
	queue_free()