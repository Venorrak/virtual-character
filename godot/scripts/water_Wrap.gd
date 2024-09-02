extends Node2D
var waterNodes: Array = []
var waterNode = preload("res://scenes/water.tscn")
var random = RandomNumberGenerator.new()

@onready var point1 = $Point1
@onready var point2 = $Point2

@onready var waterTop = $waterTop
@onready var water = $water
@onready var waterBody = $waterBody
@export var numberOfWater: int = 38 # doit etre pair 38
@export var waterInterval: int = 52 #52
@onready var waterLine = $waterLine
@export var spread: float = 0.9
@export var passes: int = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	spread /= 1000
	var newCurve = waterLine.get_curve()
	for i in numberOfWater:
		var instance = waterNode.instantiate()
		water.add_child(instance)
	waterNodes = water.get_children()
	for i in len(waterNodes):
		newCurve.add_point(Vector2(i * waterInterval, 900))
		waterNodes[i].setAnchor(Vector2(i * waterInterval, 900))
		waterNodes[i].setEndPosition(Vector2(i * waterInterval, 900))
	waterLine.set_curve(newCurve)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	waterNodes = water.get_children()
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
	
func _process(delta):
	var points = smooth()
	var waterPoly = waterBody.polygon
	waterPoly.clear()
	for point in points:
		waterPoly.append(point)
	#waterPoly.append(Vector2(1920, 900))
	var lastPoint = waterLine.curve.get_baked_points()[-1]
	if lastPoint.x > 1920:
		lastPoint.x = 1919
	waterPoly.append(lastPoint)
	waterPoly.append(Vector2(1919, 1079))
	waterPoly.append(Vector2(1, 1079))
	waterBody.set_polygon(waterPoly)
	pass

func smooth():
	waterTop.clear_points()
	var points = waterLine.curve.tessellate()
	var size = points.size()
	if size % 2 == 0 && size > 1: 
		var a = points[size-1]
		var b = points[size-2]
		var c = a.lerp(b, 0.5)
		points.insert(size-1, c)
	waterTop.add_point(points[0])
	var last_m = Vector2()
	for i in range(0, size, 2): 
		var a = points[i]
		var b = points[i+1]
		var c = points[i+2]
		var m1 = _quadratic_bezier(a, b, c, 0.2)
		var m2 = _quadratic_bezier(a, b, c, 0.4)
		var m3 = _quadratic_bezier(a, b, c, 0.6)
		var m4 = _quadratic_bezier(a, b, c, 0.8)
		if (i != 0):
			var e = last_m
			var f = points[i]
			var g = m1
			var n1 = _quadratic_bezier(e, f, g, 0.33)
			var n2 = _quadratic_bezier(e, f, g, 0.66)
			waterTop.add_point(n1)
			waterTop.add_point(n2)
		waterTop.add_point(m1)
		waterTop.add_point(m2)
		waterTop.add_point(m3)
		waterTop.add_point(m4)
		last_m = m4
	waterTop.add_point(points[size-1])
	return waterTop.get_points()

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)

	var r = q0.lerp(q1, t)
	return r

func _input(event):
	var waters = water.get_children()
	if event.is_action_pressed("wiggle"):
		var i = random.randi_range(0, numberOfWater - 1)
		waters[i].setEndPosition(Vector2(i * waterInterval, 700))
		
		
