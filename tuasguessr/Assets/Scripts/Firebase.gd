extends Node
class_name FireBaseScript

# --- Configuration ---
const FIREBASE_WEB_API_KEY = "AIzaSyBF7HoWY1ipOnEMAU133TvzTw_1Xly11l8"
const RTDB_BASE_URL = "https://wheretheamkamilb-default-rtdb.europe-west1.firebasedatabase.app"
const ANONYMOUS_SIGN_IN_URL = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=" + FIREBASE_WEB_API_KEY

# --- Internal State ---
var _id_token: String = ""
var _user_uid: String = ""
var _scoreboard_data: Dictionary = {}
var _pending_write_data: Dictionary = {}
var _last_etag: String = ""
var _etag_request: HTTPRequest
var etag_busy := false

# --- HTTPRequest Nodes ---
var _auth_request: HTTPRequest
var _read_request: HTTPRequest
var _write_request: HTTPRequest

# --- Signals ---
signal auth_completed(success: bool, id_token: String, user_uid: String)
signal scoreboard_read_completed(success: bool, data: Array, error_message: String)
signal score_write_completed(success: bool, key_or_error_message: String)
signal scoreboard_changed(new_data: Array)

func _ready():
	print("DEBUG: FireBaseScript in scene tree?", is_inside_tree())
	_auth_request = HTTPRequest.new()
	add_child(_auth_request)
	_auth_request.request_completed.connect(_on_auth_request_completed)

	_read_request = HTTPRequest.new()
	add_child(_read_request)
	_read_request.request_completed.connect(_on_read_request_completed)

	_write_request = HTTPRequest.new()
	add_child(_write_request)
	_write_request.request_completed.connect(_on_write_request_completed)
	
	_etag_request = HTTPRequest.new()
	add_child(_etag_request)
	_etag_request.request_completed.connect(_on_etag_request_completed)

	print("FirebaseManager: Initializing...")
	authenticate_anonymously()

# ---------------- AUTH ----------------
func authenticate_anonymously():
	if _auth_request.is_processing():
		print("FirebaseManager: Auth request already in progress.")
		return
	
	print("FirebaseManager: Sending anonymous authentication request...")
	var headers = ["Content-Type: application/json"]
	var body_json = JSON.stringify({"returnSecureToken": true})	
	var err = _auth_request.request(ANONYMOUS_SIGN_IN_URL, headers, HTTPClient.METHOD_POST, body_json)
	if err != OK:
		emit_signal("auth_completed", false, "Request init failed", "")

func _on_auth_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		_id_token = ""
		_user_uid = ""
		emit_signal("auth_completed", false, "HTTP Error: " + str(result), "")
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if not (json is Dictionary):
		emit_signal("auth_completed", false, "JSON Parse Error", "")
		return

	if response_code >= 200 and response_code < 300:
		_id_token = json.get("idToken", "")
		_user_uid = json.get("localId", "")
		print("FirebaseManager: Auth OK, UID:", _user_uid)
		emit_signal("auth_completed", true, _id_token, _user_uid)

		if not _pending_write_data.is_empty():
			write_score_internal(_pending_write_data.username, _pending_write_data.points)
			_pending_write_data = {}
	else:
		var msg = json.get("error", {}).get("message", "Unknown error")
		emit_signal("auth_completed", false, msg, "")

# ---------------- READ ----------------
func read_scoreboard():
	var url = RTDB_BASE_URL + "/scoreboard.json?orderBy=\"points\"&limitToLast=10"
	print("READ URL =", url)
	print("DEBUG: read_scoreboard() called")

	if _read_request.is_processing():
		print("FIREBASE: Previous request processing, cancelling request")
		_read_request.cancel_request()

	

	var err = _read_request.request(url, [], HTTPClient.METHOD_GET)
	print("DEBUG: HTTP request started =", err)
	if err != OK:
		emit_signal("scoreboard_read_completed", false, [], "Request init failed")

func _on_read_request_completed(result, response_code, headers, body):
	print("DEBUG: _on_read_request_completed triggered")
	var response_body_string = body.get_string_from_utf8()
	print("DEBUG RAW READ =", response_body_string)
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("scoreboard_read_completed", false, [], "HTTP Error: " + str(result))
		return

	var json = JSON.parse_string(response_body_string)

	if not (json is Dictionary):
		if response_body_string.strip_edges() == "null" or response_body_string.strip_edges().is_empty():
			emit_signal("scoreboard_read_completed", true, [], "")
			return

		emit_signal("scoreboard_read_completed", false, [], "JSON Parse Error")
		return

	_scoreboard_data = json
	var arr = convert_and_sort_scoreboard(_scoreboard_data)

	print("DEBUG: emitting signal scoreboard_read_completed")
	emit_signal("scoreboard_read_completed", true, arr, "")
	#print("FirebaseManager: Scoreboard OK, sorted:", arr)
	emit_signal("scoreboard_changed", arr)

