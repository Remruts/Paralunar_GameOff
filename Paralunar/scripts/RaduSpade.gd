extends "Enemy.gd"

onready var attack_timer = $AttackTimer
onready var anim = $AnimationPlayer
onready var spr = $Sprite
onready var my_body = get_node(".")
onready var my_sword = $Sprite/Sword

var red_gem_prefab = preload("res://prefabs/Gem.tscn")
var dash_effect_prefab = preload("res://prefabs/DashTrail.tscn")
var sword_prefab = preload("res://prefabs/ThrowingSword.tscn")

var state = "waiting"
var player = null

var wander_speed = 100
var dash_speed = 200.0
var current_speed = wander_speed
var direction = 1.0

var starting_point

signal life_changed(new_life)

var actions_bag = ["follow", "follow", "follow", "idle", "throwing_swords"]

export(Array, NodePath) var doors

var current_number_of_swords = 5

# Called when the node enters the scene tree for the first time.
func _ready():
    ._ready()
    var gm = get_node("/root/GameManager")
    if gm != null:
        if gm.has_red_gem or gm.red_gem_placed:
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
    if life_ratio < 0.6:
        current_number_of_swords = 7
        dash_speed = 250.0
    if life_ratio < 0.35:
        current_number_of_swords = 10
        dash_speed = 300.0

    if inactive:
        state = "waiting"
        
    #if !my_body.is_on_floor():
    #	state = "wander"
    if state == "idle":
        if my_body.is_on_floor():
            anim.play("idle")
        else:
            anim.play("jump")
    if state == "follow":
        anim.play("run")
    elif state == "throwing_swords":
        anim.play("attacking")

func _physics_process(delta):
    if inactive or dead:
        return
    
    if state != "dashing":
        speed.x *= friction
        speed.y += gravity * delta
    
    var players = get_tree().get_nodes_in_group("player")
    if len(players) > 0:
        direction = sign(players[0].global_position.x - global_position.x)
    if state == "follow":        
        current_speed = wander_speed
        if my_body.is_on_floor():
            speed.x += direction * current_speed * delta
        spr.flip_h = speed.x < 0.0
    elif state in ["idle", "intro", "waiting"]:
        current_speed = 0.0
        speed.x = 0.0		
    elif state == "throwing_swords":
        current_speed = 0.0
        speed.x = 0.0
        speed.y = 0.0
        spr.flip_h = direction < 0.0
    
    if state == "dashing":
        var collision = my_body.move_and_collide(speed * delta)
        if collision:
            speed = speed.bounce(collision.normal)
            spr.rotation = speed.angle() + PI/2.0
            spawn_dash_effect()
            play_sfx("dash")
    else:
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
    var life_ratio = life/max_life
    if life_ratio < 0.7:
        actions_bag = ["follow", "follow", "throwing_swords", "dash", "dash"]
    else:
        actions_bag = ["follow", "follow", "follow", "idle", "throwing_swords", "dash"]

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
        state = "idle"
        return
    if state in ["idle", "follow"]:
        var action = get_new_action()		
        if action == "throwing_swords":
            state = "throwing_swords"
            throw_swords(current_number_of_swords)
        elif action == "follow":
            anim.play("run")
            state = "follow"
            attack_timer.start(2.0)
        elif action == "idle":
            anim.play("idle")
            state = "idle"
            attack_timer.start(2.0)
        elif action == "dash":
            anim.play("idle")
            state = "prepare_dash"
            speed.x = 0.0
            speed.y = 0.0
            attack_timer.start(1.0)
            my_sword.visible = true				
    elif state == "throwing_swords":
        state = "idle"
        anim.play("idle")
        attack_timer.start(3.0)
    elif state == "prepare_dash":
        dash()
    elif state == "dashing":
        state = "idle"
        anim.play("idle")
        speed.x = 0.0
        speed.y = 0.0
        spr.rotation = 0.0
        my_sword.visible = false
        attack_timer.start(3.0)
        
        if life/max_life < 0.4:
            state = "throwing_swords"
            throw_swords(int(current_number_of_swords), -PI, 2*PI)

func _on_HurtTimer_timeout():
    ._on_HurtTimer_timeout()

func throw_swords(max_swords=5, start_angle=-PI, max_angle=PI):
    if dead:
        return
    
    play_sfx("wub", 0.0, 0.8)

    for i in range(max_swords):
        var sword_angle = start_angle + 0.3 + (float(i)/float(max_swords)) * max_angle
        var sword = sword_prefab.instance()
        get_tree().current_scene.call_deferred("add_child", sword)
        sword.global_position = global_position + Vector2(cos(sword_angle), sin(sword_angle)) * 32.0
        sword.auto_shoot = 2.0 + i*0.3

    attack_timer.start(max_swords * 0.3)

func die():
    if !dead:
        var gem = red_gem_prefab.instance()
        gem.gem_type = "red"
        gem.global_position = $BossArea.global_position
        get_tree().current_scene.call_deferred("add_child", gem)

        var audioman = get_node("/root/AudioManager")
        if audioman != null:
            audioman.play_with_fade("OtherArea", 1.0)
            
        var my_bullets = get_tree().get_nodes_in_group("EnemyBullet")
        for b in my_bullets:
            b.die()
        
        for door in doors:
            var real_door = get_node(door)
            if real_door != null:
                real_door.open()
            
        .die()

func dash():
    if dead:
        return
    state = "dashing"
    anim.play("jump")
    play_sfx("dash")

    var dash_direction = Vector2(1.0, 0.0)
    var players = get_tree().get_nodes_in_group("player")
    if len(players) > 0:
        dash_direction = (players[0].global_position - global_position).normalized()
    spr.rotation = dash_direction.angle() + PI/2.0
    
    my_sword.visible = true

    speed = dash_direction * dash_speed
    spawn_dash_effect()

    attack_timer.start(2.0)

func spawn_dash_effect():
    var dash_effect = dash_effect_prefab.instance()
    spr.call_deferred("add_child", dash_effect)
    dash_effect.position = Vector2(0, 12.0)

func _on_AnimationPlayer_animation_finished(anim_name):
    if anim_name == "intro":
        state = "throwing_swords"
        throw_swords()
    
func _on_BossArea_body_entered(body):
    if body.is_in_group("player"):
        if state == "waiting":
            anim.play("intro")
            state = "intro"
            var audioman = get_node("/root/AudioManager")
            if audioman != null:
                audioman.play_with_fade("RegularArea", 0)
            
            for door in doors:
                var real_door = get_node(door)
                if real_door != null:
                    real_door.close()                    

