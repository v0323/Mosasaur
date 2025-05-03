extends Node3D
var movelocation = null
var pathfollow = null
var player = null
var speed = 0.5
var gameover = false
var gameover2 = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$underwaterdinosaur2/dinosaur3/Skeleton3D/underwaterdinosaur.mesh.surface_set_material(0,load("res://assets/underwaterdinosaurmaterial.tres"))
	player = get_parent().get_node("Player")
	$Timer.wait_time = Global.dinosaurtime
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if pathfollow == get_parent().get_node("Game Over/PathFollow3D"):
		player.global_position = global_position
		if pathfollow.progress_ratio >= 0.9:
			get_tree().paused = true
	if gameover == true:
		player.get_node("Control").visible = false
		movelocation = player.global_position
		var playerquaternion = player.basis.get_rotation_quaternion()
		var lookatquaternion = player.transform.looking_at(global_position).basis.get_rotation_quaternion()
		player.basis = playerquaternion.slerp(lookatquaternion,0.1)
		if global_position.distance_to(player.global_position) <= 2:
			gameover = false
			gameover2 = true
			movelocation = null
			speed = 1
	if movelocation != null:
		if $underwaterdinosaur2/AnimationPlayer.is_playing() == false:
			$underwaterdinosaur2/AnimationPlayer.speed_scale = speed * 4
			$underwaterdinosaur2/AnimationPlayer.play("walk")
		var dinoquaternion = Quaternion(basis)
		var lookatquaternion = transform.looking_at(movelocation).basis.get_rotation_quaternion()
		basis = dinoquaternion.slerp(lookatquaternion,0.1)
		global_position = global_position.move_toward(movelocation,speed)
		if global_position == movelocation:
			movelocation = null
	if movelocation == null:
		if pathfollow != null:
			var dinoquaternion = Quaternion(basis)
			if transform.origin != pathfollow.global_position:
				var lookatquaternion = transform.looking_at(pathfollow.global_position).basis.get_rotation_quaternion()
				basis = dinoquaternion.slerp(lookatquaternion,0.1)
			global_position = global_position.move_toward(pathfollow.global_position,speed)
			pathfollow.progress += speed
			if pathfollow.progress_ratio == 1:
				pathfollow.progress_ratio = 0
				pathfollow = null
		if pathfollow == null:
			call_deferred("_new_path")
	if player.underwater == true:
		if player.noticed == false:
			if global_position.distance_to(player.global_position) <= 40:
				player.dinosaurlevel = 1
			if global_position.distance_to(player.global_position) <= 30:
				player.dinosaurlevel = 2
		if player.noticed == true:
			if $Timer.is_stopped():
				$Timer.start()
			player.dinosaurlevel = 5
	if player.time == 20:
		$Timer.wait_time = Global.dinosaurtime * 0.75
	if player.time == 40:
		$Timer.wait_time = Global.dinosaurtime * 0.5
	if player.time == 80:
		$Timer.wait_time = Global.dinosaurtime * 0.25
func _new_path():
	var locations = []
	for area in get_parent().get_node("Locations").get_children():
		if player.global_position.distance_to(area.global_position) <= Global.locationdistance:
			locations.append(area)
	var location
	if locations.is_empty() == false:
		location = locations.pick_random()
	if locations.is_empty():
		location = get_parent().get_node("Locations").get_children().pick_random()
	pathfollow = location.get_node("Path3D/PathFollow3D")
	if gameover2 == true:
		pathfollow = get_parent().get_node("Game Over/PathFollow3D")
		get_parent().get_node("Game Over").look_at(Vector3(global_position.x,0,global_position.z))
		get_parent().get_node("Game Over/Camera3D").current = true
	movelocation = pathfollow.global_position
func _on_timer_timeout() -> void:
	if player.get_node("Area3D/CollisionShape3D").shape.radius == 0.5:
		player.noticed = false
		player.get_node("AudioStreamPlayer3D").stop()
	if player.noticed == true:
		gameover = true
		player.survived = false
		movelocation = player.global_position
		pathfollow = null
