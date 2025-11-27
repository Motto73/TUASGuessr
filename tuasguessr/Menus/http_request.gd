extends HTTPRequest

class_name Scoreboard_request

var SUPABASE_URL = "https://ryvnxggsqampbcehxmfy.supabase.co"
var SUPABASE_KEY = "sb_publishable_wcBNH0JerlDTPxMp98q5Aw_cUO6gkAE"

@export var lb_ui_path: NodePath
@onready var lb_ui := get_node(lb_ui_path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func submit_score(username: String, score: int):
	var url = SUPABASE_URL + "/rest/v1/scores"
	var headers = [
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY,
		"Content-Type: application/json"
	]
	var body = {
	"username": username,
	"score": score
	}
	request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))

func get_scores():
	var url = SUPABASE_URL + "/rest/v1/scores?select=player_name,score&order=score.desc&limit=10"
	var headers = [
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY
	]
	request(url, headers, HTTPClient.METHOD_GET)

func _on_HTTPRequest_completed(result: int, code: int, headers: PackedStringArray, body: PackedByteArray):
	var json_table = body.get_string_from_utf8()
	var table = JSON.parse_string(json_table)
	
	if typeof(table) == TYPE_ARRAY:
		print("--- LEADERBOARD ---")
		for entry in table:
			print("%s  -  %d" % [entry.player_name, entry.score])
	if lb_ui:
		await lb_ui.set_data(table)
