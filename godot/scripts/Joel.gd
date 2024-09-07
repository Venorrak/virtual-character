extends RigidBody2D
@export var acceleration: Vector2 = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	linear_velocity += acceleration
	acceleration *= 0
	look_at(position + linear_velocity)

func ApplyForce(force: Vector2):
	acceleration += force

func ApplyFriction(friction: float):
	acceleration *= friction

func setSpeed(vector: Vector2):
	linear_velocity = vector
