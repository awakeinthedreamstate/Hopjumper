extends Container

var foreground_scene_edge = 1536

@export var foreground_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 4


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_foreground_crossed():
	get_child(0).queue_free()
	
func on_foreground_edged():
	var foreground = foreground_scene.instantiate()
	add_child(foreground)
	foreground.crossed.connect(on_foreground_crossed.bind())
	foreground.edged.connect(on_foreground_edged.bind())
	foreground.position.x = get_child(0).position.x + foreground_scene_edge
	

func start_background(state):
	var foreground = foreground_scene.instantiate()
	if state == 'flow':
		foreground.crossed.connect(on_foreground_crossed.bind())
		foreground.edged.connect(on_foreground_edged.bind())
		add_child(foreground)
	elif state == 'static':
		foreground.in_play = false
		add_child(foreground)
