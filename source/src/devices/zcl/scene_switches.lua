local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local zcl_device_helpers = require "devices.zcl.helpers"

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

local function build_mixed_scene_switch(profile, relay_count, scene_count, with_indicator, extra)
  local zcl_clusters = copy_list(zcl.multi_switch(relay_count, { component_prefix = "switch" }))
  zcl_device_helpers.append_clusters(zcl_clusters,
    zcl.power_on_behavior(),
    zcl.switch_mode()
  )
  if with_indicator then
    zcl_device_helpers.append_clusters(zcl_clusters, zcl.indicator_mode())
  end

  local definition = {
    profile = profile,
    scene_switch = true,
    button_actions = { "pushed" },
    scene_component_map = build_scene_component_map(relay_count, scene_count),
    zcl_clusters = zcl_clusters,
  }

  for key, value in pairs(extra or {}) do
    definition[key] = value
  end

  return definition
end

local function build_scene_only_switch(profile, scene_count)
  return {
    profile = profile,
    scene_switch = true,
    button_actions = { "pushed" },
    scene_component_map = build_scene_component_map(0, scene_count),
    zcl_clusters = {},
  }
end

local one_gang = build_mixed_scene_switch("scene-switches-1", 1, 0, false)
local two_gang = build_mixed_scene_switch("scene-switches-2", 2, 0, false)
local three_gang = build_mixed_scene_switch("scene-switches-3", 3, 0, false)
local four_gang = build_mixed_scene_switch("scene-switches-4", 4, 0, false)
local multi_one_gang = build_mixed_scene_switch("scene-switches-1-advanced", 1, 0, true)
local multi_two_gang = build_mixed_scene_switch("scene-switches-2-advanced", 2, 0, true)
local multi_three_gang = build_mixed_scene_switch("scene-switches-3-advanced", 3, 0, true)
local multi_four_gang = build_mixed_scene_switch("scene-switches-4-advanced", 4, 0, true)
local four_gang_two_scene = build_mixed_scene_switch("scene-switches-4-plus-2", 4, 2, true)
local four_gang_four_scene = build_mixed_scene_switch("scene-switches-4-plus-4", 4, 4, true)
local switch_4g_2s = build_scene_only_switch("scene-switches-scene-6", 6)
local scene_one = build_scene_only_switch("scene-switches-scene-1", 1)
local scene_two = build_scene_only_switch("scene-switches-scene-2", 2)
local scene_three = build_scene_only_switch("scene-switches-scene-3", 3)
local scene_four = build_scene_only_switch("scene-switches-scene-4", 4)

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

multi_one_gang.scene_action_map = qa_scene_action_map
multi_one_gang.scene_action_name_map = qa_scene_action_name_map
multi_one_gang.scene_component_map = {
  [1] = "main",
  [4] = "main",
}

multi_two_gang.scene_action_map = qa_scene_action_map
multi_two_gang.scene_action_name_map = qa_scene_action_name_map
multi_two_gang.scene_component_map = {
  [1] = "main",
  [4] = "main",
  [2] = "switch2",
  [5] = "switch2",
}

multi_three_gang.scene_action_map = qa_scene_action_map
multi_three_gang.scene_action_name_map = qa_scene_action_name_map
multi_three_gang.scene_component_map = {
  [1] = "main",
  [4] = "main",
  [2] = "switch2",
  [5] = "switch2",
  [3] = "switch3",
  [6] = "switch3",
}

register_device_definition(one_gang, device_helpers.create_fingerprints("TS0726_1_gang", {
  "_TZ3002_l8bfzlcd",
  "_TZ3002_l8bfzlcd:TS0726",
  "_TZ3000_ovbvmhiq:TS0726",
}))

register_device_definition(two_gang, device_helpers.create_fingerprints("TS0726_2_gang", {
  "_TZ3002_1s0vfmtv",
  "_TZ3002_1s0vfmtv:TS0726",
  "_TZ3002_gdwja9a7",
  "_TZ3002_gdwja9a7:TS0726",
  "_TZ3002_u7d3nes3",
  "_TZ3002_u7d3nes3:TS0726",
  "_TZ3000_icoxotza",
  "_TZ3000_icoxotza:TS0726",
}))

