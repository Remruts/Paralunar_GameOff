extends Area2D

export var new_scene:String = "AreaB.tscn"
export var new_position:Vector2 = Vector2.ZERO
var transitioned = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	pass

func _on_CameraArea_body_entered(body):
	if transitioned:
		return
	if body.is_in_group("player"):
		transitioned = true
		var gm = get_node("/root/GameManager")
		if gm != null:
			print("Transitioning to... " + "res://scenes/" + new_scene)
			gm.transition_to("res://scenes/" + new_scene)
			gm.player_starting_pos = new_position
	
