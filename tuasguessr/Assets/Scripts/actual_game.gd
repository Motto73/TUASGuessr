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

@onready var slotmachine : SlotMachine = $Canvas/SlotMachine
@onready var mapdisplay: MapDisplay = $"Canvas/Map Display"
@onready var canvas : CanvasLayer = $Canvas
@onready var topcanvas : CanvasLayer = $TopCanvas

@onready var statsui : ShitUI = $Canvas/ShitUI


var popup : Node

var game : Game

var currentData : MapDataPoint

var points = 0
var FireBaseNode : FireBaseScript

var currentFloor : int
var roundtimer = 0

var state = "loading"

var inventorytags : Array[String] = []

func _ready():
	start_game()
	var firebase = load("res://Resource Scenes/firebase.tscn").instantiate()
	add_child(firebase)
	assert(firebase is FireBaseScript, "FUCK!")
	FireBaseNode = firebase as FireBaseScript

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
	var dist_m = dist * GodotToMeters
	print("Distance: ", dist, " Real distance: ", dist_m)
	var pts = round(100 - dist_m)
	if pts < 0:
		pts = 0
	set_points(points + pts)
	#Spawn a little popup thing
	var pop = load("res://Resource Scenes/pointspopup.tscn").instantiate()
	pop.position = statsui.position
	topcanvas.add_child(pop)
	pop.text = "+" + str(pts) + " Points!"

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
	FireBaseNode.write_score(username, points)
	#FireBaseNode.write_score("Test", 99)
	
func load_scoreboard():
	print("Requesting scoreboard...")
	
	# Yhdistä signaali vain kerran
	if not FireBaseNode.scoreboard_read_completed.is_connected(_on_scores):
		print("DEBUG: connecting signal now")
		FireBaseNode.scoreboard_read_completed.connect(_on_scores)

	# Käynnistä HTTPRequest
	print("DEBUG: load_scoreboard() calling Firebase.read_scoreboard()")
	FireBaseNode.read_scoreboard()
	

#Triggered after load_scoreboard()
func _on_scores(success: bool, data: Array, error: String):
	print("DEBUG: _on_scores called!")
	print("DEBUG: success =", success)
	print("DEBUG: data =", data)
	if success:
		print("Scoreboard received:", data)
		print("Scoreboard length:", data.size())
	else:
		print("Error loading scoreboard:", error)
