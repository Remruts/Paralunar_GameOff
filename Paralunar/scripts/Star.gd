extends AnimatedSprite

onready var twink_timer = $TwinkTimer
var twink_factor = 1.0

func _ready():
	twink_timer.start(rand_range(3.0, 10.0))
	twink_factor = rand_range(1.0, 5.0)
	pass # Replace with function body.

func _process(_delta):
	if animation == "idle":
		modulate.a = 0.5 + ((sin(twink_factor * (OS.get_ticks_msec() / 1000.0 + position.x + position.y)) + 1.0) / 4.0)
	pass

func _on_TwinkTimer_timeout():
	play("twink")
	modulate.a = 1.0
	twink_timer.start(rand_range(5.0, 10.0))

func _on_Star_animation_finished():
	play("idle")
