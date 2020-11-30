extends Sprite

export var damage = 3
var dead = false

func die():
    if !dead:
        dead = true
        queue_free()

func _ready():
    pass # Replace with function body.
