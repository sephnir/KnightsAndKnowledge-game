extends Button

onready var global = get_node("/root/Global");

func _on_Btn_Logout_button_up():
	$CD_Logout.popup_centered();


func _on_CD_Logout_confirmed():
	global.token = "";
	global.save_auth("");
	get_tree().change_scene("res://scene/login/login.tscn");
