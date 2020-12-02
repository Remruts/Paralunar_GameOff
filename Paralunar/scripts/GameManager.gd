extends Node

# 63 es toda la pantalla
var max_lives = 12
var lives = 12
var coins:int = 0

signal lives_changed
signal added_lives

var paused = false
var playing = true

var golden_ratio = 0.618033988749895
var blink_colors = [
    Color("ff0080"), #magenta
    Color("31d1a6"), #verde
    Color("ffd96a"), #amarillo
    Color("00afff"), #azul
    Color("dc5dff"), #violeta
    Color("ff9b00"), #naranja
    Color("ffffff") #blanco
]

onready var current_blink_index = rand_range(0.0, 1.0)

var current_level = "res://scenes/AreaA.tscn"

var current_camera_limits = null
var cam:Camera2D = null

var transitioning = false
var next_scene = "res://scenes/AreaB.tscn"
var player_starting_pos = Vector2.ZERO
var time_start
var current_file = 0

var game_over_timer:Timer
var hit_stun_timer:Timer

var yellow_gem_placed = false
var has_yellow_gem = false

var blue_gem_placed = false
var has_blue_gem = false

var red_gem_placed = false
var has_red_gem = false

var visible_cursor = true
var has_joystick = false

func _ready():
    time_start = OS.get_unix_time()

    pause_mode = Node.PAUSE_MODE_PROCESS
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    current_level = "res://scenes/" + get_tree().current_scene.name + ".tscn"

    game_over_timer = Timer.new()
    game_over_timer.autostart = false
    game_over_timer.one_shot = true
    game_over_timer.wait_time = 1.0
    var _meh = game_over_timer.connect("timeout", self, "game_over_timer_timeout")
    add_child(game_over_timer)

    hit_stun_timer = Timer.new()
    hit_stun_timer.autostart = false
    hit_stun_timer.one_shot = true
    hit_stun_timer.wait_time = 0.05
    _meh = hit_stun_timer.connect("timeout", self, "end_hit_stun")
    add_child(hit_stun_timer)

    if get_tree().current_scene.has_meta("Camera"):
        cam = get_tree().current_scene.get_node("Camera")
    else:
        cam = null

    if get_tree().current_scene.name == "TitleScreen":
        playing = false

    _meh = Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
    has_joystick = len(Input.get_connected_joypads()) > 0

func _process(delta):

    if has_joystick:
        visible_cursor = false

    if Input.is_action_just_pressed("ui_fullscreen"):
        OS.window_fullscreen = !OS.window_fullscreen
    if Input.is_action_just_pressed("ui_quit"):
        if OS.get_name() != "HTML5":
            get_tree().quit()
    
    if Input.is_action_just_pressed("start") and playing:
        pause_game(!paused)
    
    # lives test
    # if Input.is_action_just_pressed("ui_right"):
    # 	add_max_lives(1)
    # if Input.is_action_just_pressed("ui_left"):
    # 	lose_lives(1)
    # if Input.is_action_just_pressed("ui_down"):
    # 	recover_lives(1)

    if current_camera_limits != null and cam != null:
        #warning-ignore:narrowing_conversion
        cam.limit_left += ceil((current_camera_limits.position.x - cam.limit_left) * 5.0 * delta)
        #warning-ignore:narrowing_conversion
        cam.limit_top += ceil((current_camera_limits.position.y - cam.limit_top) * 5.0 * delta)
        #warning-ignore:narrowing_conversion
        cam.limit_right += ceil(((current_camera_limits.position.x + current_camera_limits.size.x) - cam.limit_right) * 5.0 * delta)
        #warning-ignore:narrowing_conversion
        cam.limit_bottom += ceil(((current_camera_limits.position.y + current_camera_limits.size.y) - cam.limit_bottom) * 5.0 * delta)

func pause_game(pause_state):
    if !transitioning:
        paused = pause_state
        get_tree().paused = paused

