extends Label

const MSG_DICT = {
	"start": "Welcome! How may I help you?\n",
	"restart": "Anything else I can help you with?\n",
	
	"select": "Please select the guild that you want to participate in.\n",
	"select_success": "You have selected %s!\n",
	"select_fail": "There are no guilds listed. Please try again if you have joined a guild before.\n",
	
	"leave": "Have a safe adventure!\n",
	
	"join": "Please fill in the invitation code provided by your tutor.\n",
	"join_fail": "The invitation code you've type in is not valid.\n",
	"join_success": "You've successfully joined a guild!\nAnything else I can help you with?\n",
};

func _ready():
	text = MSG_DICT["start"];
