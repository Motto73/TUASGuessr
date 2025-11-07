extends Node2D

class_name MapDisplay

@onready var actualgame : ActualGame = $"../.."
@onready var map3d : Map3D = $"Control/SubViewportContainer/SubViewport/3dMap"
@onready var button : Button = $Control/Button

var currentGuess : Vector3
var actualPoint : MapDataPoint

var state = "loading"

func reset():
	close()

func _ready():
	close()

func _on_button_down():
	state = "accepted"
	map3d.reveal()
	close()
	actualgame.eval_points()

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
