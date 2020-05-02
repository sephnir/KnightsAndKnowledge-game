extends Button

var charId = -1;
var charName = "Create\nNew";
var experience = 0;
var money = 0;
var global;

var animTimer = 0;
onready var animplayer = $VpC_Character/Viewport/PlayerModel/Model/AnimationPlayer;

# Called when the node enters the scene tree for the first time.
func _ready():
	global = get_node("/root/Global");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	animTimer = fmod(animTimer + 0.02, 360); 
	$VpC_Character/Viewport/PlayerModel/Model.rotation.y = animTimer;
	animplayer.play("walk");
	
	get_node("Lbl_Name").text = charName;
	if(charId >= 0):
		$Spr_Plus.visible = false;
		$VpC_Character.visible = true;
	else:
		$Spr_Plus.visible = true;
		$VpC_Character.visible = false;
		

# Click handling for profile selection
func _on_Btn_Profile_button_up():
	if(charId != -1):
		global.character = charId;
		global.character_name = charName;
		get_tree().change_scene("res://scene/menu/town/menu.tscn");
	else:
		$PU_Create.popup_centered();
		pass;
