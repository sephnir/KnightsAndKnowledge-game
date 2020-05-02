extends Control

onready var global = $"/root/Global";

func _ready():
	if(global.current_floor > global.quest.level):
		$"Lbl_Header".text = "Quest Complete!";
		$"Lbl_Message".text = "Your score is \n-- " + str(global.score) + " -- "
		return;

func _on_Btn_Return_button_up():
	get_tree().change_scene("res://scene/menu/town/menu.tscn")
