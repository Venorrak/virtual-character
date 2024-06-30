extends MeshInstance3D
const point = preload("res://scenes/point.tscn")

var points = []
var done = false
var socket = PacketPeerUDP.new()
var num_socket = 12345
var json = JSON.new()
var new_material = StandardMaterial3D.new()
var brows

func _init():
	socket.bind(num_socket, "127.0.0.1", 8300)
	if(socket.is_socket_connected() == true):
		print("An error occurred listening on port ", num_socket)
	else:
		done = true;
		print("Listening on port ", num_socket, " on localhost")
	for i in range(2):
		var newPoint = point.instantiate()
		add_child(newPoint)
		points.append(newPoint)
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var brows = self.get_parent().find_children("brows")[0]
	var lips = self.get_parent().find_children("lips")[0]
	var verts = []
	if socket.get_available_packet_count() > 0:
		var pkt = socket.get_packet().get_string_from_ascii()
		pkt = json.parse_string(pkt)
		#origin point is the nose
		var origin = pkt[1]
		#set position of eyes
		points[0].position.x = (pkt[468][0] - origin[0]) / 10
		points[0].position.y = (pkt[468][1] - origin[1]) / 10
		points[0].position.z = (pkt[468][2] - origin[2] + 10) / 10
		points[1].position.x = (pkt[473][0] - origin[0]) / 10
		points[1].position.y = (pkt[473][1] - origin[1]) / 10
		points[1].position.z = (pkt[473][2] - origin[2] + 10) / 10
		#calculate scale of eyes
		var eye_size = -((points[0].position.x - points[1].position.x) + (points[0].position.y - points[1].position.y)) / 2
		eye_size = (eye_size / 10) + 0.15
		#set scale of eyes
		for i in range(2):
			var childs = points[i].find_children("eye_mesh")
			if (len(childs) > 0):
				childs[0].set_scale(Vector3(eye_size, eye_size, eye_size))
		#set positions of vertices
		for i in range(478):
			var x = (pkt[i][0] - origin[0]) / 10
			var y = (pkt[i][1] - origin[1]) / 10
			var z = (pkt[i][2] - origin[2]) / 10
			var vector = Vector3(x,y,z)
			verts.append(vector)
	var vertecies = PackedVector3Array(verts)
	#I am ashamed of this
	var indices := PackedInt32Array(
		[
			338,151,109,
			151,338,299,
			332,299,338,
			299,332,298,
			251,298,332,
			298,251,368,
			356,368,251,
			368,356,447,
			323,447,356,
			447,323,401,
			288,401,323,
			401,288,367,
			365,367,288,
			367,365,394,
			378,394,365,
			394,378,369,
			377,369,378,
			369,377,175,
			148,175,377,
			175,148,140,
			140,148,149,
			140,149,169,
			169,149,136,
			169,136,138,
			138,136,58,
			138,58,177,
			93,177,58,
			93,227,177,
			127,227,93,
			127,139,227,
			21,139,127,
			21,68,139,
			103,68,21,
			103,69,68,
			109,69,103,
			109,151,69,
			151,336,107,
			299,336,151,
			299,334,336,
			298,334,299,
			298,300,334,
			368,300,298,
			368,372,300,
			447,372,368,
			447,352,372,
			401,352,447,
			401,433,352,
			367,433,401,
			367,434,433,
			394,434,367,
			394,431,434,
			369,431,394,
			369,428,431,
			175,428,369,
			175,208,428,
			140,208,175,
			140,211,208,
			169,211,140,
			169,214,211,
			138,214,169,
			138,213,214,
			177,213,138,
			177,123,213,
			227,123,177,
			227,143,123,
			139,143,227,
			139,70,143,
			68,70,139,
			68,105,70,
			69,105,68,
			69,107,105,
			151,107,69,
			336,8,107,
			#336,295,285,
			336,285,8,
			#334,295,336,
			#334,283,282,
			#334,282,295,
			300,283,334,
			300,353,276,
			300,276,283,
			372,353,300,
			372,340,265,
			372,265,353,
			352,340,372,
			352,346,340,
			352,280,346,
			352,411,280,
			433,411,352,
			433,427,411,
			434,427,433,
			434,422,432,
			431,422,434,
			431,418,424,
			431,424,422,
			428,418,431,
			428,200,421,
			428,421,418,
			208,200,428,
			208,194,201,
			208,201,200,
			211,194,208,
			211,202,204,
			211,204,194,
			214,202,211,
			214,212,202,
			213,207,214,
			213,187,207,
			123,187,213,
			116,117,123,
			116,111,117,
			116,143,111,
			70,124,143,
			143,124,35,
			70,53,46,
			70,46,124,
			105,53,70,
			#105,65,52,
			#105,52,53,
			#107,65,105,
			107,8,55,
			#107,55,65,
			#fin des gros triangles
			143,35,111,
			52,222,223,
			65,222,52,
			65,55,222,
			55,221,222,
			55,8,193,
			55,193,221,
			53,52,224,
			52,223,224,
			46,53,225,
			53,224,225,
			124,46,113,
			46,225,113,
			124,113,226,
			35,124,226,
			35,226,31,
			35,31,111,
			111,31,117,
			31,228,117,
			228,229,118,
			228,118,117,
			229,230,119,
			229,119,118,
			230,231,120,
			230,120,119,
			231,232,121,
			231,121,120,
			232,233,128,
			232,128,121,
			233,244,128,
			244,245,128,
			189,245,244,
			189,193,245,
			221,193,189,
			##contour oeuil gauche c'est cool
			223,222,28,
			223,28,27,
			222,221,56,
			222,56,28,
			221,189,56,
			189,190,56,
			189,244,190,
			190,244,243,
			243,244,233,
			243,233,112,
			112,233,232,
			112,232,26,
			22,26,232,
			22,232,231,
			23,22,231,
			23,231,230,
			24,23,230,
			24,230,229,
			110,24,229,
			110,229,228,
			25,110,228,
			25,228,31,
			130,25,226,
			25,31,226,
			247,130,113,
			113,130,226,
			225,30,247,
			113,225,247,
			224,29,30,
			225,224,30,
			224,223,29,
			223,27,29,
			##deuxieme contour oeuil gauche
			29,27,159,
			29,159,160,
			28,159,27,
			28,158,159,
			56,158,28,
			56,157,158,
			190,157,56,
			190,173,157,
			243,173,190,
			243,133,173,
			112,133,243,
			112,155,133,
			26,155,112,
			26,154,155,
			22,154,26,
			22,153,154,
			23,153,22,
			23,145,153,
			23,24,144,
			23,144,145,
			110,144,24,
			110,163,144,
			110,7,163,
			110,25,7,
			25,33,7,
			25,130,33,
			33,247,246,
			33,130,247,
			247,30,161,
			247,161,246,
			30,29,160,
			30,160,161,
			##left eye finished
			168,193,8,
			417,168,8,
			417,8,285,
			417,285,441,
			442,441,285,
			442,285,295,
			442,295,282,
			442,282,443,
			444,443,282,
			444,282,283,
			445,444,283,
			445,283,276,
			342,445,276,
			342,276,353,
			446,342,353,
			446,353,265,
			261,446,265,
			261,265,340,
			346,448,261,
			346,261,340,
			347,449,448,
			347,448,346,
			348,450,449,
			348,449,347,
			349,450,348,
			349,451,450,
			350,451,349,
			350,452,451,
			357,452,350,
			357,453,452,
			357,465,464,
			357,464,453,
			465,417,413,
			465,413,464,
			413,417,441,
			464,413,414,
			464,414,463,
			413,441,286,
			413,286,414,
			286,441,442,
			286,442,258,
			258,442,443,
			258,443,257,
			259,257,443,
			259,443,444,
			260,259,444,
			260,444,445,
			467,260,445,
			467,445,342,
			359,467,342,
			359,342,446,
			255,359,446,
			255,446,261,
			448,339,255,
			448,255,261,
			449,254,339,
			449,339,448,
			450,253,254,
			450,254,449,
			451,252,253,
			451,253,450,
			452,256,252,
			452,252,451,
			452,453,341,
			452,341,256,
			453,464,463,
			453,463,341,
			463,414,398,
			463,398,362,
			414,286,384,
			414,384,398,
			385,384,286,
			385,286,258,
			386,385,258,
			386,258,257,
			386,257,259,
			386,259,387,
			387,259,260,
			387,260,388,
			388,260,467,
			388,467,466,
			263,466,467,
			263,467,359,
			255,249,263,
			255,263,359,
			339,390,249,
			339,249,255,
			339,254,373,
			339,373,390,
			253,374,373,
			253,373,254,
			253,252,380,
			253,380,374,
			252,256,381,
			252,381,380,
			256,341,382,
			256,382,381,
			341,463,362,
			341,362,382,
			##fin oeil droit
			123,117,50,
			50,117,118,
			101,50,118,
			101,118,119,
			100,101,119,
			100,119,120,
			47,100,120,
			47,120,121,
			114,47,121,
			114,121,128,
			114,128,245,
			114,245,188,
			122,188,245,
			122,245,193,
			122,193,168,
			122,168,6,
			351,6,168,
			351,168,417,
			351,417,465,
			351,465,412,
			343,412,465,
			343,465,357,
			343,357,350,
			343,350,277,
			277,350,349,
			277,349,329,
			329,349,348,
			329,348,330,
			330,348,347,
			330,347,280,
			280,347,346,
			411,427,425,
			411,425,280,
			425,266,330,
			425,330,280,
			266,371,329,
			266,329,330,
			355,277,329,
			355,329,371,
			437,343,277,
			437,277,355,
			399,412,343,
			399,343,437,
			419,351,412,
			419,412,399,
			419,197,6,
			419,6,351,
			196,122,6,
			196,6,197,
			196,174,188,
			196,188,122,
			174,217,114,
			174,114,188,
			217,126,47,
			217,47,114,
			126,142,100,
			126,100,47,
			36,101,100,
			36,100,142,
			205,50,101,
			205,101,36,
			187,50,205,
			187,205,207,
			187,123,50,
			214,207,216,
			214,216,212,
			207,205,206,
			207,206,216,
			206,205,36,
			206,36,203,
			36,142,129,
			36,129,203,
			209,129,142,
			209,142,126,
			198,209,126,
			198,126,217,
			198,217,174,
			198,174,236,
			236,174,196,
			236,196,3,
			3,196,197,
			3,197,195,
			248,195,197,
			248,197,419,
			456,248,419,
			456,419,399,
			420,456,399,
			420,399,437,
			420,437,355,
			420,355,429,
			429,355,371,
			429,371,358,
			358,371,266,
			358,266,423,
			426,423,266,
			426,266,425,
			426,425,427,
			426,427,436,
			434,432,436,
			434,436,427,
			281,5,195,
			281,195,248,
			281,248,456,
			281,456,363,
			363,456,420,
			363,420,360,
			279,360,420,
			279,420,429,
			358,331,279,
			358,279,429,
			294,331,358,
			294,358,327,
			294,327,460,
			423,391,327,
			423,327,358,
			391,423,426,
			391,426,322,
			322,426,436,
			322,436,410,
			432,287,410,
			432,410,436,
			273,287,432,
			273,432,422,
			335,273,422,
			335,422,424,
			424,418,406,
			424,406,335,
			421,313,406,
			421,406,418,
			200,18,313,
			200,313,421,
			200,201,83,
			200,83,18,
			201,194,182,
			201,182,83,
			204,106,182,
			204,182,194,
			202,43,106,
			202,106,204,
			43,202,212,
			43,212,57,
			212,216,186,
			212,186,57,
			216,206,92,
			216,92,186,
			206,203,165,
			206,165,92,
			203,129,98,
			203,98,165,
			64,129,102,
			64,98,129,
			64,240,98,
			129,209,49,
			129,49,102,
			49,209,198,
			49,198,131,
			134,131,198,
			134,198,236,
			51,134,236,
			51,236,3,
			51,3,195,
			51,195,5,
			98,240,97,
			98,97,167,
			164,167,97,
			164,97,2,
			164,2,326,
			164,326,393,
			327,393,326,
			327,326,460,
			167,165,98,
			391,393,327,
			267,0,164,
			267,164,393,
			269,267,393,
			269,393,391,
			269,391,322,
			269,322,270,
			270,322,410,
			270,410,409,
			287,291,409,
			287,409,410,
			375,291,287,
			375,287,273,
			273,335,321,
			273,321,375,
			406,405,321,
			406,321,335,
			406,313,314,
			406,314,405,
			18,314,313,
			18,17,314,
			18,83,84,
			18,84,17,
			182,181,84,
			182,84,83,
			182,106,91,
			182,91,181,
			43,146,91,
			43,91,106,
			146,43,57,
			146,57,61,
			57,186,185,
			57,185,61,
			186,92,40,
			186,40,185,
			39,40,92,
			39,92,165,
			39,165,167,
			39,167,37,
			37,167,164,
			37,164,0,
			#debut lips
			#302,11,0,
			#302,0,267,
			#302,267,269,
			#302,269,303,
			#303,269,270,
			#303,270,304,
			#408,304,270,
			#408,270,409,
			#306,408,409,
			#306,409,291,
			#375,307,306,
			#375,306,291,
			#321,320,307,
			#321,307,375,
			#321,405,404,
			#321,404,320,
			#405,314,315,
			#405,315,404,
			#314,17,16,
			#314,16,315,
			#84,85,16,
			#84,16,17,
			#181,180,85,
			#181,85,84,
			#91,90,180,
			#91,180,181,
			#91,146,77,
			#91,77,90,
			#146,61,76,
			#146,76,77,
			#76,61,185,
			#76,185,184,
			#184,185,40,
			#184,40,74,
			#73,74,40,
			#73,40,39,
			#72,73,39,
			#72,39,37,
			#72,37,0,
			#72,0,11,
			#12,11,302,
			#12,302,268,
			#268,302,303,
			#268,303,271,
			#271,303,304,
			#271,304,272,
			#272,304,408,
			#272,408,407,
			#407,408,306,
			#407,306,292,
			#307,325,292,
			#307,292,306,
			#320,319,325,
			#320,325,307,
			#320,404,403,
			#320,403,319,
			#404,315,316,
			#404,316,403,
			#315,16,15,
			#315,15,316,
			#85,86,15,
			#85,15,16,
			#180,179,86,
			#180,86,85,
			#90,89,179,
			#90,179,180,
			#90,77,96,
			#90,96,89,
			#77,76,62,
			#77,62,96,
			#76,184,183,
			#76,183,62,
			#42,183,184,
			#42,184,74,
			#41,42,74,
			#41,74,73,
			#38,41,73,
			#38,73,72,
			#12,38,72,
			#12,72,11,
			#13,12,268,
			#13,268,312,
			#312,268,271,
			#312,271,311,
			#311,271,272,
			#311,272,310,
			#310,272,407,
			#310,407,415,
			#415,407,292,
			#325,324,292,
			#325,319,318,
			#325,318,324,
			#403,402,318,
			#403,318,319,
			#403,316,317,
			#403,317,402,
			#316,15,14,
			#316,14,317,
			#86,87,14,
			#86,14,15,
			#179,178,87,
			#179,87,86,
			#179,89,88,
			#179,88,178,
			#96,95,88,
			#96,88,89,
			#96,62,95,
			#62,183,191,
			#80,191,183,
			#80,183,42,
			#81,80,42,
			#81,42,41,
			#82,81,41,
			#82,41,38,
			#13,82,38,
			#13,38,12,
			##fin lips
			48,64,102,
			48,102,49,
			48,49,131,
			48,131,115,
			220,115,131,
			220,131,134,
			45,220,134,
			45,134,51,
			45,51,5,
			45,5,4,
			275,4,5,
			275,5,281,
			275,281,363,
			275,363,440,
			440,363,360,
			440,360,344,
			278,344,360,
			278,360,279,
			278,279,331,
			278,331,294,
			240,64,235,
			64,48,219,
			64,219,235,
			219,48,115,
			219,115,218,
			218,115,220,
			218,220,237,
			44,237,220,
			44,220,45,
			1,44,45,
			1,45,4,
			1,4,275,
			1,275,274,
			274,275,440,
			274,440,457,
			438,457,440,
			438,440,344,
			439,438,344,
			439,344,278,
			294,455,439,
			294,439,278,
			305,455,460,
			460,455,294,
			460,328,305,
			460,326,328,
			305,328,290,
			305,290,392,
			305,392,289,
			289,392,439,
			289,439,455,
			305,289,455,
			59,235,219,
			59,219,166,
			75,235,59,
			75,240,235,
			75,59,166,
			60,75,166,
			99,75,60,
			99,240,75,
			97,240,99,
			166,219,218,
			166,218,79,
			60,166,79,
			60,79,20,
			99,60,20,
			99,20,242,
			97,99,242,
			97,242,141,
			2,97,141,
			2,141,94,
			2,94,370,
			2,370,326,
			326,370,462,
			326,462,328,
			328,462,250,
			328,250,290,
			290,250,309,
			290,309,392,
			392,309,438,
			392,438,439,
			19,1,274,
			19,274,354,
			461,354,274,
			461,274,457,
			461,457,459,
			461,459,458,
			459,457,438,
			459,438,309,
			458,459,309,
			458,309,250,
			19,125,44,
			19,44,1,
			241,237,44,
			241,44,125,
			241,238,239,
			241,239,237,
			239,79,218,
			239,218,237,
			238,20,79,
			238,79,239,
			242,20,238,
			242,238,241,
			141,242,241,
			141,241,125,
			94,141,125,
			94,125,19,
			94,19,354,
			94,354,370,
			370,354,461,
			370,461,462,
			462,461,458,
			462,458,250
		]
	)
	var indices_brows := PackedInt32Array(
		[
			65,66,107,
			65,107,55,
			52,105,66,
			52,66,65,
			53,63,105,
			53,105,52,
			53,46,63,
			#right brow
			295,285,336,
			295,336,296,
			295,296,282,
			282,296,334,
			283,282,334,
			283,334,293,
			276,283,293
		]
	)
	var indices_lips := PackedInt32Array(
		[
			302,11,0,
			302,0,267,
			302,267,269,
			302,269,303,
			303,269,270,
			303,270,304,
			408,304,270,
			408,270,409,
			306,408,409,
			306,409,291,
			375,307,306,
			375,306,291,
			321,320,307,
			321,307,375,
			321,405,404,
			321,404,320,
			405,314,315,
			405,315,404,
			314,17,16,
			314,16,315,
			84,85,16,
			84,16,17,
			181,180,85,
			181,85,84,
			91,90,180,
			91,180,181,
			91,146,77,
			91,77,90,
			146,61,76,
			146,76,77,
			76,61,185,
			76,185,184,
			184,185,40,
			184,40,74,
			73,74,40,
			73,40,39,
			72,73,39,
			72,39,37,
			72,37,0,
			72,0,11,
			12,11,302,
			12,302,268,
			268,302,303,
			268,303,271,
			271,303,304,
			271,304,272,
			272,304,408,
			272,408,407,
			407,408,306,
			407,306,292,
			307,325,292,
			307,292,306,
			320,319,325,
			320,325,307,
			320,404,403,
			320,403,319,
			404,315,316,
			404,316,403,
			315,16,15,
			315,15,316,
			85,86,15,
			85,15,16,
			180,179,86,
			180,86,85,
			90,89,179,
			90,179,180,
			90,77,96,
			90,96,89,
			77,76,62,
			77,62,96,
			76,184,183,
			76,183,62,
			42,183,184,
			42,184,74,
			41,42,74,
			41,74,73,
			38,41,73,
			38,73,72,
			12,38,72,
			12,72,11,
			13,12,268,
			13,268,312,
			312,268,271,
			312,271,311,
			311,271,272,
			311,272,310,
			310,272,407,
			310,407,415,
			415,407,292,
			325,324,292,
			325,319,318,
			325,318,324,
			403,402,318,
			403,318,319,
			403,316,317,
			403,317,402,
			316,15,14,
			316,14,317,
			86,87,14,
			86,14,15,
			179,178,87,
			179,87,86,
			179,89,88,
			179,88,178,
			96,95,88,
			96,88,89,
			96,62,95,
			62,183,191,
			80,191,183,
			80,183,42,
			81,80,42,
			81,42,41,
			82,81,41,
			82,41,38,
			13,82,38,
			13,38,12,
			267,0,37
		]
	)
	#create mesh
	var array = []
	var array_brows = []
	var array_lips = []
	array_lips.resize(ArrayMesh.ARRAY_MAX)
	array_lips[ArrayMesh.ARRAY_VERTEX] = vertecies
	array_lips[ArrayMesh.ARRAY_INDEX] = indices_lips
	array_brows.resize(ArrayMesh.ARRAY_MAX)
	array_brows[ArrayMesh.ARRAY_VERTEX] = vertecies
	array_brows[ArrayMesh.ARRAY_INDEX] = indices_brows
	array.resize(ArrayMesh.ARRAY_MAX)
	array[ArrayMesh.ARRAY_VERTEX] = vertecies
	array[ArrayMesh.ARRAY_INDEX] = indices
	var lips_mesh = ArrayMesh.new()
	var brows_mesh = ArrayMesh.new()
	var a_mesh = ArrayMesh.new()
	if (len(vertecies) != 0):
		a_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
		brows_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array_brows)
		lips_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array_lips)
		#update mesh
		mesh = a_mesh
		brows.mesh = brows_mesh
		lips.mesh = lips_mesh
		
	
