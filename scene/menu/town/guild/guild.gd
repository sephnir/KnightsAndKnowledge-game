extends Control

enum GUILD_STATE{
	START,
	JOIN,
	SELECT,
	LEAVE
}

var state=GUILD_STATE.START;
onready var label = $Pnl_Dialogue/Lbl_Dialogue;

onready var global = $"/root/Global";
onready var routes = $"/root/API";

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if(global.guild_name):
		$Lbl_Active.visible = true;
		$Lbl_Active.text = "Current active guild: (%s) %s" % [global.guild_token, global.guild_name];
	else:
		$Lbl_Active.visible = false;

func _on_Btn_Join_button_up():
	label.text = label.MSG_DICT["join"]
	state = GUILD_STATE.JOIN;

func _on_Btn_Select_button_up():
	label.text = label.MSG_DICT["select"]
	state = GUILD_STATE.SELECT;
	
func _on_Btn_Leave_button_up():
	label.text = label.MSG_DICT["leave"]
	state = GUILD_STATE.LEAVE;
	
func _on_Btn_Back_button_up():
	label.text = label.MSG_DICT["restart"]
	state = GUILD_STATE.START;


