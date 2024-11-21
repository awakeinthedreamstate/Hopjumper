extends Area2D


@export var jump_impulse = 100

const exhaust_offset_dip = -19
const exhaust_offset_pump = 1

signal hit

var screen_size

var fall_speed = 20
var world_gravity = 0
var in_play = false

@onready var hud_node = get_node('/root/main/HUD')


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$ExhaustSprite.show()
	$ExhaustSprite.play()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if in_play == true:
		world_gravity += fall_speed * delta
		position.y += world_gravity
		
		if Input.is_action_just_pressed('ui_accept'):
			var tween = create_tween().set_ease(Tween.EASE_IN)
			tween.tween_property(self, 'position', Vector2(position.x, position.y - jump_impulse), 0.1)
			$ExhaustSprite.show()
			$ExhaustSprite.stop()
			world_gravity = 0	

		if !Input.is_anything_pressed():
			$ExhaustSprite.play()
			
	if $ExhaustSprite.is_playing():
		if $ExhaustSprite.get_frame() == 1:
			$ExhaustSprite.position.y = exhaust_offset_dip
		else:
			$ExhaustSprite.position.y = exhaust_offset_pump
			
			
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	

func _on_area_entered(area):
	hit.emit()
	$ExhaustSprite.stop()
	$ExhaustSprite.hide()
	$BlueShipHitbox.set_deferred('disabled', true)
	
func start_pos(pos):
	position = pos
	
func start_state():
	world_gravity = 0
	in_play = true
	
func push_to_position():
	var tween = create_tween()
	$ExhaustSprite.show()
	$ExhaustSprite.stop()
	tween.tween_property(self, 'rotation', PI / 10, 0.1)
	tween.tween_property(self, 'position', Vector2(450, position.y), hud_node.countdown_interval * 2)
	tween.tween_property(self, 'rotation', 0, 0.3)
	await get_tree().create_timer(0.1 + (hud_node.countdown_interval * 2) + 0.2).timeout
	$ExhaustSprite.play()
	
	
	
	
	
