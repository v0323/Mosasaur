extends Control
var canunpause = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		$Fullscreen.button_pressed = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$MouseSensitivity.value = Global.mousesensitivity
	$Volume.value = Global.volume
	get_parent().maxvolume = linear_to_db(Global.volume * 2)
	if Input.is_action_pressed("interact"):
		if Rect2($MouseSensitivity.position.x - 5,$MouseSensitivity.position.y,$MouseSensitivity.size.x + 10,$MouseSensitivity.size.y).has_point(get_local_mouse_position()):
			Global.mousesensitivity = (get_local_mouse_position().x - 40) / 200
		if Rect2($Volume.position.x - 5,$Volume.position.y,$Volume.size.x + 10,$Volume.size.y).has_point(get_local_mouse_position()):
			Global.volume = (get_local_mouse_position().x - 40) / 200
	if Input.is_action_just_released("pause") and Global.dialoguearea == null:
		canunpause = true
	if Input.is_action_just_pressed("pause") and canunpause == true and Global.dialoguearea == null:
		if Global.dialoguearea == null:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		canunpause = false
		visible = false
		get_tree().paused = false
func _on_resume_pressed() -> void:
	if Global.dialoguearea == null:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	visible = false
	get_tree().paused = false
func _on_quit_pressed() -> void:
	get_tree().quit()
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on == false:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
func _on_quit_2_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
