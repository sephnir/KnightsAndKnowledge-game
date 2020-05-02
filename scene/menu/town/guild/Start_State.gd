extends Control

onready var guild = find_parent("Guild");

func _process(delta):
	if(guild):
		if(guild.state == guild.GUILD_STATE.START):
			visible = true;
		else:
			visible = false;
