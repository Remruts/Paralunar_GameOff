extends Node2D

var ended = false
export var next_scene:String = "scenes/AreaA.tscn"

onready var anim:AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	var gm = get_node("/root/GameManager")
	if gm != null:
		#gm.transition_to(next_scene)
		gm.playing = false
		gm.visible_cursor = false
	var audioman = get_node("/root/AudioManager")
	if audioman != null:
		audioman.play_with_fade("Castle", 0.0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if ended:
		return
	if Input.is_action_just_pressed("start") or Input.is_action_just_pressed("shoot"):
		go_to_next_scene()
	pass

func go_to_next_scene():
	var audioman = get_node("/root/AudioManager")
	if audioman != null:
		audioman.stop()
	ended = true
	var gm = get_node("/root/GameManager")
	if gm != null:
		gm.goto_scene(next_scene)
		gm.playing = true
		gm.visible_cursor = true

func _on_AnimationPlayer_animation_finished(anim_name):
	go_to_next_scene()
