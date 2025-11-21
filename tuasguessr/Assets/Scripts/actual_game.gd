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
@onready var canvas : CanvasLayer = $Canvas

@onready var statsui : ShitUI = $Canvas/ShitUI

@onready var firebase_rtdb = $Assets/Scripts/Firebase


var popup : Node

var game : Game

var currentData : MapDataPoint

var points = 0

var currentFloor : int
var roundtimer = 0

var state = "loading"

var inventorytags : Array[String] = []

func _ready():
	start_game()
	Firebase.points = points

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
	set_points(points + floor(clamp(3 - dist, 0, 100) * 10))

func hide_map():
	mapdisplay.map3d.reset()
	
func end_game():
	state = "gameover"
	statsui.set_time(-1)
	slotmachine.lock()
	mapdisplay.lock()
	
	if popup:
		popup.queue_free()
	popup = load("res://Menus/menu_leaderboard.tscn").instantiate()
	canvas.add_child(popup)
	if popup is MenuLeaderboard:
		(popup as MenuLeaderboard).set_points(points)
		(popup as MenuLeaderboard).actualgame = self

func new_game():
	game.new_game()
	
#Score
func set_points(pts):
	points = pts
	statsui.set_points(points)

#Inventory
func add_item(item):
	if item is String and not inventorytags.has(item):
		inventorytags.append(item)

func  buy_item(item):
	if not item is ShopItem:
		return false
	item = item as ShopItem
	if points >= item.Price:
		set_points(points - item.Price)
		add_item(item.Tag)
		return true
	return false
	
# Leaderboard
func post_score(username):
	print("Saving score for ", username)
	#This method is called when the game is ready to post the score.
	# You can access name with: username
	# You can access points with : points
	Firebase.write_score(username, points)
	
func load_scoreboard() -> Array:
	#This method is called when the leaderboard wants to load the scores. Returns an array
	#Use await here
	var scoreboard = Firebase.get_scoreboard_data()
	await scoreboard
	return scoreboard.values()
