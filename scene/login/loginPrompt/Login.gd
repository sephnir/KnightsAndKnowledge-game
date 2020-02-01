extends Panel

var api_route = "/api/login";
var timeout = -1;
onready var global = get_node("/root/Global");

func _ready():
	pass;

func _on_HTTPRequest_request_completed(result, response_code, headers, body ):
	var json = "";
	timeout = -1;
	if(typeof(body) == TYPE_RAW_ARRAY):
		json = JSON.parse(body.get_string_from_utf8());
	else:
		json = JSON.parse(body);
	$Btn_Login.disabled = false;
	$Cpn_Loading.visible = false;
	
	print(json.result);
	
	if(json.result != null):
		if(json.result.has("error")):
			$PP_Notice/Lbl_Notice.set_text(str(json.result.error));
			$PP_Notice.popup_centered();
			
		if(json.result.has("success")):
			if(json.result.success.has("token")):
				global.token = json.result.success.token;
	else:
		$PP_Notice/Lbl_Notice.set_text("Unable to connect to server.");
		$PP_Notice.popup_centered();

#Login
func _on_Btn_Login_button_up():
	if($LE_Email.text == "" || $LE_Password.text == ""):
		$PP_Notice/Lbl_Notice.set_text("E-mail/Password cannot be empty.");
		$PP_Notice.popup_centered();
		return;	
	var request_url = "";
	if($"/root/Constants".PORT == 80 || $"/root/Constants".PORT == 0):
		request_url = str("http://",$"/root/Constants".HOSTNAME, api_route);
	else:
		request_url = str("http://",$"/root/Constants".HOSTNAME, ":", $"/root/Constants".PORT, api_route);

	var headers = ["Content-Type: application/json"]
	var email = $LE_Email.text;
	var password = $LE_Password.text
	var query = build_form_data(email, password);
	$HTTPRequest.request(request_url, headers, false, HTTPClient.METHOD_POST, query);
	timeout = $"/root/Constants".CONNECTION_TIMEOUT;
	$Btn_Login.disabled = true;
	$Cpn_Loading.visible = true;

func build_form_data(email, password):
	return to_json({"email": email, "password": password});
	
func _process(delta):
	if(global.token != "" and global.token != null):
		get_tree().change_scene("res://scene/character_select/character_select.tscn");
	
	if(timeout>0):
		timeout -= 1;
	elif(timeout==0):
		timeout = -1;
		$HTTPRequest.cancel_request();
		_on_HTTPRequest_request_completed("timeout", 408, [], '{"error":"Connection timeout.\nPlease try again."}' );
