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
	print("Spawned leaderboard popup")
	submit.disabled = false
	load_leaderboard()


func set_points(pts):
	points = pts
	pointsield.text = "Your points:\n" + str(points)


# ------------------------
# INITIAL LOAD (NOT SUBMIT)
# ------------------------
func load_leaderboard():
	print("Requesting scoreboard...")
	#widget.show_loading()    # ← tärkeä
	# Yhdistä signaali vain kerran
	if not Firebase.scoreboard_read_completed.is_connected(_on_leaderboard_ready):
		Firebase.scoreboard_read_completed.connect(_on_leaderboard_ready)

	Firebase.read_scoreboard()


func _on_leaderboard_ready(success: bool, data: Array, error: String):
	# -------------------------
	# DISCONNECT IMMEDIATELY !!!
	# -------------------------
	if Firebase.scoreboard_read_completed.is_connected(_on_leaderboard_ready):
		Firebase.scoreboard_read_completed.disconnect(_on_leaderboard_ready)

	if success:
		widget.set_data(data)
	else:
		print("Error setting data")
		

# ------------------------
# SUBMIT SCORE
# ------------------------
func _on_submit_pressed():
	submit.disabled = true
	namefield.editable = false

	# --- NÄYTÄ LATAUS HETI ---
	if widget:
		widget.show_loading()
		widget.hide_scoretags()
		await get_tree().process_frame
		await get_tree().process_frame	# web tarvitsee tämän

	# --- 1) YKSI pre-read vain webin vuoksi ---
	Firebase.read_scoreboard()

	var before = await Firebase.scoreboard_read_completed
	# before = (success, data, error)

	# --- 2) Kirjoita piste ---
	Game.Active.actualGame.post_score(username)

	# --- 3) Odota että kirjoitus valmistuu ---
	var write_result = await Firebase.score_write_completed
	# write_result = (success, new_key / error)

	# --- 4) Lue scoreboard uudelleen ---
	Firebase.read_scoreboard()

	var after = await Firebase.scoreboard_read_completed
	var success = after[0]
	var newdata = after[1]
	var errmsg = after[2]

	# --- 5) Päivitä UI ---
	if success:
		widget.set_data(newdata)
	else:
		print("Error updating scoreboard:", errmsg)

	print("Leaderboard updated after submit")

	disable_submit()



func disable_submit():
	submit.disabled = true
	namefield.editable = false

func _on_new_game_pressed():
	actualgame.new_game()
	submit.disabled = false
	namefield.editable = true

func _on_namefield_text_changed():
	if len(namefield.text) > 0 and len(namefield.text) <= 10:
		submit.disabled = false
		username = namefield.text
	else:
		submit.disabled = true
