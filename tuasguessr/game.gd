extends Node2D
class_name Game

@onready var Camera = $Camera2D

var gameState = "loading" 

var gameDifficulty : String

var mainScene : Node
var popup : Node

func _ready():
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
