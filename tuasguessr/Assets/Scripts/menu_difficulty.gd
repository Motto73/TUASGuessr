extends Node2D

var diff = ""
@onready var accept : Button = $Control/Accept

@onready var game : Game = $".."

func _on_ez_button_down():
	SetDiff("easy")


func _on_medium_button_down():
	SetDiff("medium")


func _on_hard_button_down():
	SetDiff("hard")


func _on_hard_2_button_down():
	SetDiff("hard2")

func SetDiff(name):
	diff = name
	accept.disabled = false;


func _on_accept_button_down():
	if (diff != ""):
		game.setDifficulty(diff)
