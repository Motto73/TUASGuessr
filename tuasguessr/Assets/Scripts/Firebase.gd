extends Node

# ---------------- CONFIG ----------------
const FIREBASE_WEB_API_KEY = "AIzaSyBF7HoWY1ipOnEMAU133TvzTw_1Xly11l8"
const RTDB_BASE_URL = "https://wheretheamkamilb-default-rtdb.europe-west1.firebasedatabase.app"
const ANON_URL = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=" + FIREBASE_WEB_API_KEY

# ---------------- STATE ----------------
var _id_token: String = ""
var _user_uid: String = ""
var _is_web := false
var _is_authenticated := false
var _is_auth_in_progress := false
var _pending_write: Dictionary = {}
var _scoreboard_cache: Dictionary = {}

# ---------------- HTTPREQUEST ----------------
var _auth_request: HTTPRequest
var _read_request: HTTPRequest
var _write_request: HTTPRequest

# ---------------- SIGNALS ----------------
signal auth_completed(success: bool, id_token: String, user_uid: String)
signal scoreboard_read_completed(success: bool, data: Array, error_message: String)
signal score_write_completed(success: bool, msg: String)
signal scoreboard_changed(new_data: Array)

# =====================================================
# READY
# =====================================================

func _ready():
	print("FirebaseManager READY")
	_is_web = OS.get_name() == "Web"
	print("Platform:", OS.get_name())

	_auth_request = HTTPRequest.new()
	add_child(_auth_request)
	_auth_request.request_completed.connect(_on_auth_native)

	_read_request = HTTPRequest.new()
	add_child(_read_request)
	_read_request.request_completed.connect(_on_read)

	_write_request = HTTPRequest.new()
	add_child(_write_request)
	_write_request.request_completed.connect(_on_write)

	_auth_request.timeout = 30
	_read_request.timeout = 30
	_write_request.timeout = 30

	authenticate_anonymous()

# =====================================================
# AUTH ENTRY
# =====================================================

func authenticate_anonymous():
	if _is_authenticated: return
	if _is_auth_in_progress: return

	if _is_web:
		_auth_web()
	else:
		_auth_native()

# =====================================================
# NATIVE AUTH
# =====================================================

