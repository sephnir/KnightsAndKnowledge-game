extends Area2D

var room_size;

func _ready():
	pass;

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
