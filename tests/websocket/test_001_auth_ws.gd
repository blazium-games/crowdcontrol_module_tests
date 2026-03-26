extends GutTest

var credentials := {}
const CACHE_FILE = "user://cc_test_token_ws.json"

func _process(_delta):
	CrowdControl.poll()

func before_all():
	var f = FileAccess.open("res://secrets.json", FileAccess.READ)
	if f:
		credentials = JSON.parse_string(f.get_as_text())
	else:
		push_error("Missing secrets.json!")

func after_all():
	pass

func _load_cached_token() -> bool:
	if not FileAccess.file_exists(CACHE_FILE):
		return false
	var f = FileAccess.open(CACHE_FILE, FileAccess.READ)
	var cache = JSON.parse_string(f.get_as_text())
	if typeof(cache) == TYPE_DICTIONARY and cache.has("token"):
		CrowdControl.set_auth_token(cache["token"], cache.get("refresh", ""))
		return true
	return false

func _save_cached_token():
	var cache = {
		"token": CrowdControl.get_auth_token(),
		"refresh": CrowdControl.get_refresh_token()
	}
	var f = FileAccess.open(CACHE_FILE, FileAccess.WRITE)
	f.store_string(JSON.stringify(cache))

func before_each():
	pass

func test_websocket_authentication():
	watch_signals(CrowdControl)

	if _load_cached_token() and CrowdControl.is_authenticated():
		CrowdControl.connect_to_crowdcontrol("wss://pubsub.crowdcontrol.live/")
		await wait_for_signal(CrowdControl.connection_established, 10.0)
		assert_true(CrowdControl.is_websocket_connected(), "Loaded WS auth token and reconnected")
		return

	CrowdControl.close()
	CrowdControl.set_credentials(credentials.get("applicationID", ""), credentials.get("secret", ""))

	var err = CrowdControl.connect_to_crowdcontrol("wss://pubsub.crowdcontrol.live/")
	assert_eq(err, OK, "Should initiate WebSocket connection")
	
	await wait_for_signal(CrowdControl.connection_established, 10.0)
	assert_signal_emitted(CrowdControl, "connection_established")

	err = CrowdControl.request_authentication_websocket()
	assert_eq(err, OK, "Should write generate-auth-code to socket")

	var url_emitted = await wait_for_signal(CrowdControl.authentication_url_ready, 10.0)
	if url_emitted:
		var url_params = get_signal_parameters(CrowdControl, "authentication_url_ready")
		if url_params != null and url_params.size() > 0:
			print("\n=======================================================")
			print("!!! WEBSOCKET AUTHENTICATION - PLEASE AUTHORIZE IN BROWSER !!!")
			print("Link: ", url_params[0])
			print("Waiting 120 seconds for manual authorization...")
			print("=======================================================\n")

	await wait_for_signal(CrowdControl.authenticated, 120.0)
	assert_signal_emitted(CrowdControl, "authenticated")
	
	var params = get_signal_parameters(CrowdControl, "authenticated")
	if params != null and params.size() > 0:
		assert_true(typeof(params[0]) == TYPE_STRING and params[0].length() > 0, "Token should not be empty")

	assert_true(CrowdControl.is_authenticated(), "CrowdControl should report as authenticated via WebSocket")
	if CrowdControl.is_authenticated():
		_save_cached_token()
