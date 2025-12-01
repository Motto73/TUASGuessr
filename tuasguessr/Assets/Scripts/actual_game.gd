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
##Measured godot to meters distance
@export var GodotToMeters = 2.40 / 0.14

@onready var slopmachine : SlopMachine = $Canvas/Slopmachine
var slotmachine : Slots3D
@onready var mapdisplay: MapDisplay = $"Canvas/Map Display"
@onready var canvas : CanvasLayer = $Canvas
@onready var topcanvas : CanvasLayer = $TopCanvas

@onready var statsui : ShitUI = $Canvas/ShitUI

@onready var menu_lb : MenuLeaderboard = $Canvas/Menu_Leaderboard

var popup : Node

var game : Game

var currentData : MapDataPoint

var points = 0

var currentFloor : int
var roundtimer = 0

var state = "loading"

var inventorytags : Array[String] = []

func _ready():
	slotmachine = slopmachine.Slots
	menu_lb.hide_lb()
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
	if not data:
		print("FUCK")

func allow_bets():
	mapdisplay.open(currentData)

func eval_points():
	slotmachine.reset()
	var currentfloor = mapdisplay.map3d.currentfloor
	var actualfloor = currentData.floor
	print("Guess was at ", currentfloor, ", And the actual floor was ", actualfloor)
	
	print("Evaluating points:")
	print("Guess: " , mapdisplay.currentGuess, " , Target: ", currentData.position)
	var dist = mapdisplay.currentGuess.distance_to(currentData.position)
	var dist_m = dist * GodotToMeters
	print("Distance: ", dist, " Real distance: ", dist_m)
	var pts = round(100 - dist_m)
	if pts < 0:
		pts = 0
	#Spawn a little popup thing
	var pop = load("res://Resource Scenes/pointspopup.tscn").instantiate()
	pop.position = statsui.position
	topcanvas.add_child(pop)
	var text = "+" + str(pts) + " Points!"
	var floor = true
	#Check floor
	if actualfloor != currentfloor:
		pts = 0
		text = "Wrong floor!\n Actual floor: " + str(actualfloor)
		floor = false
	##Actually apply points
	pop.text = text
	set_points(points + pts)
	return floor

func hide_map():
	mapdisplay.map3d.reset()
	
func end_game():
	state = "gameover"
	statsui.set_time(-1)
	slotmachine.lock()
	mapdisplay.lock()
	
	# NÄYTÄ LEADERBOARD WIDGET
	menu_lb.show_lb()
	menu_lb.set_points(points)
	menu_lb.actualgame = self

func new_game():
	menu_lb.hide_lb()
	game.new_game()
	
#Score
func set_points(pts):
	points = pts
	statsui.set_points(points)

#Inventory
func add_item(item):
	if item is String and not inventorytags.has(item):
		inventorytags.append(item)
		#Special interactions
		if item == "lunch":
			roundtimer += 60.0

func  buy_item(item):
	print("Buying item: ", item)
	if not item is ShopItem:
		print("Item is not ShopItem!")
		return false
	item = item as ShopItem
	if points >= item.Price:
		print("Item bought!", item.Tag)
		set_points(points - item.Price)
		add_item(item.Tag)
		return true
	print("Item not bought.")
	return false
	
# Leaderboard
func post_score(username):
	print("Saving score for ", username)
	#This method is called when the game is ready to post the score.
	# You can access name with: username
	# You can access points with : points
	Firebase.write_score(username, points)
	
