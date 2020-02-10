extends Control

var guild = find_parent("Guild");

func _ready():
	guild = find_parent("Guild");

func _process(delta):
	if(guild):
		if(guild.state == guild.GUILD_STATE.JOIN):
			visible=true;
		else:
			visible=false;
