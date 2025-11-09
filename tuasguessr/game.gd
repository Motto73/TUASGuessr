extends Node2D
class_name Game

@onready var Camera := $Camera2D
@onready var versiontext := $DrawOnTop/VersionText

var gameState = "loading" 

var gameDifficulty : String

var mainScene : Node
var popup : Node

var gameVersion : String = "0.0.0"
var osname : String
var osmode : String
var osmobile : bool

func _ready():
	osname = OS.get_name()
	osmobile = OS.has_feature("web_android") or OS.has_feature("web_ios") 
	if osmobile:
		osmode = "Mobile"
	else:
		osmode = "Desktop"
	versiontext.text = "Version " + gameVersion + " Engine " + osname + " Platform " + osmode
	
	mainScene = $Menu_Intro
	gameState = "intro"

func _process(delta):
	pass

func startGame():
	loadMainScene("res://menu_difficulty.tscn")
	gameState = "difficultySelect"

func setDifficulty(diff):
	gameDifficulty = diff;
	
	loadMainScene("res://actual_game.tscn")
	gameState = "game"
	(mainScene as ActualGame).game = self

func loadMainScene(res):
	if mainScene:
		mainScene.queue_free()
	mainScene = load(res).instantiate()
	add_child(mainScene)
	
func new_game():
	startGame()
