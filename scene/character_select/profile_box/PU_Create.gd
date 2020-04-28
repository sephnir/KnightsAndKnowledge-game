extends Popup

onready var global = $"/root/Global";
onready var routes = $"/root/API";

# Click handling for profile creation
func _on_Btn_Create_button_up():
	if($Pnl_Create/LE_Name.text.length() == 0):
		$PUD_Error/Lbl_Msg.text = "Name field cannot be empty.";
		$PUD_Error.popup_centered();
		return;
		
	$Pnl_Create/Btn_Cancel.disabled = true;
	$Pnl_Create/Btn_Create.disabled = true;
	
	var request_url = global.get_request_url(routes.API_CHARA_CREATE);
	var headers = [
		"Content-Type: application/json",
		"Accept: application/json", 
		global.get_bearer()
	];

	var query = to_json({"name": $Pnl_Create/LE_Name.text});
	$HR_CreateChara.request(request_url, headers, false, 
		HTTPClient.METHOD_POST, query);

# Closes profile creation dialog
func _on_Btn_Cancel_button_up():
	visible = false;

# Callback after profile creation success
func _on_HR_CreateChara_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8());
	$Pnl_Create/Btn_Cancel.disabled = false;
	$Pnl_Create/Btn_Create.disabled = false;
	
	if(json.result != null):
		if(json.result.has("error")):
			$PUD_Error/Lbl_Msg.set_text(str(json.result.error));
			$PUD_Error.popup_centered();
		if(json.result.has("success")):
			get_tree().change_scene("res://scene/character_select/character_select.tscn");
