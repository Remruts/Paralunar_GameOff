extends "Enemy.gd"

onready var attack_timer = $AttackTimer
onready var anim = $AnimationPlayer
onready var spr = $Sprite
onready var my_body = get_node(".")

var yellow_gem_prefab = preload("res://prefabs/Gem.tscn")
var dash_effect_prefab = preload("res://prefabs/DashTrail.tscn")
var sword_prefab = preload("res://prefabs/ThrowingSword.tscn")
var ghost_prefab = preload("res://prefabs/Ghost.tscn")

var state = "waiting"
var player = null

var wander_speed = 300
var current_speed = wander_speed
var direction = 1.0

var starting_point

signal life_changed(new_life)

var actions_bag = ["follow", "follow", "follow", "spawn_ghost", "spawn_ghost"]

export(Array, NodePath) var doors

var ghost_number = 1

# Called when the node enters the scene tree for the first time.
func _ready():
    ._ready()
    var gm = get_node("/root/GameManager")
    if gm != null:
        if gm.has_yellow_gem or gm.yellow_gem_placed:
            queue_free()
            
    material = material.duplicate()
    gravity = 49.0
    friction = 0.98
    starting_point = position
    direction = 1.0 if rand_range(0.0, 1.0) > 0.5 else -1.0

    var ui = get_tree().current_scene.get_node("UI")
    self.connect("life_changed", ui, "change_boss_life")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    ._process(delta)
    
    var life_ratio = life/max_life
    if life_ratio < 0.8:
        ghost_number = 2
    if life_ratio < 0.5:
        ghost_number = 3
    if life_ratio < 0.3:
        ghost_number = 4
        
    if inactive:
        state = "waiting"
        
    #if !my_body.is_on_floor():
    #	state = "wander"
    if state == "idle":        
        anim.play("idle")
    if state == "follow":
        anim.play("idle")
    elif state == "throwing_swords":
        anim.play("attacking")

func _physics_process(delta):
    if inactive or dead:
        return
        
    speed.x *= friction
    speed.y += gravity * delta
    
    var players = get_tree().get_nodes_in_group("player")
    if len(players) > 0:
        direction = sign(players[0].global_position.x - global_position.x)
    if state == "follow":        
        current_speed = wander_speed
        if my_body.is_on_floor():
            speed.x += direction * current_speed * delta
        spr.flip_h = speed.x > 0.0
    elif state in ["idle", "waiting"]:
        current_speed = 0.0
        speed.x = 0.0		
    elif state == "spawn_ghost":
        current_speed = 0.0
        speed.x = 0.0
        speed.y = 0.0
        spr.flip_h = direction > 0.0
    
    speed = my_body.move_and_slide(speed, Vector2.UP)
    
    if my_body.is_on_wall():
        direction = -direction

func get_hurt(damage, knockback_direction = Vector2.ZERO):
    if inactive or dead:
        return
    .get_hurt(damage, knockback_direction)
    emit_signal("life_changed", life)

func _on_Area2D_body_entered(body):
    if inactive or dead:
        return
    if body.is_in_group("player_bullet"):
        var normal = body.speed.normalized()
        body.get_hit(body.position - normal * 7.0)	
        var knockback_direction = normal.normalized() * body.knockback_strength
        get_hurt(body.damage, knockback_direction)

func build_actions_bag():
    #var life_ratio = life/max_life
    actions_bag = ["follow", "follow", "follow", "spawn_ghost", "spawn_ghost"]    

func get_new_action():
    if len(actions_bag) == 0:
        build_actions_bag()
    
    var index = randi() % len(actions_bag)
    var action = actions_bag[index]
    actions_bag.remove(index)

    return action

func _on_AttackTimer_timeout():
    if dead:
        return
    if inactive:
        anim.play("idle")
        state = "waiting"
        return
    if state in ["idle", "follow"]:
        var action = get_new_action()
        if action == "spawn_ghost":
            state = "spawn_ghost"
            anim.play("open_mouth")
        elif action == "follow":
            anim.play("idle")
            state = "follow"
            attack_timer.start(2.0)
        elif action == "idle":
            anim.play("idle")
            state = "idle"
            attack_timer.start(2.0)

func _on_HurtTimer_timeout():
    ._on_HurtTimer_timeout()

func spawn_ghosts():
    if dead:
        return
    
    var my_ghosts = get_tree().get_nodes_in_group("moncat_ghosts")
    if len(my_ghosts) >= 12:
        return
    
    var max_ghosts = ghost_number
    if len(my_ghosts) + max_ghosts > 12:
        max_ghosts -= len(my_ghosts)

    play_sfx("wub", 0.0, 0.8)

    for _i in range(max_ghosts):
        var ghost = ghost_prefab.instance()
        get_tree().current_scene.call_deferred("add_child", ghost)
        ghost.global_position = global_position
        ghost.add_to_group("moncat_ghosts")
        ghost.state = "spawned"
        ghost.speed.y = rand_range(-100, -200)
        ghost.speed.x = rand_range(-150, 150)
        ghost.coins_to_spawn = 0

func die():
    if !dead:
        var gem = yellow_gem_prefab.instance()
        gem.gem_type = "yellow"
        gem.global_position = $BossArea.global_position
        get_tree().current_scene.call_deferred("add_child", gem)

        var audioman = get_node("/root/AudioManager")
        if audioman != null:
            audioman.play_with_fade("OtherArea", 1.0)
            
        var my_ghosts = get_tree().get_nodes_in_group("moncat_ghosts")
        for b in my_ghosts:
            b.die()
        
        for door in doors:
            var real_door = get_node(door)
            if real_door != null:
                real_door.open()
            
        .die()

func _on_AnimationPlayer_animation_finished(anim_name):
    if anim_name == "open_mouth":
        state = "idle"
        anim.play("idle")
        attack_timer.start(2.0)
    
func _on_BossArea_body_entered(body):
    if body.is_in_group("player"):
        if state == "waiting":
            anim.play("open_mouth")
            state = "spawn_ghost"
            var audioman = get_node("/root/AudioManager")
            if audioman != null:
                audioman.play_with_fade("RegularArea", 0)
            
            for door in doors:
                var real_door = get_node(door)
                if real_door != null:
                    real_door.close()                    