func end_hit_stun():	
    Engine.time_scale = 1.0

func hit_stun(time=0.03, scale=0.1):
    Engine.time_scale = scale
    hit_stun_timer.start(time)
    
func lose_lives(num:int=3):
    if lives <= 0:
        return
    lives = max(0, lives - num)
    emit_signal("lives_changed")    
    if get_tree().current_scene.has_node("UI"):        
        get_tree().current_scene.get_node("UI").show_hurt_hud()

func recover_lives(num:int=1):
    lives = min(lives + num, max_lives)	
    emit_signal("lives_changed")

func add_max_lives(num:int=1):
    max_lives += num*3
    emit_signal("added_lives", num)

func get_random_color():
    var new_index = int(current_blink_index * (len(blink_colors) - 1))
    current_blink_index = fmod(current_blink_index + golden_ratio, 1.0)
    return blink_colors[new_index]

func add_coins(num:int = 1):
    coins += num

func start_game():
    pass

func reset_variables():
    coins = 0
    lives = max_lives
    playing = true
    player_starting_pos = Vector2(60, 140)
    current_level = "res://scenes/AreaA.tscn"
    
    yellow_gem_placed = false
    has_yellow_gem = false
    blue_gem_placed = false
    has_blue_gem = false
    red_gem_placed = false
    has_red_gem = false
    visible_cursor = true and !has_joystick

func restart():
    game_over_timer.start()
    cam = null

func game_over_timer_timeout():
    if playing:
        playing = false
        var err = load_game(current_file)
        if err == -1:
            reset_variables()
            transition_to(current_level)

func transition_to(path, type="fadeOut", pause_game=true):
    # WIP
    transitioning = true
    if pause_game:
        get_tree().paused = true
    var trans_anim = get_tree().current_scene.get_node("UI/TransRect/AnimationPlayer")
    next_scene = path
    trans_anim.play(type)
    trans_anim.connect("animation_finished", self, "end_transition")

func end_transition(_anim_name):
    if transitioning:
        transitioning = false
        visible_cursor = true and !has_joystick
        goto_scene(next_scene)
        get_tree().paused = false
        
        yield(get_tree(), "idle_frame")		
        var players = get_tree().get_nodes_in_group("player")	
        if len(players) > 0:
            players[0].global_position = player_starting_pos

func goto_scene(path):
    #warning-ignore:return_value_discarded
    var _meh = get_tree().change_scene(path)
    current_level = path
    # para esperar a que transicione
    yield(get_tree(), "idle_frame")
    if get_tree().current_scene.has_meta("Camera"):
        cam = get_tree().current_scene.get_node("Camera")
    else:
        cam = null

func move_camera_limits(new_limits:Rect2):
    if get_tree().current_scene.has_node("Camera"):
        cam = get_tree().current_scene.get_node("Camera")
        current_camera_limits = new_limits

#####################################################
# Save/Load
#####################################################
func save_as_json(filename, save_dict):
    var f = File.new()
    #var filename = "user://save" + str(save_index) + ".bin"

    var err = f.open_encrypted_with_pass(filename, File.WRITE, OS.get_unique_id())

    if err != OK:
        print("Failed to open " + filename)
        return -1
    
    var json = to_json(save_dict)
    
    f.store_string(json)
    f.close()
    return

func load_json(filename):
    var f = File.new()
    #var filename = "user://save" + str(save_index) + ".bin"
    if not f.file_exists(filename):
        print("Couldn't find " + filename)
        return {}
    
    var err = f.open_encrypted_with_pass(filename, File.READ, OS.get_unique_id())
    if err != OK:
        print("Failed to open "+ filename +"!")
        return {}
    
    var json_str = parse_json(f.get_line())
    f.close()

    return json_str

