extends Node3D

var done = false
var json = JSON.new()
var num_socket = 5555
@onready var head = $Tv
@onready var rainbow_timer = $Tv/rainbow_timer
@onready var dum_timer = $Tv/dum_timer
@onready var dum = $Tv/display/SubViewport/dum
@onready var right_eye = $Tv/display/SubViewport/right_eye
@onready var left_eye = $Tv/display/SubViewport/left_eye
@onready var equaliser = $Tv/display/SubViewport/equaliser
@onready var green_screen = $Tv/display/SubViewport/green_screen
@onready var dum_text = $Tv/display/SubViewport/dum
@onready var brb = $Tv/display/SubViewport/brb
@onready var starting = $Tv/display/SubViewport/starting
@onready var animator = $AnimationPlayer
@onready var camera = $Camera3D

var server = WebSocketPeer.new()
var clients = []
var equaliser_bars = []

func _ready():
	server.connect_to_url("ws://192.168.0.16:5963")
	var childrens = equaliser.find_children("right")[0].get_children()
	for i in len(childrens):
		equaliser_bars.append(childrens[i])
	childrens = equaliser.find_children("left")[0].get_children()
	for i in len(childrens):
		equaliser_bars.append(childrens[i])
	
func _process(delta):
	server.poll()
	var state = server.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while server.get_available_packet_count():
			var pkt = server.get_packet()
			var data = json.parse_string(str(pkt.get_string_from_utf8()))
			print(data)
			if data["to"] == "avatar":
				match data["payload"]["command"]:
					"freeze_unfreeze_head":
						head.frozen = !head.frozen
					"reset_head":
						reset_tv()
						head.rainbow = false
						change_face_color("4e6fff")
					"change_color":
						change_face_color(data["data"])
					"rainbow_on_off":
						head.rainbow = !head.rainbow
						rainbow_timer.start()
					"scale_tiny":
						head.position.x = -4
					"scale_default":
						head.position.x = 0
					"green_on_off":
						green_screen.visible = !green_screen.visible
						head.rainbow = false
					"dum_on_off":
						dum_text.visible = !dum_text.visible
						dum_timer.start()
					"brb_on_off":
						if brb.visible == true:
							animator.current_animation = "brb_off"
						else:
							animator.current_animation = "brb_on"
					"starting_on_off":
						if starting.visible == true:
							animator.current_animation = "ease_out"
						else:
							animator.current_animation = "ease_in"
					"zoom_in_out":
						if camera.position.x == 3.0:
							animator.current_animation = "center_out"
						else:
							animator.current_animation = "center_in"
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = server.get_close_code()
		var reason = server.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
func change_face_color(couleur : Color):
	for i in len(equaliser_bars):
		equaliser_bars[i].color = couleur
		right_eye.modulate = couleur
		left_eye.modulate = couleur
		dum.label_settings.font_color = couleur
		
func reset_tv():
	head.rotation = Vector3(0, 0, 0)
	right_eye.position = head.origin_right_eye_position
	right_eye.scale = head.origin_right_eye_scale
	left_eye.position = head.origin_left_eye_postion
	left_eye.scale = head.origin_left_eye_scale
