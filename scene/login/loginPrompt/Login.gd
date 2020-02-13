extends Panel

var timeout = -1;
var temp_token = "";
onready var global = get_node("/root/Global");
onready var routes = get_node("/root/API");

# Called when the node enters the scene tree for the first time.
func _ready():
	temp_token = str(global.load_auth());
	$Cpn_Loading.visible = false;
	if(temp_token != null && temp_token != ""):
		$Btn_Login.disabled = true;
		$Cpn_Loading.visible = true;
		auth_check();

func auth_check():
	timeout = global.CONNECTION_TIMEOUT;
	var request_url = global.get_request_url(routes.API_USER_SHOW);
	var headers = ["Accept: application/json", "Authorization: Bearer " + temp_token];
	$HR_Auth.request(request_url, headers, false, HTTPClient.METHOD_POST);

# Function callback from authenticating token API call
func _on_HR_Auth_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8());
	timeout = -1;
	if(json.result != null):
		if(json.result.has("success")):
			global.token = global.load_auth();
			return;
	global.save_auth("");
	$Btn_Login.disabled = false;
	$Cpn_Loading.visible = false;

# Function callback from login API call
func _on_HR_Login_request_completed(result, response_code, headers, body ):
	var json = JSON.parse(body.get_string_from_utf8());
	timeout = -1;
	$Btn_Login.disabled = false;
	$Cpn_Loading.visible = false;
	
	if(json.result != null):
		if(json.result.has("error")):
			$PP_Notice/Lbl_Notice.set_text(str(json.result.error));
			$PP_Notice.popup_centered();
			
		if(json.result.has("success")):
			if(json.result.success.has("token")):
				global.token = json.result.success.token;
				global.save_auth(global.token);
	else:
		$PP_Notice/Lbl_Notice.set_text("Unable to connect to server.");
		$PP_Notice.popup_centered();

#Login
func _on_Btn_Login_button_up():
	if($LE_Email.text == "" || $LE_Password.text == ""):
		$PP_Notice/Lbl_Notice.set_text("E-mail/Password cannot be empty.");
		$PP_Notice.popup_centered();
		return;	
	var request_url = global.get_request_url(routes.API_USER_LOGIN);
	var headers = [
		"Content-Type: application/json", 
		"Accept: application/json"
	]
	var email = $LE_Email.text;
	var password = $LE_Password.text
	var query = build_form_data(email, password);
	$HR_Login.request(request_url, headers, false, HTTPClient.METHOD_POST, query);
	timeout = global.CONNECTION_TIMEOUT;
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
		$HR_Auth.cancel_request();
		$HR_Login.cancel_request();
		var error = '{"error":"Connection timeout.\nPlease try again."}';
		_on_HR_Login_request_completed("timeout", 408, [], error.to_utf8());



