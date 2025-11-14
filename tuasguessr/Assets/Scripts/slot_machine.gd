extends Node2D

class_name  SlotMachine

@export var RollTime : float = 1.0
@export var RandomImageTime : float = 0.1
@export var Data : MapDataPoints

var state : String = "loading"
var timer : float = 0

var images : Array = []

var rng := RandomNumberGenerator.new()

@onready var display := find_child("Display", true, false)
@onready var button := find_child("RollButton", true, false)

var selectedPoint : MapDataPoint

func _ready():
	state = "ready"
	set_random_images()

func _process(delta):
	if state == "rolling":
		timer += delta
		show_random_image()
		if timer >= RollTime:
			state = "gaming"
			timer = 0
			select_point()

func reset():
	button.disabled = false
	state = "ready"

func _on_roll_button_button_down():
	if state == "ready":
		state = "rolling"
		timer = 0
	button.disabled = true
	Game.Active.actualGame.hide_map()

func show_random_image():
	var rand = rng.randi_range(0, len(images) - 1)
	display.texture = images[rand]

func set_random_images():
	images = []
	for d : MapDataPoint in Data.DataPoints:
		var img = load(d.imgresource) as CompressedTexture2D
		images.append(img)
	print("Random images set: ", len(images))

func select_point():
	#TODO - difficulty selection
	var rand = rng.randi_range(0, len(Data.DataPoints) - 1)
	display.texture = images[rand]
	selectedPoint = Data.DataPoints[rand]
	Game.Active.actualGame.set_datapoint(selectedPoint)

func lock():
	state = "locked"
	button.disabled = true
	timer = 0
