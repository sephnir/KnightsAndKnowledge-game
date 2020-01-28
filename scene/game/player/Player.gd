extends KinematicBody2D

export var id = 0;
export var speed = 200;

var velocity = Vector2();
var grid = Vector2();

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#Constuctor. Call when instancing.
func init(pos):
	self.position = pos;

#Moves self based on current velocity
func update_pos():
	move_and_slide(velocity * speed);

#Updates grid based on position of self
func update_grid():
	grid = Vector2(floor(position.x/32), floor(position.y/32));

#Called on every frame
func _process(delta):
	update_grid();

#Called on every frame (For in-game physics processing)
func _physics_process(delta):
	update_pos();
