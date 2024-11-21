extends Node

var background_scene_edge = 1536

var save_path = "user://save/"
var save_name = "gamesave.tres"
var gameSave = SaveGame.new()
var high_scores: Dictionary

var game_on: bool = false
var fresh_game: bool = true
var new_best: bool = false
var frame_stop = false
var await_limiter = true

#var test_dict = { "HUT": 3, "JIM": 1, "KIL": 9, "YIT": 8 }

@onready var foreground_node = get_node("BackgroundContainer/ForegroundContainer")
@onready var midground_node = get_node("BackgroundContainer/MidgroundContainer")
@onready var v_box = $HUD/Panel/ScrollContainer/VBoxContainer

#var high_scores: Dictionary
var highest_score: int = 0
var key_pressed = ''
var message_position

#@export var background_scene: PackedScene
@export var obstacle_scene: PackedScene
@export var score_slide_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready(): 
	foreground_node.start_background('flow')
	midground_node.start_background('flow')
	message_position = $HUD/Message.position
	$HUD.show_message('Hopjumper')
#	load_save()
#	save_game()
	set_high_score()
	write_scores_to_ui(order_highscores(high_scores))

	
#	
	
func _process(delta):
	if not game_on and not $HUD.high_score_mode: 
		if Input.is_action_pressed('ui_accept'):
			clear_children($ObstacleContainer)
			$HUD.score = 0
			$Player.start_pos(Vector2(100, 324))
			$Player.push_to_position()
			$HUD.show_message('Get Ready!')
			game_on = true
		
		if not $HUD.high_score_page_mode:
			if key_pressed == 'H':
				if await_limiter:
					$HUD.show_message('High Scores')
					await_limiter = false
					await get_tree().create_timer(0.5).timeout
					flip_mode_flag('high score')
					key_pressed = ''
					await_limiter = true
		
		if $HUD.high_score_page_mode:		
			if key_pressed == 'H':
				if await_limiter:
					$HUD.show_message('Hopjumper')
					await_limiter = false
					await get_tree().create_timer(0.5).timeout
					flip_mode_flag('high score')
					key_pressed = ''
					await_limiter = true
			
			if key_pressed == 'B':
				if await_limiter:
					clear_children($ObstacleContainer)
#					save_game()
					get_tree().reload_current_scene()
					await_limiter = false
					await get_tree().create_timer(0.5).timeout
					flip_mode_flag('high score')
					key_pressed = ''
					await_limiter = true
			
			
		
	if not game_on and $HUD.high_score_mode:
		clear_children($ObstacleContainer)
		if Input.is_action_pressed('ui_accept'):
			var player_name = get_player_name($HUD.chars_picked)
			if check_name_repeat(player_name):
				$HUD/SubMessage.text = 'Name already taken'
				await get_tree(). create_timer(0.8).timeout
				$HUD.repeat_name_entry()
			else:
				$HUD.show_message('Game Over')
				await get_tree(). create_timer(0.3).timeout
				$HUD.high_score_mode = false
				if new_best:
					update_high_scores()
					write_scores_to_ui(order_highscores(high_scores))
					new_best = false
			
			
	
	

func new_game():
	for i in foreground_node.get_child_count():
		if get_child(i) != null:
			foreground_node.get_child(i).in_play = true
	
	for i in midground_node.get_child_count():
		if get_child(i) != null:
			midground_node.get_child(i).in_play = true
#		foreground_node.start_background('flow')
#		midground_node.start_background('flow')
	$Player/BlueShipHitbox.set_deferred('disabled', false)
	$ObstacleTimer.start()
	$Player.start_state()
	fresh_game = false 
		

func _on_obstacle_timer_timeout():
	var obstacle = obstacle_scene.instantiate()
	var variation = randi_range(0, 100)
	$ObstacleContainer.add_child(obstacle)
	obstacle.cleared.connect($HUD.on_obstacle_cleared.bind())
	obstacle.spawn(variation)

