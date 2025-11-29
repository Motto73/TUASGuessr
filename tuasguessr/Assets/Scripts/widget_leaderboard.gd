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
		await get_tree().create_timer(0.1).timeout

		var name = entry.get("username", "Unknown")
		var pts = entry.get("points", 0)

		var tag = load("res://Resource Scenes/scoretag.tscn").instantiate()
		tag.text = str(num) + ". " + name + " : " + str(pts)
		num += 1
		await get_tree().process_frame
		box.add_child(tag)


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
