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
	if CrowdControl.is_authenticated() and CrowdControl.is_websocket_connected():
		return
		
	if _load_cached_token() and CrowdControl.is_authenticated():
		CrowdControl.connect_to_crowdcontrol("wss://pubsub.crowdcontrol.live/")
		await wait_for_signal(CrowdControl.connection_established, 10.0)
		if CrowdControl.is_websocket_connected():
			return

	CrowdControl.close()
	CrowdControl.set_credentials(credentials.get("applicationID", ""), credentials.get("secret", ""))
	CrowdControl.connect_to_crowdcontrol("wss://pubsub.crowdcontrol.live/")
	await wait_for_signal(CrowdControl.connection_established, 10.0)
	
	CrowdControl.request_authentication_websocket()
	var url_emitted = await wait_for_signal(CrowdControl.authentication_url_ready, 10.0)
	if url_emitted:
		var url_params = get_signal_parameters(CrowdControl, "authentication_url_ready")
		if url_params != null and url_params.size() > 0:
			print("\nPLEASE AUTHORIZE (WS EFFECTS TEST): ", url_params[0])
		
	await wait_for_signal(CrowdControl.authenticated, 120.0)
	if CrowdControl.is_authenticated():
		_save_cached_token()

func test_respond_instant_effect():
	watch_signals(CrowdControl)

	var err = CrowdControl.respond_to_effect_instant("fake_req_123", CrowdControl.STATUS_SUCCESS, "Effect applied successfully")
	assert_eq(err, OK, "Should write instant effect response to WebSocket")

func test_respond_timed_effect():
	watch_signals(CrowdControl)

	var err = CrowdControl.respond_to_effect_timed("fake_req_456", CrowdControl.STATUS_TIMED_BEGIN, 60000, "Timed effect started")
	assert_eq(err, OK, "Should write timed effect response to WebSocket")

func test_effect_changecolor():
	watch_signals(CrowdControl)
	var err = CrowdControl.respond_to_effect_instant("req_changecolor_123", CrowdControl.STATUS_SUCCESS, "Color changed successfully")
	assert_eq(err, OK, "Should write instant response for changecolor")

func test_effect_invertcontrols():
	watch_signals(CrowdControl)
	var err = CrowdControl.respond_to_effect_timed("req_invertcontrols_123", CrowdControl.STATUS_TIMED_BEGIN, 30000, "Invert Controls started")
	assert_eq(err, OK, "Should write timed response for invertcontrols")

func test_effect_takecoins():
	watch_signals(CrowdControl)
	var err = CrowdControl.respond_to_effect_instant("req_takecoins_123", CrowdControl.STATUS_SUCCESS, "Coins taken")
	assert_eq(err, OK, "Should write instant response for takecoins")

func test_effect_givecoins():
	watch_signals(CrowdControl)
	var err = CrowdControl.respond_to_effect_instant("req_givecoins_123", CrowdControl.STATUS_SUCCESS, "Coins given")
	assert_eq(err, OK, "Should write instant response for givecoins")

func test_effect_recover():
	watch_signals(CrowdControl)
	var err = CrowdControl.respond_to_effect_instant("req_recover_123", CrowdControl.STATUS_SUCCESS, "Health recovered")
	assert_eq(err, OK, "Should write instant response for recover")

func test_effect_damageplayer():
	watch_signals(CrowdControl)
	var err = CrowdControl.respond_to_effect_instant("req_damageplayer_123", CrowdControl.STATUS_SUCCESS, "Player damaged")
	assert_eq(err, OK, "Should write instant response for damageplayer")

func test_effect_jump():
	watch_signals(CrowdControl)
	var err = CrowdControl.respond_to_effect_instant("req_jump_123", CrowdControl.STATUS_SUCCESS, "Jumped")
	assert_eq(err, OK, "Should write instant response for jump")
