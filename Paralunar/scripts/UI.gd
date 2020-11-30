extends CanvasLayer

var lives = []
var lifeprefab = preload("res://UI/LifeUI.tscn")

onready var life_container = $LifeContainer
onready var pause_ui = $PauseUI
onready var hurt_rect_anim = $HurtRect/AnimationPlayer

onready var gem_container = $Gems
onready var red_gem = $Gems/gem_red
onready var blue_gem = $Gems/gem_blue
onready var yellow_gem = $Gems/gem_yellow

onready var boss_lifebar = $BossBar

onready var coin_ui = $CoinContainer
onready var coin_text = $CoinContainer/CoinText

# Called when the node enters the scene tree for the first time.
func _ready():
	var gm = get_node("/root/GameManager")
	if gm != null:
		#warning-ignore: integer_division
		add_lives(int(gm.max_lives) / 3)
		#warning-ignore: return_value_discarded
		gm.connect("lives_changed", self, "change_lives")
		#warning-ignore: return_value_discarded
		gm.connect("added_lives", self, "add_lives")
		
		gem_container.visible = gm.playing

		red_gem.visible = (gm.has_red_gem or gm.red_gem_placed) and gm.playing
		blue_gem.visible = (gm.has_blue_gem or gm.blue_gem_placed) and gm.playing
		yellow_gem.visible = (gm.has_yellow_gem or gm.yellow_gem_placed) and gm.playing
		coin_ui.visible = gm.playing

func _exit_tree():
	var gm = get_node("/root/GameManager")
	if gm != null:
		gm.disconnect("lives_changed", self, "change_lives")
		gm.disconnect("added_lives", self, "add_lives")

func add_lives(var number = 1):
	for _i in range(number):
		var new_life = lifeprefab.instance()
		life_container.add_child(new_life)
		new_life.position = Vector2(len(lives) * 14, 0.0)
		lives.append(new_life)
	change_lives()

func show_hurt_hud():
	hurt_rect_anim.play("show")

func change_lives():
	var gm = get_node("/root/GameManager")
	if gm == null:
		return
	
	for i in len(lives):
		#warning-ignore: integer_division
		if i < int(gm.lives) / 3:
			lives[i].frame = 0
		#warning-ignore: integer_division
		elif i > int(gm.lives) / 3:
			lives[i].frame = 3
		else:			
			lives[i].frame = 3 + (i * 3 - gm.lives)

func change_boss_life(new_boss_life):
	boss_lifebar.set_life(new_boss_life)
	pass

func show_boss_bar(max_life=100, life=100, boss_name="BOSS"):
	boss_lifebar.max_life = max_life
	boss_lifebar.set_life(life)
	boss_lifebar.set_boss_name(boss_name)
	boss_lifebar.show()
	pass

func hide_boss_bar():
	boss_lifebar.hide()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var gm = get_node("/root/GameManager")
	if gm != null:
		if gm.playing:
			pause_ui.visible = gm.paused and get_tree().paused

			red_gem.visible = gm.has_red_gem or gm.red_gem_placed
			blue_gem.visible = gm.has_blue_gem or gm.blue_gem_placed
			yellow_gem.visible = gm.has_yellow_gem or gm.yellow_gem_placed

			coin_text.bbcode_text = "%04d" % gm.coins
		else:
			pause_ui.visible = false
			gem_container.visible = false
			coin_ui.visible = false
			
	#change_lives()
#	pass
