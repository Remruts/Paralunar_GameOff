tool
extends Node2D

onready var spr = $ChandelierBody
export (Texture) var chain_texture

# Called when the node enters the scene tree for the first time.
func _ready():	
	update()
	pass # Replace with function body.

func _draw():
	if chain_texture != null:
		var links = int(spr.position.y / 4)
		for i in range(links):			
			draw_texture(chain_texture, Vector2(0, i*4 + 2), Color("bf210052"))
			draw_texture(chain_texture, Vector2(-2, i*4), Color("c8af64"))
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Engine.editor_hint:
		spr.position = spr.position.snapped(Vector2(1, 4))
		spr.position.x = 0.0
		update()
	pass
