extends Node2D
class_name Game

@onready var Camera = $Camera2D

var gameState = "loading" 

var gameDifficulty

var mainScene
# Called when the node enters the scene tree for the first time.
func _ready():
	mainScene = $Menu_Intro
	gameState = "intro"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func startGame():
	mainScene.queue_free()
	mainScene = load("res://menu_difficulty.tscn").instantiate()
	add_child(mainScene)
	
	gameState = "difficultySelect"

func setDifficulty(diff):
	gameDifficulty = diff;
	
	mainScene.queue_free()
	mainScene = load("res://actual_game.tscn").instantiate()
	add_child(mainScene)
	
	gameState = "game"
