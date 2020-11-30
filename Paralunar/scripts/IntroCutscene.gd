extends Node2D

var ended = false
export var next_scene:String = "scenes/TitleScreen.tscn"

onready var music:AudioStreamPlayer = $Music
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
			gm.transition_to(next_scene)
			#gm.playing = true
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "frame1":
		anim.play("frame2")
	elif anim_name == "frame2":
		anim.play("frame3")
	elif anim_name == "frame3":
		anim.play("frame4")
	elif anim_name == "frame4":
		anim.play("frame5")
	elif anim_name == "frame5":
		anim.play("frame6")
	elif anim_name == "frame6":
		anim.play("frame7")
	elif anim_name == "frame7":
		anim.play("frame8")
	else:
		var gm = get_node("/root/GameManager")
		if gm != null:
			gm.goto_scene(next_scene)

func start_music():
	music.play()