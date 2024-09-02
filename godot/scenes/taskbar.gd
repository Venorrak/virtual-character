extends Node2D

@onready var JoelLabel = $JoelNode/JoelStats
@onready var WeatherLabel = $weatherNode/Weather
@onready var TwitchLabel = $"twitchNode/twitch stats"
@onready var TimeLabel = $TimeNode/Time
@onready var anim1 = $AnimationPlayer1
@onready var anim2 = $AnimationPlayer2
var state = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request("https://server.venorrak.dev/api/joels/users?way=DESC&sort=count")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var theString = ""
	var count = 1
	for user in json:
		match count:
			1:
				theString += "[color=#eac911]#" + str(count) + "[/color]"
			2:
				theString += "[color=#a6a6a6]#" + str(count) + "[/color]"
			3:
				theString += "[color=#cb5920]#" + str(count) + "[/color]"
		theString += " - " + str(user["name"]) + " : " + str(user["count"]) + " "
		if count > 2:
			break
		count += 1
	JoelLabel.text = "[b][font_size=22] " + theString + "[/font_size][/b]"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var myTime = Time.get_datetime_dict_from_system()
	var TimeString = str(myTime["day"]) + "-" + str(myTime["month"]) + "-" + str(myTime["year"]) + " " + str(myTime["hour"]) + ":" + str(myTime["minute"]) + ":" + str(myTime["second"])
	TimeLabel.text = "[b][font_size=22] My time right now is -> " + TimeString + "[/font_size][/b]"
	

func _on_carousel_timer_timeout():
	match state:
		0:
			anim1.current_animation = "Joel_in"
			$HTTPRequest.request("https://server.venorrak.dev/api/joels/users?way=DESC&sort=count")
			anim2.current_animation = "taskbar_anim/Time_out"
		1:
			anim1.current_animation = "Joel_out"
			anim2.current_animation = "taskbar_anim/twitch_in"
		2:
			anim1.current_animation = "twitch_out"
			anim2.current_animation = "taskbar_anim/Time_in"
	if state == 2:
		state = 0
	else:
		state += 1
	$carousel_timer.start()
