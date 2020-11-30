tool
extends Area2D

export var new_limits:Rect2 = Rect2(0, 0, 320, 180)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	if Engine.editor_hint:
		update()

func _draw():
	if Engine.editor_hint:
		var new_rect = new_limits
		new_rect.position -= global_position
		draw_rect(new_rect, Color("a4d6d741"), false, 1.0, false)

func _on_CameraArea_body_entered(body):
	if not Engine.editor_hint:
		if body.is_in_group("player"):
			var gm = get_node("/root/GameManager")
			if gm != null:
				gm.move_camera_limits(new_limits)	
	