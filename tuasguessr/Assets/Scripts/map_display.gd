extends Node2D

class_name MapDisplay

@onready var map3d : Map3D = find_child("3dMap", true, false)
@onready var button : Button = find_child("Button", true, false)

var currentGuess : Vector3
var actualPoint : MapDataPoint

var state = "loading"

func reset():
	close()

func _ready():
	close()

func _on_button_down():
	state = "accepted"
	close()
	if Game.Active.actualGame.eval_points():
		map3d.reveal()

func open(data):
	actualPoint = data
	state = "input"
	map3d.CanMove = true

func close():
	state = "waiting"
	button.disabled = true

func update_guess(pos):
	currentGuess = pos
	state = "ready"
	button.disabled = false

func lock():
	state = "locked"
	button.disabled = true
	map3d.lock()


func buttonpressed(num):
	map3d.show_floor(num)
	Game.Active.actualGame.currentFloor = num


#Yes, this is probably very dumb.
func _on_texture_button_button_down():
	buttonpressed(0)
func _on_texture_button_2_button_down():
	buttonpressed(1)
func _on_texture_button_3_button_down():
	buttonpressed(2)
func _on_texture_button_4_button_down():
	buttonpressed(3)
