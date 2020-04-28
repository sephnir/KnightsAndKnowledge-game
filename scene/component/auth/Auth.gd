extends Node

onready var global = $"/root/Global";
onready var routes = $"/root/API";

# Called when object ready
func _ready():
	var request_url = global.get_request_url(routes.API_USER_SHOW);
	var headers = [
		"Accept: application/json", 
		global.get_bearer()
	];
		
	$HR_Auth.request(request_url, headers, false, HTTPClient.METHOD_POST);
	
# Callback for authentication response
func _on_HR_Auth_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8());
	
	if(json.result != null):
		if(json.result.has("error")):
			$PP_Notice/Lbl_Notice.set_text("Connection error.\nPlease try again.");
			$PP_Notice.popup_centered();

# Callback for automatic authentication failure
func _on_PP_Notice_popup_hide():
	get_node("/root/Global").token = "";
	get_tree().change_scene("res://scene/login/login.tscn");
