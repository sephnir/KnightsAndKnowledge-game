extends KinematicBody2D

export var id = 0;
export var speed = 200;

var velocity = Vector2();

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	#position.x += velocity.x * speed;
	#position.y += velocity.y * speed;
	pass;

func _physics_process(delta):
	#velocity = velocity.normalized() * speed;
	#velocity = move_and_slide(velocity.normalized() * speed)
	move_and_slide(velocity * speed)
	pass;
