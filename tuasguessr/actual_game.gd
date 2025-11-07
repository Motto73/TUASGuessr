extends Node2D

class_name  ActualGame

@onready var slotmachine : SlotMachine = $Canvas/SlotMachine
@onready var mapdisplay: MapDisplay = $"Canvas/Map Display"

@onready var statsui : ShitUI = $Canvas/ShitUI

var currentData : MapDataPoint

var points = 0

var roundtimer = 0

func _ready():
	start_game()

func _process(delta):
	roundtimer -= delta
	
	statsui.set_time(roundtimer)
	statsui.set_points(points)

func start_game():
	roundtimer = 5 * 60
	points = 0
	slotmachine.reset()
	mapdisplay.reset()

func set_datapoint(data):
	print("Datapoint set")
	currentData = data
	mapdisplay.open(data)
	if not data:
		print("FUCK")

func eval_points():
	slotmachine.reset()
	print("Evaluating points:")
	print("Guess: " , mapdisplay.currentGuess, " , Target: ", currentData.position)
	var dist = mapdisplay.currentGuess.distance_to(currentData.position)
	print("Distance: ", dist)
	points += floor(clamp(3 - dist, 0, 100) * 10)

func hide_map():
	mapdisplay.map3d.reset()