func _auth_native():
	_is_auth_in_progress = true

	if _auth_request.is_processing():
		_auth_request.cancel_request()

	print("Auth (Native) starting...")

	var headers = [
		"Content-Type: application/json",
		"Accept-Encoding: identity"
	]

	var body = JSON.stringify({"returnSecureToken": true})

	var err = _auth_request.request(ANON_URL, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		emit_signal("auth_completed", false, "Request init failed", "")
		_is_auth_in_progress = false

func _on_auth_native(result, code, _headers, body):
	_is_auth_in_progress = false

	print("*** AUTH CALLBACK NATIVE ***")

	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("auth_completed", false, "HTTP Error", "")
		return

	var txt = body.get_string_from_utf8()
	print("BODY RAW:", txt)

	var dict = JSON.parse_string(txt)
	if dict is Dictionary:
		_handle_auth(dict)
	else:
		emit_signal("auth_completed", false, "Invalid JSON", "")

# =====================================================
# WEB AUTH (window-poll)
# =====================================================

func _auth_web():
	_is_auth_in_progress = true

	print("Web AUTH starting via JavaScript...")

	JavaScriptBridge.eval("""
		window.firebaseAuthResult = null;
		fetch('%s', {
			method: 'POST',
			headers: {'Content-Type': 'application/json'},
			body: JSON.stringify({ returnSecureToken: true })
		})
		.then(r => r.json())
		.then(j => window.firebaseAuthResult = JSON.stringify(j))
		.catch(e => window.firebaseAuthResult = JSON.stringify({error:String(e)}));
	""" % ANON_URL)

	_poll_web_auth()

func _poll_web_auth():
	print("Polling web auth...")

	var start := Time.get_ticks_msec()

	while Time.get_ticks_msec() - start < 8000:	# pollaa 8s
		await get_tree().process_frame

		var jsVal = JavaScriptBridge.eval("window.firebaseAuthResult")
		if jsVal == null or jsVal == "null":
			continue

		print("*** GOT WEB AUTH RESULT ***")
		print(jsVal)

		JavaScriptBridge.eval("window.firebaseAuthResult = null")

		var dict = JSON.parse_string(str(jsVal))
		if dict is Dictionary:
			_handle_auth(dict)
		else:
			emit_signal("auth_completed", false, "Invalid JSON", "")

		_is_auth_in_progress = false
		return

	print("Web auth timeout")
	emit_signal("auth_completed", false, "Web auth timeout", "")
	_is_auth_in_progress = false

# =====================================================
# COMMON AUTH LOGIC
# =====================================================

func _handle_auth(json: Dictionary):
	var idt = json.get("idToken", "")
	var uid = json.get("localId", "")

	if idt == "" or uid == "":
		var msg = "Auth failed"
		if json.has("error"):
			var e = json["error"]
			if e is Dictionary and e.has("message"):
				msg = e["message"]
			elif e is String:
				msg = e

		print("AUTH ERROR:", msg)
		emit_signal("auth_completed", false, msg, "")
		return

	_id_token = idt
	_user_uid = uid
	_is_authenticated = true

	print("AUTH OK → UID:", _user_uid)

	emit_signal("auth_completed", true, _id_token, _user_uid)

	if not _pending_write.is_empty():
		write_score_internal(_pending_write.username, _pending_write.points)
		_pending_write.clear()

# =====================================================
# READ SCOREBOARD
# =====================================================

func read_scoreboard():
	if _read_request.is_processing():
		_read_request.cancel_request()

	var url = RTDB_BASE_URL + "/scoreboard.json?orderBy=%22points%22&limitToLast=10"

	var err = _read_request.request(url)
	if err != OK:
		emit_signal("scoreboard_read_completed", false, [], "Init failed")

func _on_read(result, code, _headers, body):
	var txt = body.get_string_from_utf8()
	var json = JSON.parse_string(txt)

	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("scoreboard_read_completed", false, [], "HTTP Error")
		return

	if not (json is Dictionary):
		emit_signal("scoreboard_read_completed", true, [], "")
		return

	_scoreboard_cache = json
	var arr = _convert_and_sort(json)

	emit_signal("scoreboard_read_completed", true, arr, "")
	emit_signal("scoreboard_changed", arr)

func _convert_and_sort(data: Dictionary) -> Array:
	var arr: Array = []
	for key in data.keys():
		var item = data[key]
		if item is Dictionary:
			item["key"] = key
			arr.append(item)
	arr.sort_custom(Callable(self, "_sort_desc"))
	return arr

func _sort_desc(a, b):
	return b["points"] < a["points"]

# =====================================================
# WRITE SCORE
# =====================================================

func write_score(username: String, points: int):
	if not _is_authenticated:
		_pending_write = { "username": username, "points": points }
		authenticate_anonymous()
		return

	write_score_internal(username, points)

func write_score_internal(username: String, points: int):
	var url = RTDB_BASE_URL + "/scoreboard.json?auth=" + _id_token

	if _write_request.is_processing():
		_write_request.cancel_request()

	var headers = ["Content-Type: application/json"]

	var payload = {
		"username": username,
		"points": points,
		"uid": _user_uid,
		"timestamp": Time.get_datetime_string_from_unix_time(Time.get_unix_time_from_system())
	}

	var body = JSON.stringify(payload)
	_write_request.request(url, headers, HTTPClient.METHOD_POST, body)

func _on_write(result, code, _headers, body):
	var txt = body.get_string_from_utf8()
	var json = JSON.parse_string(txt)

	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("score_write_completed", false, "HTTP Error")
		return

	if code >= 200 and code < 300:
		var key = ""
		if json is Dictionary:
			key = json.get("name", "")
		emit_signal("score_write_completed", true, key)
		return

	var msg = "Unknown error"
	if json is Dictionary and json.has("error"):
		var e = json["error"]
		if e is Dictionary and e.has("message"):
			msg = e["message"]
		elif e is String:
			msg = e

	emit_signal("score_write_completed", false, msg)
