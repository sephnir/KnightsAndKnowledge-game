extends Control
onready var global = $"/root/Global";

var heart_full = preload("res://graphics/sprite/heart.png");
var heart_half = preload("res://graphics/sprite/heart_half.png");
var heart_empty = preload("res://graphics/sprite/heart_empty.png");

var heart_size = 76;

func damage():
	global.current_hp -= 1;
	update();

func _draw():
	for i in range(3):
		draw_texture(heart_empty,Vector2(50 + i*(heart_size+16), 50));
	
	var ci = 0;
	for i in range(global.current_hp /2):
		draw_texture(heart_full,Vector2(50 + i*(heart_size+16), 50));
		ci = i+1;
		
	if(global.current_hp % 2 == 1):
		draw_texture(heart_half,Vector2(50 + ci*(heart_size+16), 50));
