extends Node2D

# Declare member variables here. Examples:
onready var global = $"/root/Global";
onready var routes = $"/root/API";

var panel = [];

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup profile panel instances
	panel.append(get_node("MgC_ProfileList/VBox_ProfileList/HBox_ProfileList/Pnl_Profile1"));
	panel.append(get_node("MgC_ProfileList/VBox_ProfileList/HBox_ProfileList/Pnl_Profile2"));
	panel.append(get_node("MgC_ProfileList/VBox_ProfileList/HBox_ProfileList/Pnl_Profile3"));
	
	var request_url = global.get_request_url(routes.API_CHARA_SHOW);
	var headers = [
		"Content-Type: application/json", 
		"Accept: application/json",
		global.get_bearer()
	]
	
	$Cpn_Loading.visible = true;
	$HTTPRequest.request(request_url, headers, false, HTTPClient.METHOD_POST);
	
# Function callback after fetching character data from API call
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8());
	
	if(json.result != null):
		if(json.result.has("error")):
			get_node("/root/Global").token = "";
			get_tree().change_scene("res://scene/main.tscn");
			
		if(json.result.has("success")):
			var ind = 0;
			for result in json.result.success:
				if(ind > 2 || result == null):
					break;
				panel[ind].charId = result.id;
				panel[ind].charName = result.name;
				panel[ind].experience = result.experience;
				panel[ind].money = result.money;
				ind += 1;
			
			$Cpn_Loading.visible = false;
