extends Label
onready var global = $"/root/Global";

func _process(delta):
	text = str(global.score);
