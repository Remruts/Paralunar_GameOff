extends "Enemy.gd"

onready var anim:AnimationPlayer = $AnimationPlayer
onready var hurt_area:Area2D = $Area2D

var blue_gem_prefab = preload("res://prefabs/Gem.tscn")
var direct_bullet_prefab = preload("res://prefabs/EnemyBullet.tscn")
#var follow_bullet_prefab = preload("res://prefabs/FollowBullet.tscn")
#var homing_bullet_prefab = preload("res://prefabs/HomingBullet.tscn")

export(Array, NodePath) var doors

var state = "waiting"
var player = null

var current_speed = 20.0

onready var attack_timer = $AttackTimer
onready var spr = self
var target
var starting_point

signal life_changed(new_life)

var max_direct_shots = 5
var direct_shots_rate = 0.5
var disappear_rate = 2.0

var action_options = [
    "disappear",
    "direct_shot",
]
var actions_bag = []

var valid_positions = [
    Vector2(152, 688),
    Vector2(56, 648),
    Vector2(248, 648),
    Vector2(152, 600),
    Vector2(152, 712)    
]
var positions_bag = valid_positions.duplicate(true)

var shoot_counter:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    ._ready() 
    var gm = get_node("/root/GameManager")
    if gm != null:
        if gm.has_blue_gem or gm.blue_gem_placed:
            queue_free()
    material = material.duplicate()
    gravity = 0.0
    friction = 0.99
    starting_point = position
    target = starting_point

    attack_timer.start()

    var ui = get_tree().current_scene.get_node("UI")
    self.connect("life_changed", ui, "change_boss_life")
    
func build_actions_bag():
    if max_life <= 0.0:
        return
    
    actions_bag = ["disappear", "disappear", "direct_shot", "direct_shot"]
    
    if life/max_life < 0.45:		
        max_direct_shots = 15
        direct_shots_rate = 0.15		
        disappear_rate = 0.5
        actions_bag = ["disappear", "disappear", "direct_shot", "rotated_shot"]
    elif life/max_life < 0.75:
        max_direct_shots = 7
        direct_shots_rate = 0.35
        disappear_rate = 1.0

func get_new_action():
    if len(actions_bag) == 0:
        build_actions_bag()
    
    var index = randi() % len(actions_bag)
    var action = actions_bag[index]
    actions_bag.remove(index)

    return action

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    ._process(delta)
    if dead:
        return
    
    #if Input.is_action_just_pressed("shoot"):
    #	disappear()

    if inactive:
        state = "waiting"

    speed *= friction
        
    if hurt:
        material.set_shader_param("blink_magnitude", 1.0)
    else:
        material.set_shader_param("blink_magnitude", 0.0)
    
    if state == "idle":
        speed += (target + Vector2(rand_range(-10, 10), rand_range(-10, 10)) - position).normalized() * current_speed * delta

    if speed.length() > current_speed:
        speed = speed.normalized() * current_speed
        
    position += speed * delta

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

func _on_AttackTimer_timeout():
    if dead:
        return
    if state == "idle":
        if anim.current_animation == "idle":
            shoot_counter = 0
            var current_action = get_new_action()
            if current_action == "disappear":
                attack_timer.start(disappear_rate)
                disappear()
            elif current_action == "direct_shot":
                state = "direct_shot"
            elif current_action == "rotated_shot":
                state = "rotated_shot"
    elif state == "direct_shot":
        if shoot_counter < max_direct_shots:
            shoot_direct_bullet()
            attack_timer.start(direct_shots_rate)
            shoot_counter += 1
        else:	
            state = "idle"
            attack_timer.start(disappear_rate)
            disappear()
    elif state == "rotated_shot":
        if shoot_counter < max_direct_shots * 2.0:
            shoot_rotated_bullet()
            attack_timer.start(direct_shots_rate/2.0)
            shoot_counter += 1
        else:	
            state = "idle"
            attack_timer.start(disappear_rate)
            disappear()

func shoot_rotated_bullet():
    if dead:
        return
    
    var bullet = direct_bullet_prefab.instance()
    get_tree().current_scene.call_deferred("add_child", bullet)	
    bullet.global_position = global_position
    var bullet_angle = (float(shoot_counter) / float(max_direct_shots)) * 2.0 * PI
    
    bullet.speed = Vector2(cos(bullet_angle), sin(bullet_angle)) * 60.0
    
    for _i in range(rand_range(3, 5)):
        var sparkle = sparkle_prefab.instance()
        get_tree().current_scene.add_child(sparkle)	
        sparkle.global_position = global_position + Vector2(rand_range(-5.0, 5.0),rand_range(-5.0, 5.0))

func shoot_direct_bullet():
    if dead:
        return

    var bullet = direct_bullet_prefab.instance()
    get_tree().current_scene.call_deferred("add_child", bullet)	
    bullet.global_position = global_position
    var players = get_tree().get_nodes_in_group("player")
    if len(players) > 0:	
        bullet.speed = (players[0].global_position + Vector2(0.0, 30.0 + shoot_counter * -10.0) - global_position).normalized() * 60.0
    else:
        bullet.speed = Vector2(50, 0)
    
    for _i in range(rand_range(3, 5)):
        var sparkle = sparkle_prefab.instance()
        get_tree().current_scene.add_child(sparkle)	
        sparkle.global_position = global_position + Vector2(rand_range(-5.0, 5.0),rand_range(-5.0, 5.0))

func _on_HurtTimer_timeout():
    ._on_HurtTimer_timeout()	

func die():
    if !dead:
        var gem = blue_gem_prefab.instance()
        gem.gem_type = "blue"
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
        
        
func disappear():
    if dead:
        return

    play_sfx("teleport")

    hurt_area.set_deferred("monitorable", false)
    hurt_area.set_deferred("monitoring", false)
    anim.play("disappear")
    
    if len(positions_bag) == 0:
        positions_bag = valid_positions.duplicate(true)
    var i = rand_range(0, len(positions_bag))
    target = positions_bag[i]
    positions_bag.remove(i)
    # FIXME: Debería chequear que no aparezca encima de le jugadore
    
func _on_AnimationPlayer_animation_finished(anim_name):
    if anim_name == "die":
        queue_free()
    elif anim_name == "appear":
        state = "idle"
        anim.play("idle")
    elif anim_name == "disappear":
        anim.play("appear")
        play_sfx("teleport")
        hurt_area.set_deferred("monitorable", true)
        hurt_area.set_deferred("monitoring", true)
        position = target
    pass


func _on_BossArea_body_entered(body):
    if body.is_in_group("player"):
        if state == "waiting":            
            disappear()
            attack_timer.start(disappear_rate)
            var audioman = get_node("/root/AudioManager")
            if audioman != null:
                audioman.play_with_fade("RegularArea", 0)
            
            for door in doors:
                var real_door = get_node(door)
                if real_door != null:
                    real_door.close()     