register_device_definition(multi_one_gang, device_helpers.create_fingerprints("TS0726_multi_1_gang", {
  "_TZ3002_9vcekkp1",
  "_TZ3002_9vcekkp1:TS0726",
  "_TZ3000_m4ah6bcz",
  "_TZ3000_m4ah6bcz:TS0726",
  "_TZ3000_wopf2sox",
  "_TZ3000_wopf2sox:TS0726",
}))

register_device_definition(multi_two_gang, device_helpers.create_fingerprints("TS0726_multi_2_gang", {
  "_TZ3000_ssup6h68",
  "_TZ3000_ssup6h68:TS0726",
}))

register_device_definition(multi_three_gang, device_helpers.create_fingerprints("TS0726_multi_3_gang", {
  "_TZ3000_m3pafcnk",
  "_TZ3000_m3pafcnk:TS0726",
  "_TZ3002_m3pafcnk",
  "_TZ3002_m3pafcnk:TS0726",
  "_TZ3000_kt6xxa4o",
  "_TZ3000_kt6xxa4o:TS0726",
  "_TZ3002_vaq2bfcu",
  "_TZ3002_vaq2bfcu:TS0726",
}))

register_device_definition(multi_four_gang, device_helpers.create_fingerprints("TS0726_multi_4_gang", {
  "_TZ3002_aewsvjcu",
  "_TZ3002_aewsvjcu:TS0726",
  "_TZ3002_phu8ygaw",
  "_TZ3002_phu8ygaw:TS0726",
}))

register_device_definition(four_gang_two_scene, device_helpers.create_fingerprints("TS0726_4_gang_switch_and_2_scene", {
  "_TZ3000_qhyadm57",
  "_TZ3000_qhyadm57:TS0726",
  "_TZ3000_cumqn2av",
  "_TZ3000_cumqn2av:TS0726",
  "_TZ300A_fhbcipep",
  "_TZ300A_fhbcipep:TS0726",
}))

register_device_definition(four_gang_four_scene, device_helpers.create_fingerprints("TS0726_4_gang_switch_and_4_scene", {
  "_TZ300A_82iab0pn:TS0726",
}))

register_device_definition(three_gang, device_helpers.create_fingerprints("TS0726_3_gang", {
  "_TZ3000_lcjsewlo",
  "_TZ3000_lcjsewlo:TS0726",
  "_TZ3000_kfkqkjqe",
  "_TZ3000_kfkqkjqe:TS0726",
  "_TZ3000_cziew6eu",
  "_TZ3000_cziew6eu:TS0726",
}))

register_device_definition(three_gang, {
  device_helpers.create_fingerprint("Zemismart", "KES-606US-L3-EESS"),
})

register_device_definition(four_gang, device_helpers.create_fingerprints("TS0726_4_gang", {
  "_TZ3000_wsspgtcd",
  "_TZ3000_wsspgtcd:TS0726",
  "_TZ3000_s678wazd",
  "_TZ3000_s678wazd:TS0726",
  "_TZ3002_uu4uircb",
  "_TZ3002_uu4uircb:TS0726",
  "_TZ3002_yptomml1",
  "_TZ3002_yptomml1:TS0726",
  "_TZ3002_pw4ad2xa",
  "_TZ3002_pw4ad2xa:TS0726",
}))

register_device_definition(switch_4g_2s, device_helpers.create_fingerprints("TS0726_switch_4g_2s", {
  "_TZ3002_sal078g8",
  "_TZ3002_sal078g8:TS0726",
  "_TZ3002_sfh0jtz0",
  "_TZ3002_sfh0jtz0:TS0726",
}))

