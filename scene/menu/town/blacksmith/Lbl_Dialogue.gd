extends Label

const MSG_DICT = {
	"start": "Hey young'n! Y'need anythin'?\n",
	"restart": "Anythin' else?\n",
	
	"select": "Select a color fer yer armor.\n",
	"select_success": "Here ya go!\n",
	"select_fail": "\n",
	
	"leave": "Be seein' ye!\n",
	
	"join": "Please fill in the invitation code provided by your tutor.\n",
	"join_fail": "The invitation code you've type in is not valid.\n",
	"join_success": "You've successfully joined a guild!\nAnything else I can help you with?\n",
};

func _ready():
	text = MSG_DICT["start"];
