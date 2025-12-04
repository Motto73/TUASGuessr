extends Node2D

func _on_play_button_down():
	Sounds.play_button_normal()
	Game.Active.startGame()
