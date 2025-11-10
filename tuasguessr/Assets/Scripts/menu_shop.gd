extends Node2D

class_name MenuShop

var ogplace : Vector2
var width : float

@export var opentime := 0.5
@export var curve : Curve

@export var open := false
var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	ogplace = position
	width = $Control/Bg.get_rect().size.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(open):
		timer += delta
	else:
		timer -= delta
	timer = clamp(timer, 0, opentime)
	var progress = timer / opentime
	progress = curve.sample(progress)
	position = ogplace + Vector2(width * progress, 0)


func _on_open_button_down():
	open = !open
