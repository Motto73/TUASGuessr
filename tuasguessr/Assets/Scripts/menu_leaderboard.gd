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
	print("MENU LEADERBOARD: Calling check scoreboard for updates")
	submit.disabled = false
	load_leaderboard()
func set_points(pts):
	points = pts
	pointsield.text = "Your points:\n" + str(points)
	
func load_leaderboard():
	print("Requesting scoreboard...")
	Firebase.scoreboard_read_completed.connect(_on_leaderboard_ready)


func _on_leaderboard_ready(success: bool, data: Array, error: String):
	if not success:
		print("MENU LEADERBOARD: Leaderboard error:", error)
		return
	var arr = {"scores": data}
	widget.set_data(data)



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
	Game.Active.actualGame.post_score(username)
	Firebase.score_write_completed.connect(widget.set_data)
	await get_tree().process_frame
	widget.update_list()
	
