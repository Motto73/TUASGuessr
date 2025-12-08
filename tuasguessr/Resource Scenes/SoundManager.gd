extends Node

func _ready() -> void:
	set_roulette_sound_speed(1.0)

func play_button_normal():
	$Button.pitch_scale = 1.5
	$Button.play()

func stop_button_sound():
	$Button.stop()

func play_roulette():
	if $Roulette.pitch_scale == 1.0:
		await get_tree().create_timer(0.25).timeout
	$Roulette.play()
	
func set_roulette_sound_speed(pitch: float):
	$Roulette.pitch_scale = pitch

func stop_roulette_sound():
	await get_tree().create_timer(0.3).timeout
	$Roulette.stop()

func play_lever_sound():
	$Lever.play()
