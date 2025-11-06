extends Node2D

@export_category("Peniz")
@export var RollTime : float = 1.0
@export var RandomImageTime : float = 0.1
@export var Data : MapDataPoints

var state : String = "loading"
var timer : float = 0

var images : Array = []

var rng := RandomNumberGenerator.new()

@onready var display := $Control/Display
@onready var button := $Control/RollButton

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

func reset():
	button.disabled = false

func _on_roll_button_button_down():
	if state == "ready":
		state = "rolling"
		timer = 0
	button.disabled = true

func show_random_image():
	var rand = rng.randi_range(0, len(images) - 1)
	display.texture = images[rand]

func set_random_images():
	images = []
	for d : MapDataPoint in Data.DataPoints:
		var img = load(d.imgresource) as CompressedTexture2D
		images.append(img)
	print("Random images set: ", len(images))
