extends TextureRect

signal crossed
signal edged

var background_width = 1536

@export var foreground_speed = -10


var background_crossed = false
var background_edged = false

var in_play = true
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if in_play:
		position.x += foreground_speed
		if position.x + background_width < 0 and background_crossed == false:
			crossed.emit()
			background_crossed = true
		
		if position.x < -380 and background_edged == false:
			edged.emit()
			background_edged = true
