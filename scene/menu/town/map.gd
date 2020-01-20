extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var api_route = "/api/details";

# Called when the node enters the scene tree for the first time.
func _ready():
	var request_url = "";
	if($"/root/Constants".PORT == 80 || $"/root/Constants".PORT == 0):
		request_url = str("http://",$"/root/Constants".HOSTNAME, api_route);
	else:
		request_url = str("http://",$"/root/Constants".HOSTNAME, ":", $"/root/Constants".PORT, api_route);
	var headers = ["Accept: application/json", "Authorization: Bearer " + $"/root/Global".token];
		
	$HTTPRequest.request(request_url, headers, false, HTTPClient.METHOD_POST);
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = "";
	if(typeof(body) == TYPE_RAW_ARRAY):
		json = JSON.parse(body.get_string_from_utf8());
	else:
		json = JSON.parse(body);
	
	if(response_code == 401):
		get_node("/root/Global").token = "";
		get_tree().change_scene("res://scene/login/login.tscn");
	
	if(json.result != null):
		if(json.result.has("error")):
			$PP_Notice/Lbl_Notice.set_text("Connection error. Please try again.");
			$PP_Notice.popup_centered();
			
		if(json.result.has("success")):
			print(json.result.success);