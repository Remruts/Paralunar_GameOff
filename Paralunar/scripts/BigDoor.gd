extends Area2D

onready var medallion_area = $Medallion/MedallionArea
onready var anim = $AnimationPlayer
onready var yellow_gem = $Medallion/YellowGem
onready var red_gem = $Medallion/RedGem
onready var blue_gem = $Medallion/BlueGem

var opened = false
var finished = false
export var new_scene:String = "FinalBoss.tscn"
export var new_position:Vector2 = Vector2(64, 152)

var has_blue_gem = false
var has_red_gem = false
var has_yellow_gem = false

func _ready():
	var gm = get_node("/root/GameManager")
	if gm != null:
		if gm.yellow_gem_placed:
			add_gem("yellow")
		if gm.red_gem_placed:
			add_gem("red")
		if gm.blue_gem_placed:
			add_gem("blue")

func open():
	print("has been opened")
	opened = true

func add_gem(gem_type):
	var gm = get_node("/root/GameManager")
	if gm != null:
		if gem_type == "yellow":
			has_yellow_gem = true
			gm.place_gem("yellow")
			yellow_gem.visible = true
		elif gem_type == "red":
			has_red_gem = true
			gm.place_gem("red")
			red_gem.visible = true
		elif gem_type == "blue":
			has_blue_gem = true
			gm.place_gem("blue")
			blue_gem.visible = true

#func _process(delta):
#	pass

func _on_BigDoor_body_entered(body):
	if finished:
		return
	if body.is_in_group("player"):
		var gm = get_node("/root/GameManager")
		if opened:           
			finished = true
			if gm != null:
				print("Transitioning to... " + "res://scenes/" + new_scene)
				gm.transition_to("res://scenes/" + new_scene)
				gm.player_starting_pos = new_position
		else:
			var gem_placed = false
			if gm.has_yellow_gem:
				if !has_yellow_gem:
					add_gem("yellow")
					gem_placed = true
			if gm.has_red_gem:
				if !has_red_gem:
					add_gem("red")
					gem_placed = true
			if gm.has_blue_gem:
				if !has_blue_gem:
					add_gem("blue")
					gem_placed = true
			if gem_placed:
				var audioman = get_node("/root/AudioManager")
				if audioman != null:
					audioman.play_sfx("add_gem", 0.0)
	pass

func _on_MedallionArea_body_entered(body):	
	if body.is_in_group("player_bullet"):
		var normal = body.speed.normalized()
		body.get_hit(body.global_position - normal * 7.0)            
		
		if anim.current_animation != "open" and !opened and has_yellow_gem and has_blue_gem and has_red_gem:
			medallion_area.set_deferred("monitoring", false)
			medallion_area.set_deferred("monitorable", false)
			anim.play("open")
			var audioman = get_node("/root/AudioManager")
			if audioman != null:
				audioman.play_sfx("door_open", 0.0)
