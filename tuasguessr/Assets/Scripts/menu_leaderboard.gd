extends Node2D

class_name MenuLeaderboard

var points := 0
var username := ""

@onready var namefield := find_child("Namefield", true, false)
@onready var pointsield := find_child("Pointsfield", true, false)
@onready var submit := find_child("Submit", true, false)
@onready var widget : Leaderboard = find_child("Leaderboard", true, false)

var actualgame : ActualGame

var data : Array

func _ready():
	print("Spawned the leaderboard popup")
	submit.disabled = true
	
	load_leaderboard()

func set_points(pts):
	points = pts
	pointsield.text = "Your points:\n" + str(points)
	
func load_leaderboard():
	#TODO - load a list into the leaderboard shi
	var yep = Game.Active.actualGame.load_scoreboard()
	widget.set_data(yep)


func _on_namefield_text_changed():
	if len(namefield.text) > 0 and len(namefield.text) <= 10:
		submit.disabled = false
		username = namefield.text
	else:
		submit.disabled = true

func _on_new_game_pressed():
	actualgame.new_game()

func _on_submit_pressed():
	submit.disabled = true
	namefield.editable = false
	Game.Active.actualGame.post_score(username)
