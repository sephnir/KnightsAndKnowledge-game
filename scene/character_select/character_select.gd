extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var api_detail_route = "/api/character/details";
var api_create_route = "/api/character/create";
var panel = [];

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup profile panel instances
	panel.append(get_node("MgC_ProfileList/VBox_ProfileList/HBox_ProfileList/Pnl_Profile1"));
	panel.append(get_node("MgC_ProfileList/VBox_ProfileList/HBox_ProfileList/Pnl_Profile2"));
	panel.append(get_node("MgC_ProfileList/VBox_ProfileList/HBox_ProfileList/Pnl_Profile3"));
	
	var request_url = "";
	if($"/root/Constants".PORT == 80 || $"/root/Constants".PORT == 0):
		request_url = str("http://",$"/root/Constants".HOSTNAME, api_detail_route);
	else:
		request_url = str("http://",$"/root/Constants".HOSTNAME, ":", $"/root/Constants".PORT, api_detail_route);
	var headers = ["Accept: application/json", "Authorization: Bearer " + $"/root/Global".token];
	
	$Cpn_Loading.visible = true;
	$HTTPRequest.request(request_url, headers, false, HTTPClient.METHOD_POST);
	
# Function callback after fetching character data from API call
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = "";
	if(typeof(body) == TYPE_RAW_ARRAY):
		json = JSON.parse(body.get_string_from_utf8());
	else:
		json = JSON.parse(body);
	
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
			
			print(json.result.success);
			$Cpn_Loading.visible = false;
