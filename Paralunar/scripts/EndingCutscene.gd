extends Node2D

var ended = false
export var next_scene:String = "scenes/IntroCutscene.tscn"

onready var anim:AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	var gm = get_node("/root/GameManager")
	if gm != null:
		#gm.transition_to(next_scene)
		gm.playing = false
		gm.visible_cursor = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if ended:
		return
	if Input.is_action_just_pressed("start") or Input.is_action_just_pressed("shoot"):
		ended = true
		var gm = get_node("/root/GameManager")
		if gm != null:
			gm.reset_variables()
			gm.transition_to(next_scene)
	pass