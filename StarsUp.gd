extends TextureRect

signal on_done
signal off_done
# Called when the node enters the scene tree for the first time.
func _ready(): 
	z_index = 2
	blink_off()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): pass
	
func blink_on():
	var tween = create_tween()
	tween.tween_property(self, 'modulate:a', 2, 3)
	await get_tree().create_timer(3).timeout
	on_done.emit()

func blink_off():
	var tween = create_tween()
	tween.tween_property(self, 'modulate:a', 0, 1.5)
	await get_tree().create_timer(3).timeout
	off_done.emit()
