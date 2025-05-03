extends Control
var animationplayed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if get_parent().get_node("underwaterdinosaur").gameover2 == true:
		if animationplayed == false:
			$AnimationPlayer.play("Game Over")
			if get_parent().get_node("Player").time > 80:
				get_parent().get_node("Player").time = 80
			Global.gameoverscreen["Time"] = get_parent().get_node("Player").time
			Global.gameoverscreen["Items Found"] = get_parent().get_node("Player").itemsfound
			Global.gameoverscreen["Money"] = get_parent().get_node("Player").money
			Global.gameoverscreen["Survived"] = get_parent().get_node("Player").survived
			var survivemultiply = 1
			if get_parent().get_node("Player").survived:
				survivemultiply = 5
			Global.gameoverscreen["Score"]= (Global.gameoverscreen["Time"] * 10) + (Global.gameoverscreen["Items Found"] * 5) + (Global.gameoverscreen["Money"] * 20) * survivemultiply
			if Global.gameoverscreen["Score"] < 1000:
				Global.gameoverscreen["Rank"] = "YOU SUCK"
			if Global.gameoverscreen["Score"] >= 1000:
				Global.gameoverscreen["Rank"] = "OK"
			if Global.gameoverscreen["Score"] >= 100000:
				Global.gameoverscreen["Rank"] = "AMAZING"
			$Label2.text = str("
			Time : ",Global.gameoverscreen["Time"],"
			Items Found : ",Global.gameoverscreen["Items Found"],"
			Money : ",Global.gameoverscreen["Money"],"
			Survived : ",Global.gameoverscreen["Survived"],"
			
			
			
			
			Total Score : ",Global.gameoverscreen["Score"])
			$Label3.text = Global.gameoverscreen["Rank"]
			Global.highscores[Global.username] = Global.gameoverscreen["Score"]
			visible = true
			animationplayed = true
			var savefile = FileAccess.open("res://scarysave.game",FileAccess.WRITE)
			var save = {
				"firstlaunch" : Global.firstlaunch,
				"username" : Global.username,
				"dialoguearea" : Global.dialoguearea,
				"mousesensitivity" : Global.mousesensitivity,
				"volume" : Global.volume,
				"highscores" : Global.highscores
			}
			var jsonstring = JSON.stringify(save)
			savefile.store_line(jsonstring)
			
		if Input.is_action_just_pressed("pause"):
			get_tree().change_scene_to_file("res://main_menu.tscn")
