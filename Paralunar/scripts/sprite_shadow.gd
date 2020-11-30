tool
extends Sprite

onready var parent = get_parent()
export var starting_position:Vector2 = Vector2(2, 2)

# Called when the node enters the scene tree for the first time.
func _ready():
	starting_position = position
	update_shadow()

func update_shadow():
	if parent == null:
		return
	texture = parent.texture
	vframes = parent.vframes
	hframes = parent.hframes
	frame = parent.frame
	offset = parent.offset
	centered = parent.centered
	flip_h = parent.flip_h
	flip_v = parent.flip_v
	global_position = parent.global_position + starting_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_shadow()
