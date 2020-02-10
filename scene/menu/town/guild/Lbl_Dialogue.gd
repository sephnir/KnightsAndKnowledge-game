extends Label

const MSG_DICT = {
	"start": "Welcome! How may I help you?\n",
	"restart": "Anything else I can help you with?\n",
	"join": "Please fill in the invitation code provided by your tutor.\n",
	"select": "Please select the guild that you want to participate in.\n",
	"leave": "Have a safe adventure!"
};

func _ready():
	text = MSG_DICT["start"];
