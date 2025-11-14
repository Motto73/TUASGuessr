extends Node2D
class_name Game

@onready var Camera := $Camera2D
@onready var versiontext := $DrawOnTop/VersionText

##Static reference to the current active game
static var Active : Game

var actualGame : ActualGame

var gameState = "loading" 

var gameDifficulty : String

var mainScene : Node
var popup : Node

##This is the primary build version. Whenever releasing a new build, change this.
var gameVersion : String = "0.0.1"
var osname : String
var osmode : String
var osmobile : bool

const FIRESTORE_BASE := "REPLACE"
const FIRESTORE_QUERY := "REPLACE"
const API_KEY := "REPLACE"

func _ready():
	Active = self
	
	osname = OS.get_name()
	osmobile = OS.has_feature("web_android") or OS.has_feature("web_ios") 
	if osmobile:
		osmode = "Mobile"
	else:
		osmode = "Desktop"
	versiontext.text = "Version " + gameVersion + " | Platform " + osname + " | Mode " + osmode
	
	mainScene = $Menu_Intro
	gameState = "intro"

func startGame():
	loadMainScene("res://Menus/menu_difficulty.tscn")
	gameState = "difficultySelect"

func setDifficulty(diff):
	gameDifficulty = diff;
	
	loadMainScene("res://Main Scenes/scene_actual_game.tscn")
	gameState = "game"
	(mainScene as ActualGame).game = self
	actualGame = mainScene as ActualGame

func loadMainScene(res):
	if mainScene:
		mainScene.queue_free()
	mainScene = load(res).instantiate()
	add_child(mainScene)
	
func new_game():
	startGame()
