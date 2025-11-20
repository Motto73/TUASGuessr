extends Node

var points = 0

# --- Configuration ---
const FIREBASE_WEB_API_KEY = "AIzaSyAS4AXH_fCMi63cHv3lqDwlubaorerHZhM"
const RTDB_BASE_URL = "https://wheretheamkami-default-rtdb.europe-west1.firebasedatabase.app" # Your RTDB instance URL
# Firebase Authentication REST API endpoint for anonymous sign-up/in
const ANONYMOUS_SIGN_IN_URL = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=" + FIREBASE_WEB_API_KEY

# --- Internal State ---
var _id_token: String = "" # Stores the Firebase ID Token for authenticated writes
var _user_uid: String = "" # Stores the Firebase User ID (UID)
var _scoreboard_data: Dictionary = {} # Stores the last successfully read scoreboard data

# --- HTTPRequest Nodes (one for each type of operation) ---
var _auth_request: HTTPRequest
var _read_request: HTTPRequest
var _write_request: HTTPRequest

# --- Signals (for communicating results back to your game logic) ---
signal auth_completed(success: bool, id_token_or_error: String, user_uid: String)
signal scoreboard_read_completed(success: bool, data_or_error: Variant)
signal score_write_completed(success: bool, key_or_error: String)
signal scoreboard_data_loaded(data_dict: Dictionary) # Keep this signal for notification

func _ready():
	get_tree().get_root().get_node("scene_actual_game/ActualGame")
	
	_auth_request = HTTPRequest.new()
	add_child(_auth_request)
	_auth_request.request_completed.connect(_on_auth_request_completed)
	_read_request = HTTPRequest.new()
	add_child(_read_request)
	_read_request.request_completed.connect(_on_read_request_completed)
	_write_request = HTTPRequest.new()
	add_child(_write_request)
	_write_request.request_completed.connect(_on_write_request_completed)

	# Start by authenticating anonymously when the manager is ready
	authenticate_anonymously()

#ANONYMOUS AUTHENTICATION FUNCTIONS
func authenticate_anonymously():
	if _auth_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return # Request already in progress
	var headers = ["Content-Type: application/json"]
	var body_data = {"returnSecureToken": true}
	var body_json = JSON.stringify(body_data)
	
	_auth_request.request(ANONYMOUS_SIGN_IN_URL, headers, HTTPClient.METHOD_POST, body_json)
	
func _on_auth_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		_id_token = "" #Clear token
		_user_uid = ""
		return
	var response_body_string = body.get_string_from_utf8()
	var json_result = JSON.parse_string(response_body_string)
	if json_result is Dictionary:
		if response_code >= 200 and response_code < 300:
			_id_token = json_result.get("idToken", "")
			_user_uid = json_result.get("localId", "")
		else:
			_id_token = ""
			_user_uid = ""

#  REALTIME DATABASE READ FUNCTIONS
func read_scoreboard():
	if _read_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	# No auth token needed for public reads
	var url = RTDB_BASE_URL + "/scoreboard.json?orderBy=\"points\"&limitToLast=20" #Fetches only top 20 points
	
	_read_request.request(url, [], HTTPClient.METHOD_GET)
	
func _on_read_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		_scoreboard_data = {} #Clear data on failure
		return
	var response_body_string = body.get_string_from_utf8()
	var json_result = JSON.parse_string(response_body_string)
	if response_code >= 200 and response_code < 300:
		if json_result is Dictionary or (json_result == null and response_code == 204):
			_scoreboard_data = json_result if json_result != null else {}
			emit_signal("scoreboard_data_loaded", _scoreboard_data) # Emit signal when data is ready
		else:
			_scoreboard_data = {}
	else:
		_scoreboard_data = {}
		
#Getter function
func get_scoreboard_data() -> Dictionary:
	return _scoreboard_data
	

# REALTIME DATABASE WRITE FUNCTIONS
func write_score(username: String, score: int):
	if _id_token.is_empty():
		return
	if _write_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	
	var url = RTDB_BASE_URL + "/scoreboard.json?auth=" + _id_token
	var headers = ["Content-Type: application/json"]
	var score_data = {"username": username, "points": points}
	
	var body_json = JSON.stringify(score_data)
	_write_request.request(url, headers, HTTPClient.METHOD_POST, body_json)
	
func _on_write_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		return
	if response_code == 401: # Unauthorized, often due to expired token
		authenticate_anonymously()
		return
