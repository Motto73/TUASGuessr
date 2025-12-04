extends Node

var roulette_speed =$Roulette.pitch_scale

func play_button_normal():
	$Button.pitch_scale = 1.5
	$Button.play()
	

func play_roulette():
	$Roulette.play()
	
func set_roulette_sound_speed(pitch: float):
	roulette_speed = pitch

func stop_roulette_sound():
	$Roulette.stop()

func play_lever_sound():
	$Lever.play()
