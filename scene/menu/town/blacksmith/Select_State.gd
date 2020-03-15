extends Control

onready var blacksmith = find_parent("Blacksmith");
onready var global = $"/root/Global";
onready var routes = $"/root/API";


func _ready():
	visible = false;

func _process(delta):
	if(blacksmith):
		if(blacksmith.state == blacksmith.BLACKSMITH_STATE.SELECT):
			visible = true;
		else:
			visible = false;
