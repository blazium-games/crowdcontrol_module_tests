extends GutTest

var credentials := {}
const CACHE_FILE = "user://cc_test_token_http.json"

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
	if CrowdControl.is_authenticated() or (_load_cached_token() and CrowdControl.is_authenticated()):
		return
		
	CrowdControl.close()
	CrowdControl.set_credentials(credentials.get("applicationID", ""), credentials.get("secret", ""))
	CrowdControl.request_authentication_http()
	var url_emitted = await wait_for_signal(CrowdControl.authentication_url_ready, 10.0)
	if url_emitted:
		var url_params = get_signal_parameters(CrowdControl, "authentication_url_ready")
		if url_params != null and url_params.size() > 0:
			print("\nPLEASE AUTHORIZE (HTTP REPORTS TEST): ", url_params[0])
		
	await wait_for_signal(CrowdControl.authenticated, 120.0)
	if CrowdControl.is_authenticated():
		_save_cached_token()

func test_report_effects():
	watch_signals(CrowdControl)

	var ids = PackedStringArray()
	ids.append("effect_1")
	ids.append("effect_2")

	var err = CrowdControl.report_effects(ids, CrowdControl.MENU_VISIBLE)
	assert_eq(err, OK, "Should queue HTTP effect reporting")