func game_over():
	var drop_time = 0.7 #time it takes for sprite anim to finish
	$ObstacleTimer.stop()
	#make player fall to ground
	var tween = create_tween()
	tween.tween_property($Player, 'position', Vector2($Player.position.x, 628), drop_time)
	
	#disable player controls
	$Player.in_play = false
	
	#stop the background scrolling
	for i in foreground_node.get_child_count():
		if get_child(i) != null:
			foreground_node.get_child(i).in_play = false
	
	for i in midground_node.get_child_count():
		if get_child(i) != null:
			midground_node.get_child(i).in_play = false
	
	#stop the obstacle scrolling
	for i in $ObstacleContainer.get_child_count():
		$ObstacleContainer.get_child(i).in_play = false 
		
	#delay game-on state switch and game over message display till end of drop anim
	await get_tree().create_timer(drop_time).timeout
	if highest_score < $HUD.score:
		$HUD.high_score_mode = true
		$HUD.show_message('New High Score')
		highest_score = $HUD.score
		new_best = true
	else:
		$HUD.show_message('Game Over')
	
	game_on = false
	

	#stop spawning of new obstacles
	
func clear_children(parent):
	for i in parent.get_child_count():
		if parent.get_child(i) != null:
			parent.get_child(i).queue_free()
			
func update_high_scores(): 
	var player_name = get_player_name($HUD.chars_picked)
	var score = $HUD.score
	high_scores[player_name] = score
	
	while high_scores.size() > 10:
		var lowest_value: int = 100
		for entry in high_scores:
			if high_scores[entry] < lowest_value:
				lowest_value = high_scores[entry]
		
		for logged in high_scores:
			if high_scores[logged] == lowest_value:
				high_scores.erase(logged)
	
	print(high_scores)

func get_player_name(name_array):
	var player_name = ''
	for char in name_array:
		player_name += char
	return player_name
	
func check_name_repeat(new_name) -> bool:
	for entry in high_scores:
		if entry == new_name:
			return true
			break	
	return false

func write_scores_to_ui(scores):
	for i in v_box.get_child_count():
		if get_child(i) != null:
			v_box.get_child(i).queue_free()
	for entry in scores:
		var score_slide = score_slide_scene.instantiate()
		score_slide.get_child(0).text = entry
		score_slide.get_child(1).text = str(scores[entry]).pad_zeros(3)
		v_box.add_child(score_slide)
	print(v_box.get_child_count())	
	print('Scores drawn to UI Real')
	
	
			
func _unhandled_input(event):
	if event is InputEventKey:
		key_pressed = event.as_text_key_label()
	
	if event.is_action_pressed('ui_cancel'):
#		save_game()
		get_tree().quit()
		
func flip_mode_flag(mode):
#	await get_tree().create_timer(0.3).timeout
	if mode == 'high score':
		$HUD.high_score_page_mode = not $HUD.high_score_page_mode

func position_reset():
	$HUD/Message.position = message_position
	print('position reset ' + str(message_position))

func save_game():
	ResourceSaver.save(gameSave, save_path + save_name)
	print('game saved')

func load_save():
	print('load function called')
	if FileAccess.file_exists(save_path + save_name):
		gameSave = ResourceLoader.load(save_path + save_name).duplicate(true)
		print('save loaded')
		high_scores = gameSave.high_scores
		print(high_scores)
	else:
		pass

func set_high_score():
	var highest_value: int = 0
	for entry in high_scores:
		if high_scores[entry] > highest_value:
			highest_value = high_scores[entry]
	highest_score = highest_value

#func order_high_scores(scores: Dictionary):
#	var original_dict = scores.duplicate()
#	var ordered_dict = {}
#	var value_arr = original_dict.values()
#	for i in original_dict.size():
#		var highest_value: int = 0
#		var duplicate_arr = []
#		for value in value_arr:
#			if value > highest_value:
#				highest_value = value
#		for entry in original_dict:
#			if original_dict[entry] == highest_value:
#				duplicate_arr.append(entry)
#		if duplicate_arr.size() > 1:
#			ordered_dict[original_dict.find_key(highest_value)] = highest_value
#			original_dict.erase(original_dict.find_key(highest_value))
#		else:
#			ordered_dict[original_dict.find_key(highest_value)] = highest_value
#		value_arr.pop_at(value_arr.find(highest_value))
#	return ordered_dict

func order_highscores(score: Dictionary) -> Dictionary:
	var original_dict: Dictionary = score.duplicate()
	var ordered_dict: Dictionary
	for i in original_dict.size():
		var highest_score: int = 0
		for entry in original_dict:
			if original_dict[entry] > highest_score:
				highest_score = original_dict[entry]
		ordered_dict[original_dict.find_key(highest_score)] = highest_score
		original_dict.erase(original_dict.find_key(highest_score))
	return ordered_dict	

