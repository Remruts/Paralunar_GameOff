tool
extends TileMap

onready var shadows =  $TileMapShadows

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
		
func set_cell(x, y, tile, flip_x=false, flip_y=false, transpose=false, autotile_coord=Vector2()):
    # Write your custom logic here.
	# To call the default method:
	shadows = $TileMapShadows
	print(shadows)
	.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)
	if shadows != null:
		shadows.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)	
