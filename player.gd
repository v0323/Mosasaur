extends CharacterBody3D
const SPEED = 10.0
const JUMP_VELOCITY = 5
const SINK_VELOCITY = 7
var maxvolume = -10
var gravity = Vector3(0,-1,0) * 9.8
var location = null
var underwater = false
var dialogue = 0
var choice = false
var choiceid = null
var choiceindex = null
var dinosaurlevel = 0
var noticed = false
var itemsfound = 0
var money = 0
var survived = true
var areaname = null
var time = 0
func _ready() -> void:
	maxvolume = linear_to_db(Global.volume * 0.8)
	$AudioStreamPlayer.volume_db = maxvolume
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_parent().get_node("boat2/boat/").mesh.surface_set_material(0,load("res://assets/boatmaterial.tres"))
	get_parent().get_node("boat2/ladder/").mesh.surface_set_material(0,load("res://assets/laddermaterial.tres"))
	global_rotation_degrees = Vector3(0,-180,0)
	for item in get_parent().get_node("Items").get_children():
		for object in item.get_children():
			object.mesh.surface_set_material(0,load(str("res://assets/",object.name,"material.tres")))
			object.get_child(0).set_collision_layer_value(2,true)
		var itemlocation = MeshInstance2D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 20
		sphere.height = 40
		itemlocation.mesh = sphere
		$Control/TextureRect/Control.add_child(itemlocation)
		itemlocation.position = Vector2(-item.global_position.x*5.12,-item.global_position.z*5.12)
		itemlocation.name = item.name
	var boatlocation = MeshInstance2D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 20
	sphere.height = 40
	boatlocation.mesh = sphere
	$Control/TextureRect/Control.add_child(boatlocation)
	boatlocation.modulate = Color(Color.BLUE)
	boatlocation.position = Vector2(0,-68.26)
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += gravity * delta
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not Rect2(Vector2(-100,-100),Vector2(200,200)).has_point(Vector2(global_position.x,global_position.z)):
		noticed = true
	if global_position.y > -10:
		noticed = true
	$Control/TextureRect/Control/playerlocation.position = Vector2(-global_position.x * 5.12, -global_position.z * 5.12)
	$Control/TextureRect/Control/playerlocation.rotation_degrees = -rotation_degrees.y
	$Control/Label2.text = str("Money: ",money,"
	","Time: ",time)
	if direction:
		$Area3D/CollisionShape3D.shape.radius = 30
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if underwater == true:
			velocity.y = $Camera3D.rotation_degrees.x/20
			if Input.is_action_pressed("jump"):
				velocity.y += JUMP_VELOCITY
			if Input.is_action_pressed("sink"):
				velocity.y -= SINK_VELOCITY
	else:
		$Area3D/CollisionShape3D.shape.radius = 0.5
		dinosaurlevel -= 1
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if underwater == true:
			velocity.y = -2
			if Input.is_action_pressed("jump"):
				velocity.y += JUMP_VELOCITY
			if Input.is_action_pressed("sink"):
				velocity.y -= SINK_VELOCITY
	if $Camera3D.rotation_degrees.x > 90:
		$Camera3D.rotation_degrees.x = 90
	if $Camera3D.rotation_degrees.x < -90:
		$Camera3D.rotation_degrees.x = -90
	if global_position.y < -2:
		underwater = true
		get_parent().get_node("WorldEnvironment").get_environment().fog_enabled = true
		for item in get_parent().get_children():
			if item.is_in_group("alwaysvisible") == false:
				if item.global_position.y > 0:
					item.visible = false
				if item.global_position.y <= 0:
					item.visible = true
	if global_position.y >= -2:
		underwater = false
		get_parent().get_node("WorldEnvironment").get_environment().fog_enabled = false
		for item in get_parent().get_children():
			if item.is_in_group("alwaysvisible") == false:
				if item.global_position.y > 0:
					item.visible = true
				if item.global_position.y <= 0:
					item.visible = false
	if get_parent().get_node("Game Over/Camera3D").current == true:
		get_parent().get_node("WorldEnvironment").get_environment().fog_enabled = false
		for item in get_parent().get_children():
			if item.is_in_group("alwaysvisible") == false:
				if item.global_position.y > 0:
					item.visible = true
				if item.global_position.y <= 0:
					item.visible = false
	location = global_position
	move_and_slide()
	$AudioStreamPlayer.volume_db = maxvolume
	if Global.dialoguearea != null:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		global_position = location
		$Dialogue.visible = true
		$Control.visible = false
		if $Dialogue/Label.visible_characters != $Dialogue/Label.text.length():
			$Dialogue/Label.visible_characters += 1
		if choice == false:
			if choiceid != null:
				$Dialogue/Label.visible_characters = 0
				var text1 = Global.dialogue[Global.dialoguearea][0]
				var text2 = str(Global.dialogue[Global.dialoguearea][dialogue]).format([Global.username])
				$Dialogue/Label.text = str(text1,": ",text2)
				choiceid = null
			if Input.is_action_just_pressed("enter"):
				dialogue += 1
				$Dialogue/Label.visible_characters = 0
				if dialogue != Global.dialogue[Global.dialoguearea].size():
					if choiceindex != null:
						if dialogue == Global.dialogue[str(Global.dialoguearea,"ChoiceLocation")][choiceindex]:
							dialogue = Global.dialogue[str(Global.dialoguearea,"ChoiceLocation")][0]
							choiceindex = null
					var text1 = Global.dialogue[Global.dialoguearea][0]
					var text2 = str(Global.dialogue[Global.dialoguearea][dialogue]).format([Global.username])
					if text2.begins_with("?") == true:
						text2 = text2.erase(0)
						$Dialogue/Label.text = str(text1,": ",text2)
						$Dialogue/ItemList.visible = true
						choice = true
					$Dialogue/Label.text = str(text1,": ",text2)
				if dialogue == Global.dialogue[Global.dialoguearea].size():
					choiceindex = null
					$Dialogue.visible = false
					$Control.visible = true
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
					Global.dialoguearea = null
		if choice == true:
			if $Dialogue/ItemList.item_count == 0:
				for textchoice in Global.dialogue[str(Global.dialoguearea,"Choices")]:
					$Dialogue/ItemList.add_item(textchoice)
			if choiceid != null:
				dialogue = choiceid
				choice = false
	if underwater == true:
		if $Timer.is_stopped():
			$Timer.start()
		if noticed == true:
			if $AudioStreamPlayer3D.playing == false:
				$AudioStreamPlayer3D.volume_db = 20
				$AudioStreamPlayer3D.play()
				if Global.visual == true:
					$Control/Label3.visible = true
		if noticed == false:
			$Control/Label3.visible = false
	if $Camera3D/RayCast3D.is_colliding():
		if $Camera3D/RayCast3D.get_collider() != null:
			if $Camera3D/RayCast3D.get_collider().get_parent().get_parent().get_parent().name == "Items":
				var itemsplit = $Camera3D/RayCast3D.get_collider().get_parent().get_parent().name.split(",")
				$Control/Label.text = itemsplit[0]
	if $Camera3D/RayCast3D.is_colliding() == false and areaname == null:
		$Control/Label.text = ""
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotation_degrees.y -= event.relative.x * Global.mousesensitivity
			$Camera3D.rotation_degrees.x -= event.relative.y * Global.mousesensitivity
	if event.is_action_pressed("interact"):
		if areaname != null:
			if areaname == "boat2":
				$AudioStreamPlayer.play()
				global_position = Vector3(0,-23, 20)
				areaname = null
				get_parent().get_node("boat2/Area3D").queue_free()
			if areaname == "exit":
				$Control.visible = false
				get_parent().get_node("underwaterdinosaur").gameover2 = true
				get_tree().paused = true
		if $Camera3D/RayCast3D.is_colliding() and get_parent().get_node("underwaterdinosaur").gameover == false:
			if $Camera3D/RayCast3D.get_collider().get_parent().get_parent().get_parent().name == "Items":
				var itemsplit = $Camera3D/RayCast3D.get_collider().get_parent().get_parent().name.split(",")
				money += Global.itemvalues[itemsplit[0]]
				$Control/TextureRect/Control.get_node(str($Camera3D/RayCast3D.get_collider().get_parent().get_parent().name)).queue_free()
				$Camera3D/RayCast3D.get_collider().get_parent().get_parent().queue_free()
				itemsfound += 1
	if event.is_action_pressed("pause") and get_tree().paused == false and Global.dialoguearea == null:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$Pause.visible = true
		get_tree().paused = true
func _on_item_list_item_selected(index: int) -> void:
	$Dialogue/ItemList.deselect_all()
	$Dialogue/ItemList.visible = false
	choiceid = Global.dialogue[str(Global.dialoguearea,"ChoiceLocation")][index + 1]
	choiceindex = index + 2
func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent().name == "underwaterdinosaur":
		noticed = true
func _on_other_area_3d_body_entered(body: Node3D, extra_arg_0: String) -> void:
	if body.name == "Player":
		areaname = extra_arg_0
		if areaname == "boat2":
			$Control/Label.text = "Leave Boat (Dangerous)"
		if areaname == "exit":
			$Control/Label.text = "Go back to Boat"
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		areaname = null 
func _on_timer_timeout() -> void:
	time += 1
