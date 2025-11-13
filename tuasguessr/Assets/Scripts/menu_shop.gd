extends Node2D

class_name MenuShop

var ogplace : Vector2
var width : float

@export var opentime := 0.5
@export var curve : Curve

@export var open := false
var timer = 0

@onready var shopfront : Shopfront = find_child("ShopFront", true, false)

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
	
	if timer == opentime:
		shopfront.isvisible = true


func _on_open_button_down():
	open = !open
	var anim = "Slide_L" if open else "Slide_R"
	shopfront.play_anim(anim)
