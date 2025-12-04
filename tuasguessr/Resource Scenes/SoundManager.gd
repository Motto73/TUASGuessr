extends Node

func play_button_normal():
	$Button.pitch_scale = 1.5
	$Button.play()
	

func play_roulette():
	$Roulette.play()
	
func play_roulette_speed(pitch: float):
	$Roulette.pitch_scale = pitch
	$Roulette.play()
	
func stop_roulette_sound():
	$Roulette.stop()

func play_level_sound():
	$Lever.play()
