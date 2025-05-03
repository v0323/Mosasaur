extends Node3D
var lookat = Vector3(0 ,4.5, 5)
var play = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if FileAccess.file_exists("res://scarysave.game") == true:
		var savefile = FileAccess.open("res://scarysave.game",FileAccess.READ)
		var json_string = savefile.get_line()
		var json = JSON.new()
		json.parse(json_string)
		var savedata = json.get_data()
		Global.firstlaunch = savedata["firstlaunch"]
		Global.username = savedata["username"]
		Global.dialoguearea = savedata["dialoguearea"]
		Global.mousesensitivity = savedata["mousesensitivity"]
		Global.volume = savedata["volume"]
		Global.highscores = savedata["highscores"]
	if Global.firstlaunch == false:
		$Control/LineEdit.queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$boat2/boat.mesh.surface_set_material(0,load("res://assets/boatmaterial.tres"))
	$boat2/ladder.mesh.surface_set_material(0,load("res://assets/laddermaterial.tres"))
	get_tree().paused = false
	$Control/Label3.text = "HIGH SCORES:"
	for highscore in Global.highscores:
		$Control/Label3.text += str("
		",highscore,": ",Global.highscores.get(highscore))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$Control/MouseSensitivity.value = Global.mousesensitivity
	$Control/Volume.value = Global.volume
	if is_nan(linear_to_db(Global.volume * 2)) == false:
		$AudioStreamPlayer.volume_db = linear_to_db(Global.volume * 2)
	if Input.is_action_pressed("interact"):
		if Rect2($Control/MouseSensitivity.position.x - 5,$Control/MouseSensitivity.position.y,$Control/MouseSensitivity.size.x + 10,$Control/MouseSensitivity.size.y).has_point($Control.get_local_mouse_position()):
			Global.mousesensitivity = ($Control.get_local_mouse_position().x - 40) / 200
		if Rect2($Control/Volume.position.x - 5,$Control/Volume.position.y,$Control/Volume.size.x + 10,$Control/Volume.size.y).has_point($Control.get_local_mouse_position()):
			Global.volume = ($Control.get_local_mouse_position().x - 40) / 200
	if play == true:
		var cameraquaternion = Quaternion($Camera3D.basis)
		var lookatquaternion = $Camera3D.transform.looking_at(lookat).basis.get_rotation_quaternion()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		$Camera3D.basis = cameraquaternion.slerp(lookatquaternion,0.1)
		$Camera3D.global_position = $Camera3D.global_position.move_toward(Vector3(0,4.5,0),0.5)
		if $AudioStreamPlayer.volume_db >= -20:
			$AudioStreamPlayer.volume_db -= 0.1
		if $Camera3D.rotation_degrees.y >= 179:
			get_tree().change_scene_to_file("res://level_1.tscn")
func _on_play_pressed() -> void:
	$Control.visible = false
	play = true
func _on_quit_pressed() -> void:
	get_tree().quit()
func _on_how_to_play_toggled(toggled_on: bool) -> void:
	if $Control/Label3.visible == true:
		$Control/Label3.visible = false
		$Control/HighScores.button_pressed = false
	$Control/Label2.visible = toggled_on
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on == false:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
func _on_high_scores_toggled(toggled_on: bool) -> void:
	if $Control/Label2.visible == true:
		$Control/Label2.visible = false
		$"Control/How To Play".button_pressed = false
	$Control/Label3.visible = toggled_on
func _on_line_edit_text_submitted(new_text: String) -> void:
	Global.username = new_text
	if new_text.is_empty():
		Global.username = "Carlos"
	$Control/LineEdit.queue_free()
	Global.firstlaunch = false
func _on_submit_pressed() -> void:
	Global.username = $Control/LineEdit.text
	if $Control/LineEdit.text.is_empty():
		Global.username = "Carlos"
	$Control/LineEdit.queue_free()
	Global.firstlaunch = false
func _on_alert_toggled(toggled_on: bool) -> void:
	Global.visual = toggled_on
