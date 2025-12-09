extends Node

func _ready() -> void:
	set_roulette_sound_speed(1.0)
	$Main_intro.volume_db = $Main.volume_db

func play_button_normal():
	$Button.pitch_scale = 1.5
	$Button.play()

func stop_button_sound():
	$Button.stop()

func play_roulette():
	if $Roulette.pitch_scale == 1.0:
		await get_tree().create_timer(0.25).timeout
	$Roulette.play()
	
func play_intro():
	$Main.stop()
	$Intro.play()

func play_main():
	$Main.stop()
	$Intro.stop()
	$Main_intro.play()
	var check = $Main_intro.finished
	if not check.is_connected(_on_main_intro_finished):
		$Main_intro.finished.connect(_on_main_intro_finished)

func _on_main_intro_finished():
	$Main.play()
	
func play_item_sound():
	$Item.play()
	
func play_error_sound():
	var current_pos = $Error.get_playback_position()
	var playing = $Error.playing
	if $Error.has_stream_playback() == false:
		$Error.play()
	
	elif current_pos >= 0.5:
		$Error.play()

func play_switch():
	$Map_switch.play(0.13)
	
func play_blop():
	$Blop.play()

func set_roulette_sound_speed(pitch: float):
	$Roulette.pitch_scale = pitch

func stop_roulette_sound():
	await get_tree().create_timer(0.3).timeout
	$Roulette.stop()

func play_lever_sound():
	$Lever.play()
