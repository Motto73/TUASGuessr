extends Node

func play_button_normal():
	$Button.pitch_scale = 1.5
	$Button.play()

func stop_button_sound():
	$Button.stop()

func play_roulette():
	await get_tree().create_timer(0.3).timeout
	$Roulette.play()
	
func set_roulette_sound_speed(pitch: float):
	$Roulette.pitch_scale = pitch

func stop_roulette_sound():
	await get_tree().create_timer(0.3).timeout
	$Roulette.stop()

func play_lever_sound():
	$Lever.play()
