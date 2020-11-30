extends AnimatedSprite

var dead = false

func _ready():
	play("idle")

func _on_dust_animation_finished():
	if dead:
		return
	dead = true
	queue_free()