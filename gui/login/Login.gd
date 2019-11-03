extends Panel

var api_route = "/api/login";
var timeout = -1;

func _ready():
	pass # Replace with function body.

func _on_HTTPRequest_request_completed(result, response_code, headers, body ):
	var json = "";
	if(typeof(body) == TYPE_RAW_ARRAY):
		json = JSON.parse(body.get_string_from_utf8());
	else:
		json = JSON.parse(body);
	timeout = -1;
	$Btn_Login.disabled = false;
	$PopupPanel.popup_centered();
	$PopupPanel/Label.set_text(str(json.result));
	print(json.result);

func _on_Btn_Login_button_up():
	var request_url = "";
	if($"/root/Constants".PORT == 80 || $"/root/Constants".PORT == 0):
		request_url = str("http://",$"/root/Constants".HOSTNAME, api_route);
	else:
		request_url = str("http://",$"/root/Constants".HOSTNAME, ":", $"/root/Constants".PORT, api_route);
	print(request_url);
	var headers = ["Content-Type: application/json"]
	var email = $LE_Username.text;
	var password = $LE_Password.text
	var query = build_form_data(email, password);
	print(query)
	$HTTPRequest.request(request_url, headers, false, HTTPClient.METHOD_POST, query);
	timeout = $"/root/Constants".CONNECTION_TIMEOUT;
	$Btn_Login.disabled = true;

func build_form_data(email, password):
	return to_json({"email": email, "password": password});
	
func _process(delta):
	if(timeout>0):
		timeout -= 1;
	elif(timeout==0):
		timeout = -1;
		$HTTPRequest.cancel_request();
		_on_HTTPRequest_request_completed("timeout", 408, [], '{"error":"timeout"}' );