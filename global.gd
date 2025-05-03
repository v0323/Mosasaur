extends Node
var username = "Carlos"
var firstlaunch = true
var dialoguearea = "Intro"
var mousesensitivity = 1
var volume = 0.5
var visual = false
var dinosaurtime = 1
var locationdistance = 50
var dialogue = {	
	"Intro" : ["Gio","Alright {0}, this is the area.", "There should hopefully be tons of stuff down there as we mentioned.",
	"?Any questions?","?Any more questions?",
	"You see, I was made aware of this area thirty minutes ago, and the amount of expensive salvage this place supposedly has is too good to wait for a reasonable time of day.",
	"Trust me.","No... hopefully.",
	"But just in case, I've installed a newly invented whale detector in your suit. It should make scary sounds whenever something large gets close.",
	"It's intended for whales but it should work for any large underwater animal. Not saying that there is any, but just in case.",
	"Good luck out there."],
	
	"IntroChoices" : ["Why are we out here at 2 in the 
	morning?","Is there something here I should worry about?","See you in a bit."],
	
	"IntroChoiceLocation" : [4,5,7,10]
}
var itemvalues = {
	"CSGBox3D" : 100,
	"treasurechest" : 200,
	"airfryer" : 100,
	"blender" : 50,
	"nontendoswitch" : 100
}
var gameoverscreen = {
	"Time" : 0,
	"Items Found" : 0,
	"Money Earned" : 0,
	"Survived" : true,
	"Score" : 0,
	"Rank" : "" 
}
var highscores = {
	"Ramon Sr." : 1000000,
	"Ramon Jr." : 999999,
	"Giovanni" : 800589, 
}
