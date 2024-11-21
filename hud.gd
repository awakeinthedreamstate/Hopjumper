extends CanvasLayer

var score = 0

@export var countdown_interval = 0.9

var main = get_parent()

var message_decrement = false
var sub_message_decrement_high_score = false

@export var high_score_mode = true
var high_score_page_mode: bool = false

var key_just_pressed = ''
var last_confirmed_letter = ''
var chars_picked: Array = ['', '', '']
var prev_char_text = '_'

var tween

#check to make sure process does not call Input function multiple 
#times within one button press
var frame_stop = false
var updated = false
#variables useful for iterating through characters on screen
@onready var char_nodes: Array = [$NameEntry/Char1, $NameEntry/Char2, $NameEntry/Char3]
var max_char_count = 2
var char_focus = 0

var message_default_position = Vector2(225.5, 283)
var submessage_default_position = Vector2(361.5, 364.5)
#spread layout of title and submessage text to make way for score display on game over
var title_spread_position = Vector2(225.5, 176)
var submessage_spread_position = Vector2(326.5, 366.5)
#spread layout of title and submessage text to make way for name save on new high score
var title_highscore_position = Vector2(225.5, 124)
var submessage_highscore_position = Vector2(361.5, 427)

signal countdown_done

# Called when the node enters the scene tree for the first time.
func _ready(): pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ScoreLabel.text = "Score: %s" % score
#Code that decides that sets focus on the desired character for tweening and 
#uodating
	if high_score_mode:
		if Input.is_action_pressed('ui_right'): 
			move_cursor('right')
		
		if Input.is_action_pressed('ui_left'): 
			move_cursor('left')

func tween_character(char_in_focus, last_char, call_source):
	if tween:
		tween.stop()
	
	if last_char != null and char_nodes[last_char].text == '' and not updated:
		char_nodes[last_char].text = '_'
			
	if call_source == 'input':
		char_nodes[last_char].text = prev_char_text
		chars_picked[last_char] = prev_char_text
	elif call_source == 'start':
		char_nodes[2].text = '_'

	prev_char_text = char_in_focus.text

	tween = create_tween().set_loops()
	tween.tween_property(char_in_focus, 'text', '' if char_in_focus.text == '_' else '_', 0.4)
	tween.tween_property(char_in_focus, 'text', char_in_focus.text, 0.4)
		
	await get_tree().create_timer(0.5).timeout
	frame_stop = false
		
func update_char(updatee, updatee_index):
	updatee.text = key_just_pressed
	chars_picked[updatee_index] = key_just_pressed

func calc_last_char(char, direction):
	var last_char: int
	if direction == 'right':
		last_char = char - 1 if char != 0 else 2
#		if char != 0:
#			last_char = char - 1
#		else:
#			last_char = 2
	elif direction == 'left':
		last_char = char + 1 if char != 2 else 0
#		if char != 2:
#			last_char = char + 1
#		else:
#			last_char = 0
	return last_char
		
func on_obstacle_cleared():
	score += 1
	
func show_message(message):
	if message == 'Hopjumper':
		for i in get_parent().foreground_node.get_child_count():
			if get_child(i) != null:
				get_parent().foreground_node.get_child(i).in_play = true
	
		for i in get_parent().midground_node.get_child_count():
			if get_child(i) != null:
				get_parent().midground_node.get_child(i).in_play = true
		get_node("../Player").start_pos(Vector2(100, 324))
		$NameEntry.hide()
		$ScoreLabel.hide()
		$ScoreDisplay.hide()
		$Panel.hide()
		$Message.show()
		$SubMessage.show()
		$Message.text = message
		$SubMessage.text = 'Press Space to Start'
		$HighScoreSelectLabel.text = 'Press [h] for high scores'
		$SubMessage.position = submessage_default_position
		#Tween submessage
		var tween2 = create_tween().set_loops()
		tween2.tween_property($SubMessage, 'theme_override_colors/font_color', Color(Color.WHITE, 1), 0.5)
		tween2.tween_property($SubMessage, 'theme_override_colors/font_color', Color(Color.RED, 1), 0.5)
		
		get_parent().position_reset()