# Converts Firebase dictionary → sorted array
func convert_and_sort_scoreboard(data: Dictionary) -> Array:
	var arr: Array = []

	for key in data.keys():
		var item = data[key]
		if item is Dictionary:
			item["key"] = key
			arr.append(item)

	arr.sort_custom(Callable(self, "_sort_score_descending"))
	return arr

func _sort_score_descending(a, b):
	return b["points"] < a["points"]

func _get_cached_scoreboard_data() -> Dictionary:
	return _scoreboard_data
func _get_scoreboard_array() -> Array:
	var arr = convert_and_sort_scoreboard(_scoreboard_data)
	return arr
	
# ---------------- WRITE ----------------
func write_score(username: String, points: int):
	if _id_token.is_empty():
		_pending_write_data = {"username": username, "points": points}
		authenticate_anonymously()
		emit_signal("score_write_completed", false, "Auth required")
		return
	
	write_score_internal(username, points)

func write_score_internal(username: String, points: int):
	var url = RTDB_BASE_URL + "/scoreboard.json?auth=" + _id_token
	#print("WRITE URL =", url)
	print("DEBUG: write_score_internal:", username, points)
	if _write_request.is_processing():
		emit_signal("score_write_completed", false, "Write already in progress.")
		return
	
	var headers = ["Content-Type: application/json"]
	var score_data = {
		"username": username,
		"points": points,
		"uid": _user_uid,
		"timestamp": Time.get_datetime_string_from_unix_time(Time.get_unix_time_from_system())
	}
	
	var body_json = JSON.stringify(score_data)
	print("DEBUG WRITE BODY =", body_json)
	print("DEBUG WRITE BODY PARSED =", score_data)
	var err = _write_request.request(url, headers, HTTPClient.METHOD_POST, body_json)

	if err != OK:
		emit_signal("score_write_completed", false, "Request init failed")

func _on_write_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print("WRITE COMPLETED:", response_code, json)
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("score_write_completed", false, "HTTP Error: " + str(result))
		return

	if response_code >= 200 and response_code < 300:
		var new_key = ""
		if json is Dictionary:
			new_key = json.get("name", "")
			emit_signal("score_write_completed", true, new_key)
	else:
		var err = "Unknown error"
		if json is Dictionary:
			err = json.get("error", "Unknown error")
			if err is Dictionary and err.has("message"):
				err = err["message"]
		
		emit_signal("score_write_completed", false, err)
		
		if response_code == 401:
			authenticate_anonymously()
			
func get_scoreboard_data(callback: Callable):
	scoreboard_read_completed.connect(callback)
	read_scoreboard()

func check_scoreboard_for_updates():
	await get_tree().process_frame
	OS.delay_msec(1)
	if etag_busy:
		return    # estää loopin
	etag_busy = true
	if _etag_request.is_processing():
		print("Firebase: ETag request skipped (busy)")
		return
	
	var url = RTDB_BASE_URL + "/scoreboard.json"
	
	# Pyydetään pelkkä ETag ilman dataa
	var headers = [
		"X-Firebase-ETag: true",
    	"Content-Type: application/json"
]

	var err = _etag_request.request(url, headers, HTTPClient.METHOD_GET, "")
	if err != OK:
		print("Firebase: ETag request failed:", err)
		print("ERR:", err, " → ", error_string(err))
		etag_busy = false

func _on_etag_request_completed(result, response_code, headers, body):
	while _read_request.is_processing():
		print("ETAG: Waiting for previous request to finish")
		await get_tree().process_frame
	
	# Pieni viive web-version vuoksi
	await get_tree().create_timer(0.05).timeout
	
	print("ETag request completed, safe to continue")
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Firebase: ETag request error:", result)
		return

	var new_etag := ""
	for h in headers:
		if h.begins_with("ETag:"):
			new_etag = h.replace("ETag: ", "").strip_edges()
			break

	if new_etag == "":
		print("Firebase: No ETag returned")
		return

	# Ensimmäinen kerta: pelkkä tallennus, ei signaalia
	if _last_etag == "":
		_last_etag = new_etag
		return

	# Muuttuiko ETag?
	if new_etag != _last_etag:
		print("Firebase: Scoreboard changed!")
		_last_etag = new_etag

		# Nyt haetaan päivitetty data ja emit_signal
		read_scoreboard()

		# read_scoreboard() lopulta kutsuu _on_read_request_completed,
		# jonka lopussa lisäämme signaalin:
		# emit_signal("scoreboard_changed", array_data)
	else:
		print("Firebase: No changes detected.")
	etag_busy = false

func console(text):
	Game.Active.console(text)