register_device_definition(scene_one, device_helpers.create_fingerprints("TS0726_1_gang_scene_switch", {
  "_TZ3000_5kxl9esg",
  "_TZ3000_5kxl9esg:TS0726",
  "_TZ3002_jn2x20tg",
  "_TZ3002_jn2x20tg:TS0726",
  "_TZ300A_rncj86af",
  "_TZ300A_rncj86af:TS0726",
  "_TZ3002_xkxgfxsg",
  "_TZ3002_xkxgfxsg:TS0726",
}))

register_device_definition(scene_one, {
  device_helpers.create_fingerprint("BSEED", "EC-GL86ZPCS11"),
  device_helpers.create_fingerprint("BSEED", "EC-SL-FK86ZPCS11"),
})

register_device_definition(scene_two, device_helpers.create_fingerprints("TS0726_2_gang_scene_switch", {
  "_TZ3000_ezqbvrqz",
  "_TZ3000_ezqbvrqz:TS0726",
  "_TZ3002_ymv5vytn",
  "_TZ3002_ymv5vytn:TS0726",
  "_TZ3002_6ahhkwyh",
  "_TZ3002_6ahhkwyh:TS0726",
  "_TZ3002_zjuvw9zf",
  "_TZ3002_zjuvw9zf:TS0726",
  "_TZ3002_a4kvf6zd",
  "_TZ3002_a4kvf6zd:TS0726",
  "_TZ300A_ohjmifiz",
  "_TZ300A_ohjmifiz:TS0726",
  "_TZ3002_tlsvxhxc",
  "_TZ3002_tlsvxhxc:TS0726",
}))

register_device_definition(scene_two, {
  device_helpers.create_fingerprint("BSEED", "EC-GL86ZPCS21"),
  device_helpers.create_fingerprint("BSEED", "EC-SL-FK86ZPCS21"),
})

register_device_definition(scene_three, device_helpers.create_fingerprints("TS0726_3_gang_scene_switch", {
  "_TZ3000_noru9tix",
  "_TZ3000_noru9tix:TS0726",
  "_TZ3002_rbnycsav",
  "_TZ3002_rbnycsav:TS0726",
  "_TZ3002_kq3kqwjt",
  "_TZ3002_kq3kqwjt:TS0726",
  "_TZ3002_ybtqbyk3",
  "_TZ3002_ybtqbyk3:TS0726",
  "_TZ3002_iedhxgyi",
  "_TZ3002_iedhxgyi:TS0726",
  "_TZ3002_vsom92pp",
  "_TZ3002_vsom92pp:TS0726",
  "_TZ300A_vqrs45nj",
  "_TZ300A_vqrs45nj:TS0726",
  "_TZ3000_r2fgo9ks",
  "_TZ3000_r2fgo9ks:TS0726",
}))

register_device_definition(scene_three, {
  device_helpers.create_fingerprint("BSEED", "EC-GL86ZPCS31"),
  device_helpers.create_fingerprint("BSEED", "EC-SL-FK86ZPCS31"),
})

register_device_definition(scene_four, device_helpers.create_fingerprints("TS0726_4_gang_scene_switch", {
  "_TZ3000_rsylfthg",
  "_TZ3000_rsylfthg:TS0726",
  "_TZ3002_umdkr64x",
  "_TZ3002_umdkr64x:TS0726",
  "_TZ3002_hkaktryd",
  "_TZ3002_hkaktryd:TS0726",
  "_TZ3002_pzao9ls1",
  "_TZ3002_pzao9ls1:TS0726",
  "_TZ300A_vkflnsl0",
  "_TZ300A_vkflnsl0:TS0726",
  "_TZ3002_eda6eitk",
  "_TZ3002_eda6eitk:TS0726",
  "_TZ3000_hurauima",
  "_TZ3000_hurauima:TS0726",
  "_TZ3002_tdf2m4ch",
  "_TZ3002_tdf2m4ch:TS0726",
}))

register_device_definition(scene_four, {
  device_helpers.create_fingerprint("BSEED_TODO", "TS0726"),
  device_helpers.create_fingerprint("BSEED", "EC-GL86ZPCS41"),
  device_helpers.create_fingerprint("BSEED", "EC-SL-FK86ZPCS41"),
})

return device_definitions
