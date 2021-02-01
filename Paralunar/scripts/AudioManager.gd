extends AudioStreamPlayer

var jukebox = {
    "Title": preload("res://music/paralunar_title.ogg"),
    "Castle": preload("res://music/waiting.ogg"),
    "RegularArea": preload("res://music/paralunar_01.ogg"),
    "OtherArea": preload("res://music/Inkorporeal.ogg"),
    "FinalBoss": preload("res://music/paralunar_Boss.ogg")
}

var sfxbox = {
    "scream": preload("res://audio/scream0.wav"),
    "player_shot": preload("res://audio/alex_shoot.wav"),
    "dash": preload("res://audio/firethrow.wav"),
    "enemy_explosion": preload("res://audio/clank2.wav"),
    "coin": preload("res://audio/coin.wav"),
    "bullet_hit": preload("res://audio/alex_shoot.wav"),
    "player_die": preload("res://audio/die.wav"),
    "player_hurt": preload("res://audio/hit1.wav"),
    "gem_grab": preload("res://audio/key_grab.wav"),
    "add_gem": preload("res://audio/thump.wav"),
    "door_open": preload("res://audio/fanfare.wav"),
    "save": preload("res://audio/puzzle_finished.wav"),
    "spores": preload("res://audio/snif.wav"),
    "wub": preload("res://audio/wub.wav"),
    "throw_sword": preload("res://audio/burst.wav"),
    "teleport": preload("res://audio/firethrow.wav"),
    "homing_bullet_spawn": preload("res://audio/wub.wav"),
    "homing_bullet_move": preload("res://audio/dialogue_next2.wav"),
    "follow_bullet_spawn": preload("res://audio/shoot.wav"),
    "enemy_bullet": preload("res://audio/bubble.wav"),	
    "follow_bullet_follow": preload("res://audio/burst.wav"),
    "collision": preload("res://audio/text_advance.wav"),
}

var next_stream = stream
var fading = 0
var fade_time = 0.5

export var trailer_mode:bool = false

onready var tween_transition = get_node("Tween")
onready var sfxplayer = get_node("sfxplayer")
var tween_type = Tween.TRANS_EXPO

var last_song = "Title"
var currently_playing = ""

var global_music_volume = 8
var global_sound_volume = 8

var current_music_volume = 1.0
var current_sound_volume = 1.0

var sfx_prefab = preload("res://prefabs/SFXOneShot.tscn")

func _ready():
    pause_mode = Node.PAUSE_MODE_PROCESS
    pass # Replace with function body.

func play_with_fade(new_stream:String, new_fade_time:float = 0):
    if trailer_mode:
        return
    if not (new_stream in jukebox.keys()):
        return
    if new_fade_time == 0:
        if currently_playing != new_stream:
            stream = jukebox[new_stream]
            last_song = currently_playing
            currently_playing = new_stream
            play()
        return
    
    fade_time = new_fade_time
    next_stream = jukebox[new_stream]
    if not playing:
        volume_db = -80
        tween_transition.interpolate_property(self, "current_music_volume", 0.0, 1.0, fade_time, tween_type, Tween.EASE_OUT, 0)
        fading = 2
        stream = next_stream
        if currently_playing != new_stream:
            last_song = currently_playing
            currently_playing = new_stream
        play()
    else:
        if currently_playing != new_stream:
            fading = 1
            tween_transition.interpolate_property(self, "current_music_volume", 1, 0.0, fade_time, tween_type, Tween.EASE_OUT, 0)
            last_song = currently_playing
            currently_playing = new_stream
            tween_transition.start()

# warning-ignore:unused_argument
func _process(delta):
    volume_db = get_music_db()
    sfxplayer.volume_db = get_sfx_db()
        
func increase_sound_volume():
    global_sound_volume = min(global_sound_volume + 1, 10)
func increase_music_volume():
    global_music_volume = min(global_music_volume + 1, 10)
func decrease_sound_volume():
    global_sound_volume = max(global_sound_volume - 1, 0)
func decrease_music_volume():
    global_music_volume = max(global_music_volume - 1, 0)

func get_sfx_db(scale=1.0):
    var sound_vol = current_sound_volume * scale * (global_sound_volume / 10.0)
    return (20.0 * log(sound_vol)) if sound_vol > 0.0 else -80.0

func get_music_db():
    var music_vol = current_music_volume * (global_music_volume / 10.0)
    return (20.0 * log(music_vol)) if music_vol > 0.0 else -80.0

func play_sfx(name, random_pitch_offset=0.05, volume_scale=1.0):
    if sfxbox.has(name):
        var sfx = sfx_prefab.instance()
        sfx.sound_name = name
        sfx.random_pitch_offset = random_pitch_offset
        sfx.volume_scale = volume_scale
        add_child(sfx)
        #sfxplayer.stream = sfxbox[name]
        #sfxplayer.play()
    else:
        print("Missing " + name + " audio")

func fadeOut():
    fading = 1
    tween_transition.interpolate_property(self, "current_music_volume", 1, 0.0, fade_time, tween_type, Tween.EASE_IN, 0)
    next_stream = null

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_Tween_tween_completed(object, key):
    if fading == 1:
        stop()
        volume_db = -80
        stream = next_stream
        if stream != null:
            play()
        fading = 2
        tween_transition.interpolate_property(self, "current_music_volume", 0.0, 1.0, fade_time, tween_type, Tween.EASE_IN, 0)
        tween_transition.start()
    if fading == 2:
        fading = 0
    pass # Replace with function body.
