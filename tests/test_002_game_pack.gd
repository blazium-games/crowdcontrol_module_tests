extends GutTest

func test_001_meta_instantiation():
	var meta = CrowdControlGamePackMeta.new()
	assert_not_null(meta, "GamePackMeta instantiated")
	meta.set_game_name("Blazium Test Pack")
	meta.set_description("This is a pack")
	meta.set_release_date("2024-01-01")
	meta.set_platform("PC")
	
	var d = meta.to_json()
	assert_eq(d.has("name"), true)
	assert_eq(d["name"], "Blazium Test Pack")
	assert_eq(d["description"], "This is a pack")
	assert_eq(d["releaseDate"], "2024-01-01")

func test_002_effect_parameters():
	var param = CrowdControlEffectParameter.new()
	assert_not_null(param, "Param instantiated")
	param.set_parameter_id("param1")
	param.set_name("Speed")
	param.set_min_value(1.0)
	param.set_max_value(10.0)
	
	var d = param.to_json()
	assert_eq(d.has("id"), true)
	assert_eq(d["id"], "param1")
	assert_eq(d["min"], 1.0)
	assert_eq(d["max"], 10.0)

func test_003_effect():
	var effect = CrowdControlEffect.new()
	assert_not_null(effect, "Effect instantiated")
	effect.set_effect_id("speed_up")
	effect.set_name("Speed Up")
	effect.set_description("Makes you fast")
	effect.set_price(100)
	
	var param = CrowdControlEffectParameter.new()
	param.set_parameter_id("mult")
	param.set_max_value(5)
	var params = []
	params.append(param)
	effect.set_parameters(params)
	
	var d = effect.to_json()
	assert_eq(d["name"], "Speed Up")
	assert_eq(d["price"], 100)
	assert_eq(d.has("parameters"), true)
	
func test_004_game_pack_export():
	var pack = CrowdControlGamePack.new()
	assert_not_null(pack, "GamePack instantiated")
	
	var meta = CrowdControlGamePackMeta.new()
	meta.set_name("Godot Pack")
	pack.set_pack_meta(meta)
	
	var effect = CrowdControlEffect.new()
	effect.set_effect_id("test_eff")
	effect.set_name("Test Effect")
	pack.add_effect(effect)
	
	var d = pack.to_json()
	assert_eq(d.has("meta"), true)
	assert_eq(d.has("effects"), true)
	assert_eq(d["effects"].has("game"), true)
	assert_eq(d["effects"]["game"].has("test_eff"), true)
