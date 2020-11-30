extends "Enemy.gd"

var state = "follow"
var player = null
var offset_radius = 128.0
var offset_angle = 0.0

var follow_speed = 50
var wander_speed = 20
var current_speed = wander_speed

onready var wander_timer = $WanderTimer
onready var spr = self
var target
var starting_point

# Called when the node enters the scene tree for the first time.
func _ready():
    ._ready()
    material = material.duplicate()
    gravity = 0.0
    friction = 0.99
    starting_point = position
    target = starting_point
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    ._process(delta)

    if inactive:
        state = "wander"

    speed *= friction
    
    offset_angle += delta
    if offset_angle > 2 * PI:
        offset_angle -= 2*PI
    
    if hurt:
        material.set_shader_param("blink_magnitude", 1.0)
    else:
        material.set_shader_param("blink_magnitude", 0.0)                    
        if state == "follow":
            current_speed = follow_speed
            if player != null:
                target = player.position
                offset_radius = ((sin(OS.get_ticks_msec() + 1.0)) / 2.0) * 32.0
            else:
                state = "wander"
        elif state == "wander":
            offset_radius = 128.0
            current_speed = wander_speed
            target = starting_point
            offset_angle += rand_range(-PI, PI) * 5.0 * delta
        elif state == "spawned":
            current_speed = 300.0
        
        if state != "spawned":
            speed += (target + Vector2(cos(offset_angle), sin(offset_angle)) * offset_radius - position).normalized() * delta * current_speed
    
        spr.flip_h = speed.x > 0.0

    if speed.length() > current_speed:
        speed = speed.normalized() * current_speed
        
    position += speed * delta

func get_hurt(damage, knockback_direction = Vector2.ZERO):
    if inactive:
        return
    .get_hurt(damage, knockback_direction)
    speed = knockback_direction
    current_speed = knockback_direction.length()

func _on_Area2D_body_entered(body):
    if inactive:
        return
    if body.is_in_group("player_bullet"):
        var normal = body.speed.normalized()
        body.get_hit(body.position - normal * 7.0)	
        var knockback_direction = normal.normalized() * body.knockback_strength
        get_hurt(body.damage, knockback_direction)

func _on_FollowArea_body_entered(body):
    if body.is_in_group("player"):
        state = "follow"
        player = body
        offset_angle = rand_range(0.0, 2 * PI)
        wander_timer.stop()

func _on_FollowArea_body_exited(body):
    if body.is_in_group("player"):
        wander_timer.start()

func _on_WanderTimer_timeout():
    if state in ["follow", "spawned"]:
        state = "wander"

func _on_HurtTimer_timeout():
    ._on_HurtTimer_timeout()	
