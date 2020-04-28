extends Label

onready var global = $"/root/Global";

# Display guild name of the currently active guild
func _process(delta):
	if(global.guild_name):
		visible = true;
		text = "Current active guild: \n(%s) %s" % [global.guild_token, global.guild_name];
	else:
		visible = false;
