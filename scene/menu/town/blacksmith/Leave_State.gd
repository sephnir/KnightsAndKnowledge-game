extends Control

onready var blacksmith = find_parent("Blacksmith");

func _process(delta):
	if(blacksmith):
		if(blacksmith.state == blacksmith.BLACKSMITH_STATE.LEAVE):
			visible = true;
		else:
			visible = false;


func _on_Btn_Leave_button_down():
	get_tree().change_scene("res://scene/menu/town/menu.tscn");
