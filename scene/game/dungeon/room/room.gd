extends RigidBody2D

var room_size;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func make_room(pos, size):
	position = pos;
	room_size = size;
	var s = RectangleShape2D.new();
	s.custom_solver_bias = 0.75
	s.extents = size;
	$CS_Room.shape = s;

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
