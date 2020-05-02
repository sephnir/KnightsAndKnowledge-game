extends Button

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(self.pressed):
		var login = find_parent("Pnl_Login");
		login._on_login_pressed();	
		self.disabled = true;
	pass
