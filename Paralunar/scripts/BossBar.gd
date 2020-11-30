tool
extends Sprite

onready var anim:AnimationPlayer = $AnimationPlayer
onready var boss_text:RichTextLabel = $BossName
onready var yellow_timer:Timer = $YellowTimer

onready var red_part = $red
onready var yellow_part = $yellow

export var current_life = 100.0
export var max_life = 100.0

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	red_part.value = current_life
	yellow_part.value = current_life - 0.5
	pass # Replace with function body.

func _process(delta):
	red_part.value = current_life
	if yellow_timer.is_stopped():
		if abs(current_life - yellow_part.value) > 0.01:
			yellow_part.value += sign((current_life - 0.5) - yellow_part.value) * delta * 10.0
		else:
			yellow_part.value = current_life - 0.5

func set_boss_name(boss_name):
	boss_text.bbcode_text = "[center]" + boss_name + "[/center]"

func show():
	if !visible:
		anim.play("show")

func hide():
	if visible:
		anim.play("hide")

func set_life(new_life):
	current_life = (new_life / max_life) * 100.0
	yellow_timer.start()



