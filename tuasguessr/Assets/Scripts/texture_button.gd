extends TextureButton

var icon_default = get_texture_normal()
var icon_pressed = preload("res://Assets/Textures/FloorButton2_on.png")

func _pressed():
	Sounds.play_switch()
	self.texture_normal = icon_pressed
	await(5) 
	self.texture_normal = icon_default
