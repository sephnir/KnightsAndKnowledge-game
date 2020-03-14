extends Control

var blacksmith = find_parent("Blacksmith");

func _ready():
	blacksmith = find_parent("Blacksmith");

func _process(delta):
	if(blacksmith):
		if(blacksmith.state == blacksmith.BLACKSMITH_STATE.START):
			visible = true;
		else:
			visible = false;
