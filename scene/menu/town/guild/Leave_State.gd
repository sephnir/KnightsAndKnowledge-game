extends Control

var guild = find_parent("Guild");

func _ready():
	guild = find_parent("Guild");

func _process(delta):
	if(guild):
		if(guild.state == guild.GUILD_STATE.LEAVE):
			visible = true;
		else:
			visible = false;


func _on_Btn_Leave_button_down():
	get_tree().change_scene("res://scene/menu/town/menu.tscn");
