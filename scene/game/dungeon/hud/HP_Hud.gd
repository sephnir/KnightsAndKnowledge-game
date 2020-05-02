extends Control
onready var global = $"/root/Global";

var heart_full = preload("res://graphics/sprite/heart.png");
var heart_half = preload("res://graphics/sprite/heart_half.png");
var heart_empty = preload("res://graphics/sprite/heart_empty.png");

var heart_size = 76;

func damage():
	global.current_hp -= 1;
	if global.current_hp == 0:
		get_tree().change_scene("res://scene/game/result/Result.tscn");
	
func _process(delta):
	update();

func _draw():
	var ci = 0;
	for i in range(3):
		var hpRect = Rect2(Vector2(50 + i*(heart_size+16), 50), 
			Vector2(heart_size, heart_size));
		
		if(global.current_hp/2 > i):
			draw_texture_rect(heart_full, hpRect, false);
			ci += 1;
		else:
			draw_texture_rect(heart_empty, hpRect, false);
	
	if(global.current_hp % 2 == 1):
		var hpRectHalf = Rect2(Vector2(50 + ci*(heart_size+16), 50), 
			Vector2(heart_size/2, heart_size));
		draw_texture_rect(heart_half, hpRectHalf, false);
#	var ci = 0;
#	for i in range(global.current_hp /2):
#		draw_texture(heart_full,Vector2(50 + i*(heart_size+16), 50));
#		ci = i+1;
		

