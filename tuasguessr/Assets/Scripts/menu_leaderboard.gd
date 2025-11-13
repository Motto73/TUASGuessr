extends Node2D

class_name MenuLeaderboard

var points = 0

@onready var namefield := find_child("Namefield", true, false)
@onready var pointsield := find_child("Pointsfield", true, false)
@onready var submit := find_child("Submit", true, false)

var actualgame : ActualGame

func _ready():
	print("Spawned the leaderboard popup")
	submit.disabled = true

func set_points(pts):
	points = pts
	pointsield.text = "Your points:\n" + str(points)


func _on_namefield_text_changed():
	if len(namefield.text) > 0 and len(namefield.text) <= 10:
		submit.disabled = false
	else:
		submit.disabled = true

func _on_submit_pressed():
	pass #Send to database

func _on_new_game_pressed():
	actualgame.new_game()
