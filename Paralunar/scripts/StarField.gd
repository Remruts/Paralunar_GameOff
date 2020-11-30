extends Node2D

var star_prefab = preload("res://prefabs/Star.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():	

	for star_x in range(10):
		for star_y in range(6):
			var new_star = star_prefab.instance()
			add_child(new_star)
			new_star.position = Vector2(star_x * 32 + 16, star_y * 32 + 16) + Vector2(rand_range(-12, 12), rand_range(-12, 12))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
