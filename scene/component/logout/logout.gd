extends Button

onready var global = get_node("/root/Global");

func _on_Btn_Logout_button_up():
	global.token = "";
	global.save_auth("");
	get_tree().change_scene("res://scene/login/login.tscn");
