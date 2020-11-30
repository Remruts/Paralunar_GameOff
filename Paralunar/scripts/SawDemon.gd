extends "Enemy.gd"
var my_path

onready var saw = $Saw

export var path_speed:float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	material = material.duplicate()
	gravity = 0.0
	friction = 1.0
	
	my_path = get_parent()
	pass # Replace with function body.


func get_hurt(damage, knockback_direction = Vector2.ZERO):
	if inactive:
		return
	.get_hurt(damage, knockback_direction)
	
func _on_HurtTimer_timeout():
	._on_HurtTimer_timeout()	

func _on_Area2D_body_entered(body):	
	if inactive:
		return
	if body.is_in_group("player_bullet"):
		var normal = body.speed.normalized()
		body.get_hit(body.position - normal * 7.0)	
		var knockback_direction = normal.normalized() * body.knockback_strength
		get_hurt(body.damage, knockback_direction)

func _process(delta):
	._process(delta)

	my_path.offset += path_speed * delta
	saw.rotation += (path_speed * delta) / PI
