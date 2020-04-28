extends Node2D

var disabled = false;
var mouse_pos = Vector2(0,0);
var inner_pos = Vector2(0,0);
var outer_radius = 120;
var bound_radius = 90;
var inner_radius = 80;
var alpha = 1;
var velocity = Vector2(0,0);

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(0,0);


func _process(delta):
	if(disabled): 
		visible = false;
		mouse_pos = position;
		velocity = Vector2(0,0);
		return;
		
	if(Input.is_action_just_pressed("mouse_left")):
		position = get_viewport().get_mouse_position()/2;
	if(Input.is_action_pressed("mouse_left")):
		mouse_pos = get_viewport().get_mouse_position()/2;
		alpha = 1;
	else:
		mouse_pos = position;
		alpha = 0;
		
	if(position.distance_to(mouse_pos) > bound_radius):
		var vec_dir = position.direction_to(mouse_pos);
		inner_pos = position + (vec_dir * bound_radius); 
	else:
		inner_pos = mouse_pos;
		
	velocity = (inner_pos - position) / bound_radius;

	if(alpha<=0):
		visible = false;
	else:
		visible = true;
	update();

func _draw():
	draw_circle(position, outer_radius, Color(255,255,255, alpha*0.3));
	draw_circle(inner_pos, inner_radius, Color(255,255,255, alpha*0.3));
	
