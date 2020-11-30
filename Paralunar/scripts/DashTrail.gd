extends Particles2D

onready var death_timer = $DeathTimer
var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	emitting = true
	pass # Replace with function body.

func _on_DeathTimer_timeout():
	if !dead:
		if emitting:
			emitting = false
			death_timer.start(1.0)
		else:
			dead = true
			queue_free()