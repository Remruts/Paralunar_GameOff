extends Sprite

onready var anim:AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("float", -1, 0.5, false)
	anim.seek(rand_range(0.0, anim.current_animation_length), true)
	