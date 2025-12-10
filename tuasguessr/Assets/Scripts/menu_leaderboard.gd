extends Node2D

class_name MenuLeaderboard

var points := 0
var username := ""

@onready var namefield := find_child("Namefield", true, false)
@onready var pointsield := find_child("Pointsfield", true, false)
@onready var submit := find_child("Submit", true, false)

@onready var widget : Leaderboard = find_child("Leaderboard", true, false)

var actualgame : ActualGame


func _ready():
	
	submit.disabled = false
	print("Leaderboard widget found:", widget)
	load_leaderboard()

func set_points(pts):
	points = pts
	pointsield.text = "Your points:\n" + str(points)

# ------------------------
# INITIAL LOAD
# ------------------------
func load_leaderboard():
	print("Requesting scoreboard...")

	# yhdistä signaali vain kerran
	if not Firebase.scoreboard_read_completed.is_connected(_on_leaderboard_ready):
		Firebase.scoreboard_read_completed.connect(_on_leaderboard_ready)

	Firebase.read_scoreboard()


func _on_leaderboard_ready(success: bool, data: Array, error: String):

	# disconnect ONCE → estää tuplat UI-päivityksen
	if Firebase.scoreboard_read_completed.is_connected(_on_leaderboard_ready):
		Firebase.scoreboard_read_completed.disconnect(_on_leaderboard_ready)

	if success:
		widget.set_data(data)
	else:
		print("Error setting data:", error)


# ------------------------
# SUBMIT SCORE
# ------------------------
func _on_submit_pressed():
	Sounds.play_switch()
	submit.disabled = true
	namefield.editable = false

	# --- SHOW LOADING UI ---
	widget.show_loading()
	widget.hide_scoretags()
	await get_tree().process_frame
	await get_tree().process_frame	# web tarvitsee nämä

	# 1) PRE-READ (web only)
	Firebase.read_scoreboard()
	var _before = await Firebase.scoreboard_read_completed

	# 2) WRITE SCORE
	Game.Active.actualGame.post_score(username)

	# 3) WAIT WRITE OK
	var _write_result = await Firebase.score_write_completed

	# 4) READ UPDATED LIST
	Firebase.read_scoreboard()
	var after = await Firebase.scoreboard_read_completed
	var success = after[0]
	var newdata = after[1]
	var errmsg  = after[2]

	# 5) APPLY UI
	if success:
		widget.set_data(newdata)
	else:
		print("Error updating scoreboard:", errmsg)
	
	disable_submit()



func disable_submit():
	submit.disabled = true
	namefield.editable = false

func _on_new_game_pressed():
	Sounds.play_switch()
	actualgame.new_game()
	submit.disabled = false
	namefield.editable = true

func _on_namefield_text_changed(new_text):
	if new_text.length() > 0 and new_text.length() <= 10:
		submit.disabled = false
		username = new_text
	else:
		submit.disabled = true

		
		
func hide_lb():
	visible = false
	widget.visible = false
	for child in get_children():
		child.visible = false
		
func show_lb():
	visible = true
	Sounds.stop_roulette_sound()
	Sounds.play_blop()
	widget.visible = true
	for child in get_children():
		child.visible = true
