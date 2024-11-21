extends Container

var midground_scene_edge = 1536

@export var midground_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_midground_crossed():
	get_child(0).queue_free()
	
func on_midground_edged():
	var midground = midground_scene.instantiate()
	add_child(midground)
	midground.crossed.connect(on_midground_crossed.bind())
	midground.edged.connect(on_midground_edged.bind())
	midground.position.x = get_child(0).position.x + midground_scene_edge
	

func start_background(state):
	var midground = midground_scene.instantiate()
	if state == 'flow':
		midground.crossed.connect(on_midground_crossed.bind())
		midground.edged.connect(on_midground_edged.bind())
		add_child(midground)
	elif state == 'static':
		midground.in_play = false
		add_child(midground)
