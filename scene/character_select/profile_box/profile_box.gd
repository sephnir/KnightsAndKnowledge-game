extends Button

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var charId = -1;
var charName = "Create\nNew";
var experience = 0;
var money = 0;
var global;

# Called when the node enters the scene tree for the first time.
func _ready():
	global = get_node("/root/Global");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	get_node("Lbl_Name").text = charName;
	if(charId >= 0):
		$Spr_Plus.visible = false;
		$VpC_Character.visible = true;
	else:
		$Spr_Plus.visible = true;
		$VpC_Character.visible = false;
		


func _on_Btn_Profile_button_up():
	if(charId != -1):
		global.character = charId;
		global.character_name = charName;
		get_tree().change_scene("res://scene/menu/town/menu.tscn");
	else:
		$PU_Create.popup_centered();
		pass;
