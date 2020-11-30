extends KinematicBody2D

var gravity:float = 49

export var speed:Vector2 = Vector2.ZERO
onready var spr:Sprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	speed.x *= 0.99
	speed.y += gravity * delta
	speed = move_and_slide(speed, Vector2.UP)
	if is_on_floor():
		rotation = 0.0
		speed.x = 0.0
	else:
		rotation += delta * 10.0

func _process(_delta):
	if is_on_floor():
		var players = get_tree().get_nodes_in_group("player")
		if len(players) > 0:
			spr.flip_h = players[0].position.x < position.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
