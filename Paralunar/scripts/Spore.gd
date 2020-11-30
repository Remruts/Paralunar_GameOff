extends Sprite

var speed = Vector2.ZERO
var dead = false
onready var death_timer:Timer = $DeathTimer
onready var col = $Area2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	rotation = rand_range(0.0, 2 * PI)
	pass # Replace with function body.

func die():
	if !dead:
		dead = true
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += speed * delta
	speed.x += rand_range(-30.0, 30.0) * delta
	speed.y += rand_range(-30.0, 30.0) * delta
	speed *= 0.98
	rotation += 0.1 * delta

	if death_timer.time_left <= 0.5:
		modulate = Color("171717").linear_interpolate(Color.white, death_timer.time_left * 2.0)
		scale = Vector2.ONE * (death_timer.time_left + 0.5)
		col.disabled = true			

func _on_DeathTimer_timeout():
	die()

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.get_hurt(1)