func get_save_metadata(save_index:int):
    var filename = "user://save" + str(save_index) + ".bin"
    var save_dict = load_json(filename)
    if save_dict.empty():
        return null
    
    var elapsed = save_dict["playtime"]
    var minutes = int(elapsed) / 60
    var seconds = int(elapsed) % 60
    
    var str_elapsed = "%02d : %02d" % [minutes, seconds]

    var metadata = {
        "name" : save_dict["name"],
        "lives" : save_dict["max_lives"],
        "playtime" : str_elapsed
    }

    return metadata

func save_game(save_index: int):
    
    var filename = "user://save" + str(save_index) + ".bin"

    var save_dict = {}
    #save_dict["has_sword"] = has_sword
    save_dict["max_lives"] = max_lives
    save_dict["coins"] = coins
    save_dict["fullscreen"] = OS.window_fullscreen
    save_dict["current_level"] = current_level
    save_dict["starting_position"] = var2str(player_starting_pos)

    # GEMS!
    save_dict["yellow_gem_placed"] = yellow_gem_placed
    save_dict["has_yellow_gem"] = has_yellow_gem
    save_dict["blue_gem_placed"] = blue_gem_placed
    save_dict["has_blue_gem"] = has_blue_gem
    save_dict["red_gem_placed"] = red_gem_placed
    save_dict["has_red_gem"] = has_red_gem
        
    save_dict["playtime"] = OS.get_unix_time() - time_start
    
    save_dict["name"] = "Alex Gunn"

    save_as_json(filename, save_dict)
    
    print("Saved game on file" + str(save_index) + "!")

    return 1

func load_game(save_index: int):
    time_start = OS.get_unix_time()
    
    var filename = "user://save" + str(save_index) + ".bin"
    var save_dict = load_json(filename)

    if save_dict.empty():		
        return -1
    
    current_file = save_index	
    if save_dict.has("coins"):
        coins = save_dict["coins"]

    if save_dict.has("max_lives"):
        max_lives = save_dict["max_lives"]
    if save_dict.has("fullscreen"):    
        OS.window_fullscreen = save_dict["fullscreen"]
    if save_dict.has("current_level"):
        current_level = save_dict["current_level"]
    if save_dict.has("starting_position"):
        player_starting_pos = str2var(save_dict["starting_position"])
    
    # GEMS!
    if save_dict.has("yellow_gem_placed"):
        yellow_gem_placed = save_dict["yellow_gem_placed"]
    if save_dict.has("has_yellow_gem"):
        has_yellow_gem = save_dict["has_yellow_gem"]
    if save_dict.has("blue_gem_placed"):
        blue_gem_placed = save_dict["blue_gem_placed"]
    if save_dict.has("has_blue_gem"):
        has_blue_gem = save_dict["has_blue_gem"]
    if save_dict.has("red_gem_placed"):
        red_gem_placed = save_dict["red_gem_placed"]
    if save_dict.has("has_red_gem"):
        has_red_gem = save_dict["has_red_gem"]

    if save_dict.has("playtime"):
        time_start = OS.get_unix_time() - save_dict["playtime"]
        
    transition_to(current_level)
    playing = true
    visible_cursor = true and !has_joystick
    lives = max_lives
    
    return 1

func delete_save(save_index: int):
    var filename = "user://save" + str(save_index) + ".bin"
    var dir = Directory.new()
    dir.remove(filename)

func get_gem(gem_color):
    if gem_color == "red":
        has_red_gem = true
    elif gem_color == "blue":
        has_blue_gem = true
    elif gem_color == "yellow":
        has_yellow_gem = true
    
func place_gem(gem_color):
    if gem_color == "red":
        red_gem_placed = true
        has_red_gem = false
    elif gem_color == "blue":
        blue_gem_placed = true
        has_blue_gem = false
    elif gem_color == "yellow":
        yellow_gem_placed = true
        has_yellow_gem = false

func _on_joy_connection_changed(device_id, connected):
    if connected and device_id == 0:
        has_joystick = true
    else:
        has_joystick = false