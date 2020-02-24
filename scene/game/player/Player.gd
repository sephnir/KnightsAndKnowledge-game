extends KinematicBody2D

export var id = 0;
export var speed = 200;

enum ANIM{
	IDLE,
	WALK,
	RUN,
	ATTACK
}

var velocity = Vector2();
var grid = Vector2();
var anim = ANIM.IDLE;

onready var animplayer = $ViewportContainer/Viewport/PlayerModel/Model/AnimationPlayer;

# Called when the node enters the scene tree for the first time.
func _ready():
	animplayer.play("idle");
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

func update_rotate():
	if(velocity != Vector2(0,0)):
		var nvel = velocity.normalized();
		var angle = atan2(nvel.x, nvel.y);
		$ViewportContainer/Viewport/PlayerModel/Model.rotation.y = angle;

func update_anim():
	if velocity == Vector2(0,0):
		anim = ANIM.IDLE;
	elif sqrt( pow(velocity.x, 2) + pow(velocity.y, 2)) > 0.7:
		anim = ANIM.RUN;
	else:
		anim = ANIM.WALK;

func loop_anim():
	update_anim();
	if anim == ANIM.IDLE:
		animplayer.play("idle");
	elif anim == ANIM.RUN:
		animplayer.play("run");
	elif anim == ANIM.WALK:
		animplayer.play("walk");

func fix_cam():
	$Camera2D.position.x = floor($Camera2D.position.x + 0.5);
	$Camera2D.position.y = floor($Camera2D.position.y + 0.5);

#Called on every frame
func _process(delta):
	update_grid();
	update_rotate();
	#fix_cam();
	loop_anim();

#Called on every frame (For in-game physics processing)
func _physics_process(delta):
	update_pos();
