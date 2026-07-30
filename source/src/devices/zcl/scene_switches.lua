local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local zcl_device_helpers = require "devices.zcl.helpers"
local device_management = require "st.zigbee.device_management"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local function copy_list(items)
  local copied = {}
  for _, item in ipairs(items or {}) do
    copied[#copied + 1] = item
  end
  return copied
end

local function build_scene_component_map(relay_count, scene_count)
  local map = {}
  for index = 1, relay_count do
    map[index] = index == 1 and "main" or ("switch" .. tostring(index))
  end
  for index = 1, scene_count do
    local endpoint = relay_count + index
    map[endpoint] = endpoint == 1 and "main" or ("button" .. tostring(endpoint))
  end
  if relay_count == 0 then
    map[1] = "main"
  end
  return map
end

local function bind_on_off_endpoints(endpoint_count)
  return function(driver, device)
    for endpoint = 1, endpoint_count do
      device:send(device_management.build_bind_request(
        device,
        zcl.CLUSTER_ON_OFF,
        driver.environment_info.hub_zigbee_eui,
        endpoint
      ))
    end
  end
end

local function build_mixed_scene_switch(profile, relay_count, scene_count, extra)
  local zcl_clusters = copy_list(zcl.multi_switch(relay_count, { component_prefix = "switch" }))
  table.insert(zcl_clusters, 1, zcl.tuya_magic_packet())
  zcl_device_helpers.append_clusters(zcl_clusters,
    zcl.power_on_behavior(),
    zcl.switch_mode()
  )
  local definition = {
    profile = profile,
    scene_switch = true,
    button_actions = { "pushed" },
    scene_component_map = build_scene_component_map(relay_count, scene_count),
    zcl_clusters = zcl_clusters,
    configure = bind_on_off_endpoints(relay_count + scene_count),
  }

  for key, value in pairs(extra or {}) do
    definition[key] = value
  end

  return definition
end

local one_gang = build_mixed_scene_switch("scene-switches-1", 1, 0)
local two_gang = build_mixed_scene_switch("scene-switches-2", 2, 0)
local three_gang = build_mixed_scene_switch("scene-switches-3", 3, 0)
local four_gang = build_mixed_scene_switch("scene-switches-4", 4, 0)
local multi_one_gang = build_mixed_scene_switch("scene-switches-1-advanced", 1, 0)
local multi_two_gang = build_mixed_scene_switch("scene-switches-2-advanced", 2, 0)
local multi_three_gang = build_mixed_scene_switch("scene-switches-3-advanced", 3, 0)
local multi_four_gang = build_mixed_scene_switch("scene-switches-4-advanced", 4, 0)
local four_gang_two_scene = build_mixed_scene_switch("scene-switches-4-plus-2", 4, 2)
local four_gang_four_scene = build_mixed_scene_switch("scene-switches-4-plus-4", 4, 4)
local scene_one = build_mixed_scene_switch("scene-switches-scene-1", 1, 0)
local scene_two = build_mixed_scene_switch("scene-switches-scene-2", 2, 0)
local scene_three = build_mixed_scene_switch("scene-switches-scene-3", 3, 0)
local scene_four = build_mixed_scene_switch("scene-switches-scene-4", 4, 0)
local coswall_four_two = build_mixed_scene_switch("scene-switches-scene-6", 4, 2)

local qa_one_gang = build_mixed_scene_switch("scene-switches-1-advanced", 1, 0)
local qa_two_gang = build_mixed_scene_switch("scene-switches-2-advanced", 2, 0)
local qa_three_gang = build_mixed_scene_switch("scene-switches-3-advanced", 3, 0)
local moes_three_gang = build_mixed_scene_switch("scene-switches-3-advanced", 3, 0)

local qa_scene_action_map = {
  [1] = 1,
  [2] = 2,
  [3] = 3,
  [4] = 1,
  [5] = 2,
  [6] = 3,
}

local qa_scene_action_name_map = {
  [1] = "1_down",
  [2] = "2_down",
  [3] = "3_down",
  [4] = "1_up",
  [5] = "2_up",
  [6] = "3_up",
}

qa_one_gang.scene_action_map = qa_scene_action_map
qa_one_gang.scene_action_name_map = qa_scene_action_name_map
qa_one_gang.scene_component_map = {
  [1] = "main",
  [4] = "main",
}

qa_two_gang.scene_action_map = qa_scene_action_map
qa_two_gang.scene_action_name_map = qa_scene_action_name_map
qa_two_gang.scene_component_map = {
  [1] = "main",
  [4] = "main",
  [2] = "switch2",
  [5] = "switch2",
}

qa_three_gang.scene_action_map = qa_scene_action_map
qa_three_gang.scene_action_name_map = qa_scene_action_name_map
qa_three_gang.scene_component_map = {
  [1] = "main",
  [4] = "main",
  [2] = "switch2",
  [5] = "switch2",
  [3] = "switch3",
  [6] = "switch3",
}

moes_three_gang.scene_action_map = qa_scene_action_map
moes_three_gang.scene_action_name_map = qa_scene_action_name_map
moes_three_gang.scene_component_map = qa_three_gang.scene_component_map

register_device_definition(one_gang, device_helpers.create_fingerprints("TS0726", {
  "_TZ3002_l8bfzlcd",
  "_TZ3000_ovbvmhiq",
}))

register_device_definition(two_gang, device_helpers.create_fingerprints("TS0726", {
  "_TZ3002_1s0vfmtv",
  "_TZ3002_gdwja9a7",
  "_TZ3002_u7d3nes3",
  "_TZ3000_icoxotza",
}))

register_device_definition(multi_one_gang, device_helpers.create_fingerprints("TS0726", {
  "_TZ3002_9vcekkp1",
  "_TZ3000_m4ah6bcz",
}))

register_device_definition(qa_one_gang, {
  device_helpers.create_fingerprint("_TZ3000_wopf2sox", "TS0726"),
})

register_device_definition(qa_two_gang, device_helpers.create_fingerprints("TS0726", {
  "_TZ3000_ssup6h68",
}))

register_device_definition(multi_three_gang, device_helpers.create_fingerprints("TS0726", {
  "_TZ3000_m3pafcnk",
  "_TZ3002_m3pafcnk",
}))

register_device_definition(qa_three_gang, device_helpers.create_fingerprints("TS0726", {
  "_TZ3000_kt6xxa4o",
}))

register_device_definition(moes_three_gang, device_helpers.create_fingerprints("TS0726", {
  "_TZ3002_vaq2bfcu",
}))

register_device_definition(multi_four_gang, device_helpers.create_fingerprints("TS0726", {
  "_TZ3002_aewsvjcu",
  "_TZ3002_phu8ygaw",
}))

register_device_definition(four_gang_two_scene, device_helpers.create_fingerprints("TS0726", {
  "_TZ3000_qhyadm57",
  "_TZ3000_cumqn2av",
  "_TZ300A_fhbcipep",
}))

register_device_definition(coswall_four_two, device_helpers.create_fingerprints("TS0726", {
  "_TZ3002_sal078g8",
  "_TZ3002_sfh0jtz0",
}))

register_device_definition(four_gang_four_scene, device_helpers.create_fingerprints("TS0726", {
  "_TZ300A_82iab0pn",
}))

register_device_definition(three_gang, device_helpers.create_fingerprints("TS0726", {
  "_TZ3000_lcjsewlo",
  "_TZ3000_kfkqkjqe",
}))

register_device_definition(four_gang, device_helpers.create_fingerprints("TS0726", {
  "_TZ3000_wsspgtcd",
  "_TZ3000_s678wazd",
  "_TZ3002_uu4uircb",
  "_TZ3002_yptomml1",
  "_TZ3002_pw4ad2xa",
}))

register_device_definition(scene_one, device_helpers.create_fingerprints("TS0726", {
  "_TZ3000_5kxl9esg",
  "_TZ3002_jn2x20tg",
  "_TZ300A_rncj86af",
  "_TZ3002_xkxgfxsg",
}))

register_device_definition(scene_two, device_helpers.create_fingerprints("TS0726", {
  "_TZ3000_ezqbvrqz",
  "_TZ3002_ymv5vytn",
  "_TZ3002_6ahhkwyh",
  "_TZ3002_zjuvw9zf",
  "_TZ3002_a4kvf6zd",
  "_TZ300A_ohjmifiz",
  "_TZ3002_tlsvxhxc",
}))

register_device_definition(scene_three, device_helpers.create_fingerprints("TS0726", {
  "_TZ3000_noru9tix",
  "_TZ3002_rbnycsav",
  "_TZ3002_kq3kqwjt",
  "_TZ3002_ybtqbyk3",
  "_TZ3002_iedhxgyi",
  "_TZ3002_vsom92pp",
  "_TZ300A_vqrs45nj",
  "_TZ3000_cziew6eu",
  "_TZ3000_r2fgo9ks",
}))

register_device_definition(scene_four, device_helpers.create_fingerprints("TS0726", {
  "_TZ3000_rsylfthg",
  "_TZ3002_umdkr64x",
  "_TZ3002_hkaktryd",
  "_TZ3002_pzao9ls1",
  "_TZ300A_vkflnsl0",
  "_TZ3002_eda6eitk",
  "_TZ3000_hurauima",
  "_TZ3002_tdf2m4ch",
}))

-- Legacy internal Z2M model aliases remain temporarily matchable during the
-- full fingerprint audit. They are never used as evidence for new exacts.
register_device_definition(one_gang, device_helpers.create_fingerprints("TS0726_1_gang", {
  "_TZ3002_l8bfzlcd",
}))
register_device_definition(two_gang, device_helpers.create_fingerprints("TS0726_2_gang", {
  "_TZ3002_1s0vfmtv", "_TZ3002_gdwja9a7", "_TZ3002_u7d3nes3", "_TZ3000_icoxotza",
}))
register_device_definition(multi_one_gang, device_helpers.create_fingerprints("TS0726_multi_1_gang", {
  "_TZ3002_9vcekkp1", "_TZ3000_m4ah6bcz",
}))
register_device_definition(qa_one_gang, device_helpers.create_fingerprints("TS0726_multi_1_gang", {
  "_TZ3000_wopf2sox",
}))
register_device_definition(qa_two_gang, device_helpers.create_fingerprints("TS0726_multi_2_gang", {
  "_TZ3000_ssup6h68",
}))
register_device_definition(multi_three_gang, device_helpers.create_fingerprints("TS0726_multi_3_gang", {
  "_TZ3000_m3pafcnk", "_TZ3002_m3pafcnk",
}))
register_device_definition(qa_three_gang, device_helpers.create_fingerprints("TS0726_multi_3_gang", {
  "_TZ3000_kt6xxa4o",
}))
register_device_definition(moes_three_gang, device_helpers.create_fingerprints("TS0726_multi_3_gang", {
  "_TZ3002_vaq2bfcu",
}))
register_device_definition(multi_four_gang, device_helpers.create_fingerprints("TS0726_multi_4_gang", {
  "_TZ3002_aewsvjcu", "_TZ3002_phu8ygaw",
}))
register_device_definition(four_gang_two_scene, device_helpers.create_fingerprints("TS0726_4_gang_switch_and_2_scene", {
  "_TZ3000_qhyadm57", "_TZ3000_cumqn2av", "_TZ300A_fhbcipep",
}))
register_device_definition(three_gang, device_helpers.create_fingerprints("TS0726_3_gang", {
  "_TZ3000_lcjsewlo", "_TZ3000_kfkqkjqe",
}))
register_device_definition(four_gang, device_helpers.create_fingerprints("TS0726_4_gang", {
  "_TZ3000_wsspgtcd", "_TZ3000_s678wazd", "_TZ3002_uu4uircb", "_TZ3002_yptomml1", "_TZ3002_pw4ad2xa",
}))
register_device_definition(coswall_four_two, device_helpers.create_fingerprints("TS0726_switch_4g_2s", {
  "_TZ3002_sal078g8", "_TZ3002_sfh0jtz0",
}))
register_device_definition(scene_one, device_helpers.create_fingerprints("TS0726_1_gang_scene_switch", {
  "_TZ3000_5kxl9esg", "_TZ3002_jn2x20tg", "_TZ300A_rncj86af", "_TZ3002_xkxgfxsg",
}))
register_device_definition(scene_two, device_helpers.create_fingerprints("TS0726_2_gang_scene_switch", {
  "_TZ3000_ezqbvrqz", "_TZ3002_ymv5vytn", "_TZ3002_6ahhkwyh", "_TZ3002_zjuvw9zf",
  "_TZ3002_a4kvf6zd", "_TZ300A_ohjmifiz", "_TZ3002_tlsvxhxc",
}))
register_device_definition(scene_three, device_helpers.create_fingerprints("TS0726_3_gang_scene_switch", {
  "_TZ3000_noru9tix", "_TZ3002_rbnycsav", "_TZ3002_kq3kqwjt", "_TZ3002_ybtqbyk3",
  "_TZ3002_iedhxgyi", "_TZ3002_vsom92pp", "_TZ300A_vqrs45nj", "_TZ3000_r2fgo9ks",
}))
register_device_definition(scene_four, device_helpers.create_fingerprints("TS0726_4_gang_scene_switch", {
  "_TZ3000_rsylfthg", "_TZ3002_umdkr64x", "_TZ3002_hkaktryd", "_TZ3002_pzao9ls1",
  "_TZ300A_vkflnsl0", "_TZ3002_eda6eitk", "_TZ3000_hurauima", "_TZ3002_tdf2m4ch",
}))

return device_definitions
