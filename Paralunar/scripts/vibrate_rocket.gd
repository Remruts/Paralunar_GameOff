extends Node2D

onready var rocket = $Rocket
onready var rocket_fire = $RocketFire

var rocket_start_pos
var fire_start_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	rocket_start_pos = rocket.position
	fire_start_pos = rocket_fire.position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	rocket.position = rocket_start_pos + Vector2(rand_range(-1, 1), rand_range(-1, 1))
	rocket_fire.position = fire_start_pos + Vector2(rand_range(-1, 1), rand_range(-3, 3))
	pass
