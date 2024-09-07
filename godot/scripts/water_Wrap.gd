extends Node2D

var waterNodes: Array = []
var waterNode = preload("res://scenes/water.tscn")
var JoelNode = preload("res://scenes/Joel.tscn")
var random = RandomNumberGenerator.new()

#objects
@onready var waterTop = $waterTop
@onready var water = $water
@onready var JoelHome = $Joels
@onready var waterBody = $waterBody
@onready var waterLine = $waterLine

#general water vars
@export var numberOfWater: int = 38 #38
@export var waterInterval: int = 52 #52
@export var waterHeight: int = 900

#spread of water
@export var spread: float = 0.9
@export var passes: int = 4

#smoothing
@export var spline_lenght: int = 12

func _ready():
	spread /= 1000
	var newCurve = waterLine.get_curve()
	# create water nodes
	for i in numberOfWater:
		var instance = waterNode.instantiate()
		water.add_child(instance)
		
	#set position of all water nodes and add to basic curve
	waterNodes = water.get_children()
	for i in len(waterNodes):
		newCurve.add_point(Vector2(i * waterInterval, waterHeight))
		waterNodes[i].setAnchor(Vector2(i * waterInterval, waterHeight))
		waterNodes[i].setEndPosition(Vector2(i * waterInterval, waterHeight))
		waterNodes[i].setCollisionWidth(waterInterval)
	waterLine.set_curve(newCurve)

func _physics_process(delta):
	waterNodes = water.get_children()
	#update water physic
	var nowCurve = waterLine.curve
	for times in passes:
		for i in len(waterNodes):
			if i > 0:
				var diffHeight = spread * (waterNodes[i].getEndPosition().y - waterNodes[i-1].getEndPosition().y)
				waterNodes[i].applyForce(-diffHeight)
			if i < numberOfWater - 1:
				var diffHeight = spread * (waterNodes[i].getEndPosition().y - waterNodes[i+1].getEndPosition().y)
				waterNodes[i].applyForce(-diffHeight)

			nowCurve.set_point_position(i, Vector2(i * waterInterval, waterNodes[i].getEndPosition().y))
	waterLine.curve = nowCurve
	
#func _process(delta):

	var lastX = waterLine.curve.get_point_position(waterLine.curve.get_point_count() - 1).x # end of line and polygon
	var screen_size = DisplayServer.screen_get_size() #size of screen
	var Line = smooth(lastX, screen_size)
	var waterPoly = waterBody.polygon
	waterPoly.clear()
	
	#two points at the bottom to finish water body
	if waterNodes[-1].getEndPosition().y < screen_size.y:
		Line.append(Vector2(screen_size.x, screen_size.y + 1000))
	if waterNodes[0].getEndPosition().y < screen_size.y:
		Line.append(Vector2(0, screen_size.y + 1000))
	waterBody.set_polygon(Line)
	pass

func smooth(lastX, screen_size):
	waterTop.clear_points()
	var points = waterLine.curve
	#create curve
	for i in points.point_count:
		var spline = _get_spline(i, points)
		points.set_point_in(i, -spline)
		points.set_point_out(i, spline)

	#cleaning the list of points for polygon to show
	var backed_points = points.get_baked_points()
	var backed_points_size = backed_points.size() - 1
	for i in backed_points_size:
		if i < backed_points_size:
			var j = backed_points_size - i
			if backed_points[j].x > lastX or backed_points[j].x < 0 or backed_points[j].x > screen_size.x or backed_points[j].y > screen_size.y - 1:
				backed_points.remove_at(j)
				backed_points_size -= 1
			else:
				if j < backed_points_size and backed_points[j].x > backed_points[j + 1].x:
					backed_points.remove_at(j)
					backed_points_size -= 1

	waterTop.points = backed_points
	return waterTop.get_points()

func _get_spline(i, points):
	var last_point = _get_point(i - 1, points)
	var next_point = _get_point(i + 1, points)
	var spline = last_point.direction_to(next_point) * spline_lenght
	return spline
	
func _get_point(i, points):
	i = wrapi(i, 0, points.point_count)
	return points.get_point_position(i)
	
func _input(event):
	var waters = water.get_children()
	if event.is_action_pressed("wiggle"):
		var i = random.randi_range(0, numberOfWater - 1)
		waters[i].setEndPosition(Vector2(i * waterInterval, waterHeight - 100))
		#waters[1].setEndPosition(Vector2(waterInterval, waterHeight - 100))
	if event.is_action_pressed("Joel"):
		spawnJoel()
		
func spawnJoel():
	var screen = DisplayServer.screen_get_size()
	var startPosition = Vector2(random.randi_range(0, screen.x), screen.y + 200)
	var instance = JoelNode.instantiate()
	var vPercent = ((screen.x - startPosition.x) * 100) / (screen.x / 2)
	var xVelocity = (vPercent * 350) / 100
	if startPosition.x > screen.x / 2:
		xVelocity *= -1
		
	var startVelocity = Vector2(xVelocity, -1500)
	instance.position = startPosition
	instance.linear_velocity = startVelocity
	JoelHome.add_child(instance)
