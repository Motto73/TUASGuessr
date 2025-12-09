extends TextureRect



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



func _on_play_mouse_entered() -> void:
	show()


func _on_play_mouse_exited() -> void:
	hide()
