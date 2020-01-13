extends Button

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(self.pressed):
		var login = find_parent("Pnl_Login");
		login._on_login_pressed();	
		self.disabled = true;
	pass
