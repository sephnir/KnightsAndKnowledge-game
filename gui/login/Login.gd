extends Panel

var api_route = "/api/login"

func _ready():
	pass # Replace with function body.

func _on_HTTPRequest_request_completed(result, response_code, headers, body ):
	var json = JSON.parse(body.get_string_from_utf8());
	$Btn_Login.disabled = false;
	print(json.result);

func _on_Btn_Login_button_up():
	var request_url = str("http://",$"/root/Constants".HOSTNAME, ":", $"/root/Constants".PORT, api_route);
#	request_url = str("http://",$"/root/Constants".HOSTNAME, api_route);
	print(request_url);
	var headers = ["Content-Type: application/json"]
	var email = $LE_Username.text;
	var password = $LE_Password.text
	var query = build_form_data(email, password);
	print(query)
	$HTTPRequest.request(request_url, headers, false, HTTPClient.METHOD_POST, query);
	$Btn_Login.disabled = true;

func build_form_data(email, password):
	return to_json({"email": email, "password": password});