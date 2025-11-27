extends Node2D

class_name MenuLeaderboard

var points := 0
var username := ""

@onready var namefield := find_child("Namefield", true, false)
@onready var pointsield := find_child("Pointsfield", true, false)
@onready var submit := find_child("Submit", true, false)
@onready var widget : Leaderboard = find_child("Leaderboard", true, false)

@onready var http := $CanvasLayer/Control/LBControl/scoreboard_request

var actualgame : ActualGame

var data : Array

func _ready():
	print("Spawned the leaderboard popup")
	submit.disabled = false
	http.get_scores()
	
func set_points(pts):
	points = pts
	pointsield.text = "Your points:\n" + str(points)
	post_score(username, pts)
	

func _on_namefield_text_changed():
	if len(namefield.text) > 0 and len(namefield.text) <= 10:
		submit.disabled = false
		username = namefield.text
	else:
		submit.disabled = true

func _on_new_game_pressed():
	actualgame.new_game()
	submit.disabled = false
	namefield.editable = true

func disable_submit():
	submit.disabled = true
	namefield.editable = false

func _on_submit_pressed():
	submit.disabled = true
	namefield.editable = false
	post_score(username, points)
	Game.Active.actualGame.update_lb_ui()
	
# Leaderboard
func post_score(username, points):
	print("Saving score for", username, "points:", points)
	http.submit_score(username, points)
	
	#This method is called when the game is ready to post the score.
	# You can access name with: username
	# You can access points with : points
	#if username.strip_edges() == "":
		#var num = randi_range(1, 10000)
		#var defaultname = "Player" + str(num)
		#username = defaultname
		#print("Saving score for " + defaultname)
		#http.submit_score(username, points)
		#return
