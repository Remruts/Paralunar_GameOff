tool
extends Area2D

onready var shape:CollisionShape2D = $CollisionShape2D
var my_boss = null

var starting_pos:Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
    my_boss = get_parent()
    starting_pos = global_position
    pass # Replace with function body.

func _draw():
    if Engine.editor_hint:
        #ignore-warning:unsafe_property_access
        draw_rect(Rect2(shape.position - shape.shape.extents, shape.shape.extents * 2.0), Color.red, false)
    else:
        pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    if Engine.editor_hint:
        update()
    else:
        global_position = starting_pos
    
func _on_BossArea_body_entered(body):
    if body.is_in_group("player"):
        if my_boss != null:
            var ui = get_tree().current_scene.get_node("UI")
            if ui != null:
                ui.show_boss_bar(my_boss.max_life, my_boss.life, my_boss.enemy_name)
        

func _on_BossArea_body_exited(body):
    if body.is_in_group("player"):
        var ui = get_tree().current_scene.get_node("UI")
        if ui != null:
            ui.hide_boss_bar()
        