extends Control

onready var global = $"/root/Global";

func _ready():
	if(global.current_floor > global.quest.level):
		$"Lbl_Header".text = "Quest Complete!";
		$"Lbl_Message".text = "You earned \n-- " + str(floor(global.score/10)) + " golds -- \nfrom your adventures!"
		return;

func _on_Btn_Return_button_up():
	get_tree().change_scene("res://scene/menu/town/menu.tscn")
