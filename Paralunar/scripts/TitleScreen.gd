extends Node2D

var ended = false
export var next_scene:String = "scenes/TestScene.tscn"
onready var press_start_anim = $PressStart/AnimationPlayer
onready var fadeAnim = $AnimationPlayer

onready var new_game_text = $NewGameText
onready var continue_text = $ContinueText
onready var selection_bars = $SelectionBars

var has_saved = false

var selection = "continue"

# Called when the node enters the scene tree for the first time.
func _ready():
    var audioman = get_node("/root/AudioManager")
    if audioman != null:
        audioman.play_with_fade("Title")

    var gm = get_node("/root/GameManager")
    if gm != null:
        has_saved = (gm.get_save_metadata(0) != null)
    
    if has_saved:
        fadeAnim.play("starting_menu")
        selection_bars.global_position = continue_text.global_position
        continue_text.modulate = Color("ff9dd0")
        new_game_text.modulate = Color.white
    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    if ended:
        return
    if Input.is_action_just_pressed("move_down"):
        select("continue")
    if Input.is_action_just_pressed("move_up"):    
        select("new game")
    if Input.is_action_just_pressed("start") or Input.is_action_just_pressed("shoot"):  
        ended = true
        var audioman = get_node("/root/AudioManager")
        if audioman != null:
            audioman.stop()

        if !has_saved:
            press_start_anim.play("pressed")            
        
        fadeAnim.play("fadeOut")
    
func transition():
    var gm = get_node("/root/GameManager")
    if gm != null:
        var game_load = -1
        if selection == "continue":
            game_load = gm.load_game(gm.current_file)
        if game_load == -1 or selection == "new game":
            gm.goto_scene(next_scene)
            gm.playing = true
            gm.visible_cursor = true

func _on_NewGameText_area_entered(_area):
    select("new game")
    

func _on_ContinueText_area_entered(_area):
    select("continue")
    

func select(sel = "continue"):
    selection = sel
    if sel == "continue":
        selection_bars.global_position = continue_text.global_position
        continue_text.modulate = Color("ff9dd0")
        new_game_text.modulate = Color.white
    else:
        selection_bars.global_position = new_game_text.global_position
        new_game_text.modulate = Color("ff9dd0")
        continue_text.modulate = Color.white
