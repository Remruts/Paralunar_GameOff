extends StaticBody2D

onready var shape = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func close():
    shape.set_deferred("disabled", false)

func open():
    shape.set_deferred("disabled", true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
