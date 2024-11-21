extends Node2D

signal cleared

@export var obstacle_speed = -15
const obstacle_gap = 150
var dy_value = true
var in_play = true

# Called when the node enters the scene tree for the first time.
func _ready():
	dy_value = false if randf() > 0.5 else dy_value


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if in_play:
		$ObstacleDown.position.x += obstacle_speed
		$ObstacleUp.position.x += obstacle_speed
		$ScoreCheck.position.x += obstacle_speed

func spawn(variation): 
	variation = -variation if dy_value == false else variation
	$ObstacleUp.position.y += variation
	$ObstacleDown.position.y += variation
	$ScoreCheck.position.y += variation

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

#This function checks if the player has passed through the area2d and sends a signal
func _on_score_check_area_exited(area):
	await get_tree().create_timer(0.5).timeout
	if in_play:
		cleared.emit()
	$ScoreCheck/CollisionShape2D.set_deferred('disabled', true)
