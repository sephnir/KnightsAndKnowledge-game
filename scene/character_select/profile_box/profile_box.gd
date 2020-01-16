extends Button

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var charId = -1;
var charName = "Create\nNew";
var experience = 0;
var money = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	get_node("Lbl_Name").text = charName;
	if(charId >= 0):
		get_node("Spr_Plus").visible = false;
	else:
		get_node("Spr_Plus").visible = true;
		


func _on_Btn_Profile_button_up():
	print(charId);
	pass # Replace with function body.