#		print('Hopjumper ' + str($Message.position.x) + ' ' + str($Message.position.y))
		
	if message == "Get Ready!":
		$SubMessage.hide()
		$ScoreLabel.show()
		$NameEntry.hide()
		$ScoreDisplay.hide()
		$HighScoreSelectLabel.hide()
		$Message.position = message_default_position
#		$SubMessage.position = Vector2(0, 0)
		
#	#reset the highscore name input field to '_'
		reset_highscore_name_field()
		
		$Message.text = "Get Ready! \n3"
		$Message.show()
		
		
		$SubMessage.position = submessage_default_position
		
		await get_tree().create_timer(countdown_interval).timeout
		$Message.text = "Get Ready! \n2"
		$Message.show()		
		await get_tree().create_timer(countdown_interval).timeout

		$Message.text = "Get Ready! \n1"
		$Message.show()
		
		await get_tree().create_timer(countdown_interval).timeout
		$Message.hide()
		
		countdown_done.emit()
		
	if message  == 'Game Over':
		$ScoreLabel.hide()
		$NameEntry.hide()
		$ScoreDisplay.show()
		$HighScoreSelectLabel.show()
		$Message.position = title_spread_position
		$SubMessage.position = submessage_spread_position
#		if not sub_message_decrement_game_over:
#			$SubMessage.position = submessage_spread_position
#		else:
#			$SubMessage.position = submessage_spread_position + Vector2(-35, 0)
		$Message.text = "Game Over!"
		$ScoreDisplay.text = "Score: %s" % score
		$SubMessage.text = "Press Space to try again"
		$HighScoreSelectLabel.text = 'Press [B] to go back to main'
		$Message.show()
		$SubMessage.show()
		var tween1 = create_tween().set_loops()
		tween1.tween_property($SubMessage, 'theme_override_colors/font_color', Color(Color.WHITE, 1), 0.5)
		tween1.tween_property($SubMessage, 'theme_override_colors/font_color', Color(Color.RED, 1), 0.5)
		high_score_page_mode = true
#		print('Game Over' + str($Message.position.x) + ' ' + str($Message.position.y))
		
	if message == 'New High Score':
		
		$ScoreDisplay.hide()
		$Message.text = message
		$SubMessage.text = 'Press Space to Save'
		$Message.position = title_highscore_position
		$SubMessage.position = submessage_highscore_position
		$Message.show()
		$SubMessage.show()
		$NameEntry.show()
		if high_score_mode:
			update_char(char_nodes[char_focus], char_focus) 
			tween_character(char_nodes[char_focus], null, 'start')
			
	if message == 'High Scores':
		$ScoreLabel.hide()
		$ScoreDisplay.hide()
		$SubMessage.hide()
		$Message.hide()
		$NameEntry.hide()
		$Panel.show()
		
		$HighScoreSelectLabel.text = 'Press [H] to go back'

func move_cursor(direction):
	if direction == 'right':
		if !frame_stop:
			if char_focus < max_char_count:
				char_focus += 1
			elif char_focus == max_char_count:
				char_focus = 0
#				last_confirmed_letter = key_just_pressed
			frame_stop = true
			tween_character(char_nodes[char_focus], calc_last_char(char_focus, 'right'), 'input')
	elif direction == 'left':
		if !frame_stop:
			if char_focus > 0:
				char_focus -= 1
			elif char_focus == 0:
				char_focus = max_char_count
#			last_confirmed_letter = key_just_pressed
			frame_stop = true
			tween_character(char_nodes[char_focus], calc_last_char(char_focus, 'left'), 'input')		
		
		
		
func _unhandled_input(event):
	if high_score_mode:
		if event is InputEventKey:
			if !event.as_text_key_label().length() > 1:
				key_just_pressed = event.as_text_key_label()
				updated = true
				update_char(char_nodes[char_focus], char_focus)
				tween_character(char_nodes[char_focus], null, 'update')
				await get_tree().create_timer(0.15).timeout
				if char_focus != 2:
					move_cursor('right')

func reset_highscore_name_field():
	for chars in char_nodes:
			chars.text = '_'
	for i in chars_picked.size():
		chars_picked[i] = ''
	char_focus = 0
	key_just_pressed = ''
	prev_char_text = '_'	

func repeat_name_entry():
	reset_highscore_name_field()
	show_message('New High Score')
		
func clear_message():
	$Message.hide()
	$SubMessage.hide()
