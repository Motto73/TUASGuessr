extends Node2D

class_name  ActualGame

@export_category("Game Settings")
##Game duration in seconds
@export var GameDuration := 5. * 60.
##Game duration in short gamemode
@export var ShortDuration := 1. * 60.
##How many points does short game start with?
@export var ShortStartPoints := 50.
##Use short game mode instead
@export var UseShortGame := true

@onready var slotmachine : SlotMachine = $Canvas/SlotMachine
@onready var mapdisplay: MapDisplay = $"Canvas/Map Display"

@onready var statsui : ShitUI = $Canvas/ShitUI

var game : Game

var currentData : MapDataPoint

var points = 0

var roundtimer = 0

var state = "loading"

func _ready():
	start_game()

func _process(delta):
	if state == "playing":
		roundtimer -= delta
		statsui.set_time(roundtimer)
		statsui.set_points(points)
		if roundtimer <= 0:
			end_game()

func start_game():
	roundtimer = ShortDuration if UseShortGame else GameDuration
	points = 0
	slotmachine.reset()
	mapdisplay.reset()
	state = "playing"

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
	
func end_game():
	state = "gameover"
	statsui.set_time(-1)
	slotmachine.lock()
	mapdisplay.lock()
	#TODO - load game end
	game.gameover(points)
