extends Node2D

class_name Leaderboard

@onready var loading = find_child("Loading", true, false)
@onready var box = find_child("VBoxContainer", true, false)

func _ready():
	visible = false
	# Show loading immediately
	if loading:
		loading.show()

	# Hide old tags so UI doesn’t flicker
	hide_scoretags()



# ----------------------------------------------------------------
# SET DATA (UI UPDATE)
# ----------------------------------------------------------------
func set_data(dat: Array):
	var created_tags: Array = []
	visible = true
	# 1) Show loading while clearing
	if loading:
		loading.visible = true

	# Wait 1 frame → required for web to update UI state
	await get_tree().process_frame

	# 2) Remove only scoretags (not loading)
	for child in box.get_children():
		if child != loading :
			child.queue_free()

	# 3) OPTIONAL: hide loading BEFORE rendering new tags
	#	(or move to AFTER tags if you want loading to stay during animation)
	hide_loading()
	

		
	
	
	# 4) Build scoretags
	var num := 1
	for entry in dat:
		# Web benefits from slight delay
		await get_tree().create_timer(0.05).timeout

		var name = entry.get("username", "Unknown")
		var pts = entry.get("points", 0)

		var tag = load("res://Resource Scenes/scoretag.tscn").instantiate()
		print(tag.get_tree_string())
		tag.text = str(num) + ". " + name + " : " + str(pts)
		
		# ⭐ TALLENNA TIMESTAMP meta-dataan ⭐
		var ts_raw = entry.get("timestamp", "")
		var ts = Time.get_unix_time_from_datetime_string(ts_raw)
		tag.set_meta("timestamp", ts)

		
		num += 1
		await get_tree().process_frame

		# --- NEW: Color the newest one ---
		
		box.add_child(tag)
		# Lisää listaan
		created_tags.append(tag)
		
	highlight_latest_timestamp()
# ----------------------------------------------------------------
# LOADING HELPERS
# ----------------------------------------------------------------
func hide_loading():
	if loading:
		loading.visible = false
		
func show_loading():
	if loading:
		loading.visible = true


func hide_scoretags():
	for child in box.get_children():
		if child != loading:
			child.visible = false
			
func highlight_latest_timestamp():
	# 1) Tyhjä lista → ei tehdä mitään
	var tags: Array = []

	for child in box.get_children():
		if child != loading and child.has_meta("timestamp"):
			tags.append(child)

	if tags.is_empty():
		return

	var max_ts := -INF
	var max_tag = null

	for tag in tags:
		var ts = tag.get_meta("timestamp")
		if ts > max_ts:
			max_ts = ts
			max_tag = tag

	for tag in tags:
		tag.self_modulate = Color.BLACK

	if max_tag:
		max_tag.self_modulate = Color(0.664, 0.003, 0.028, 1.0)
