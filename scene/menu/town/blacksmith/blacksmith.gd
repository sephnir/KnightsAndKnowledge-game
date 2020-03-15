extends Control

enum BLACKSMITH_STATE{
	START,
	JOIN,
	SELECT,
	LEAVE
}

var state=BLACKSMITH_STATE.START;
onready var label = $Pnl_Dialogue/Lbl_Dialogue;

onready var global = $"/root/Global";
onready var routes = $"/root/API";

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Btn_Select_button_up():
	label.text = label.MSG_DICT["select"]
	state = BLACKSMITH_STATE.SELECT;
	
func _on_Btn_Leave_button_up():
	label.text = label.MSG_DICT["leave"]
	state = BLACKSMITH_STATE.LEAVE;
	
func _on_Btn_Back_button_up():
	label.text = label.MSG_DICT["restart"]
	state = BLACKSMITH_STATE.START;


