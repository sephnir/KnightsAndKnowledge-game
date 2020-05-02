extends Label

onready var global = $"/root/Global";

# Called when the node enters the scene tree for the first time.
func _ready():
	text = "Welcome, \n%s!" % global.character_name;
