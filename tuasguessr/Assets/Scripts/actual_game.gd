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

var popup : Node

var game : Game

var currentData : MapDataPoint

var points = 0
var currentFloor : int
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
	
	if popup:
		popup.queue_free()
	popup = load("res://Menus/menu_leaderboard.tscn").instantiate()
	canvas.add_child(popup)
	if popup is MenuLeaderboard:
		(popup as MenuLeaderboard).set_points(points)
		(popup as MenuLeaderboard).actualgame = self

func new_game():
	game.new_game()


# Leaderboard
# --- Configuration ---
const FIREBASE_WEB_API_KEY = "AIzaSyAS4AXH_fCMi63cHv3lqDwlubaorerHZhM"
const RTDB_BASE_URL = "https://wheretheamkami-default-rtdb.europe-west1.firebasedatabase.app/scoreboard" # Your RTDB instance URL
# Firebase Authentication REST API endpoint for anonymous sign-up/in
const ANONYMOUS_SIGN_IN_URL = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=" + FIREBASE_WEB_API_KEY
# --- Internal State ---
var _id_token: String = "" # Stores the Firebase ID Token for authenticated writes
var _user_uid: String = "" # Stores the Firebase User ID (UID)
var _is_authenticating: bool = false
var _is_requesting_rtdb: bool = false

func post_score(username):
	print("Saving score for ", username)
	#This method is called when the game is ready to post the score.
	# You can access name with: username
	# You can access points with : points
	
func load_scoreboard() -> Array:
	return []
	#This method is called when the leaderboard wants to load the scores. Returns an array
	#Use await here
