local zcl = require "protocol.zcl"
local device_helpers = require "contracts.helpers.family"
local emit = require "capabilities.events.all"
local device_management = require "st.zigbee.device_management"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local function copy_list(items)
  local copied = {}
  for _, item in ipairs(items or {}) do
    copied[#copied + 1] = item
  end
  return copied
end

local function bind_light_endpoints(endpoint_count)
  return function(driver, device)
    for endpoint = 1, endpoint_count do
      for _, cluster_id in ipairs({ zcl.CLUSTER_ON_OFF, zcl.CLUSTER_LEVEL_CONTROL }) do
        device:send(device_management.build_bind_request(
          device,
          cluster_id,
          driver.environment_info.hub_zigbee_eui,
          endpoint
        ))
      end
    end
  end
end

local function build_single_dimmer(profile, options)
  options = options or {}
  local clusters = {
    zcl.tuya_magic_packet(),
    zcl.switch(),
    zcl.tuya_dimmer_level(),
  }
  if options.power_on_behavior then clusters[#clusters + 1] = zcl.power_on_behavior() end
  if options.switch_type then clusters[#clusters + 1] = zcl.ts110e_switch_type({ write_only = true }) end
  if options.countdown then
    clusters[#clusters + 1] = options.countdown_step == 30
      and zcl.ts110e_countdown_timer({ emit = emit.countdownTsOneTenHalfMinute("s") })
      or zcl.ts110e_countdown_timer()
  end
  if options.min_brightness then clusters[#clusters + 1] = zcl.ts110e_min_brightness() end
  if options.max_brightness then clusters[#clusters + 1] = zcl.ts110e_max_brightness() end
  if options.light_type then clusters[#clusters + 1] = zcl.light_type() end

  return {
    profile = profile,
    zcl_clusters = clusters,
    configure = bind_light_endpoints(1),
  }
end

local function build_basic_single_dimmer(profile)
  return {
    profile = profile,
    zcl_clusters = {
      zcl.switch(),
      zcl.level(),
    },
    configure = bind_light_endpoints(1),
  }
end

local function build_basic_single_dimmer_min(profile)
  return {
    profile = profile,
    zcl_clusters = {
      zcl.switch(),
      zcl.level(),
      zcl.min_brightness(),
    },
    configure = bind_light_endpoints(1),
  }
end

local function build_basic_dual_dimmer(profile)
  local zcl_clusters = copy_list(zcl.multi_switch(2, { component_prefix = "switch" }))
  for _, cluster in ipairs(zcl.multi_level(2, { component_prefix = "switch" })) do
    zcl_clusters[#zcl_clusters + 1] = cluster
  end

  return {
    profile = profile,
    zcl_clusters = zcl_clusters,
    configure = bind_light_endpoints(2),
  }
end


local function build_basic_dual_dimmer_min(profile)
  local zcl_clusters = copy_list(zcl.multi_switch(2, { component_prefix = "switch" }))
  for _, cluster in ipairs(zcl.multi_level(2, { component_prefix = "switch" })) do
    zcl_clusters[#zcl_clusters + 1] = cluster
  end
  for endpoint = 1, 2 do
    zcl_clusters[#zcl_clusters + 1] = zcl.min_brightness({
      endpoint = endpoint,
      component = endpoint == 1 and "main" or "switch2",
    })
  end
  return {
    profile = profile,
    zcl_clusters = zcl_clusters,
    configure = bind_light_endpoints(2),
  }
end

local function build_dual_dimmer(profile, options)
  options = options or {}
  local zcl_clusters = copy_list(zcl.multi_switch(2, { component_prefix = "switch" }))
  for _, cluster in ipairs(zcl.multi_level(2, { component_prefix = "switch" })) do
    zcl_clusters[#zcl_clusters + 1] = cluster
  end
  table.insert(zcl_clusters, 1, zcl.tuya_magic_packet())
  if options.power_on_behavior then zcl_clusters[#zcl_clusters + 1] = zcl.power_on_behavior() end
  for endpoint = 1, 2 do
    local component = endpoint == 1 and "main" or "switch2"
    if options.switch_type then
      zcl_clusters[#zcl_clusters + 1] = zcl.ts110e_switch_type({
        endpoint = endpoint,
        component = component,
        write_only = true,
      })
    end
    if options.min_brightness then
      zcl_clusters[#zcl_clusters + 1] = zcl.ts110e_min_brightness({ endpoint = endpoint, component = component })
    end
    if options.max_brightness then
      zcl_clusters[#zcl_clusters + 1] = zcl.ts110e_max_brightness({ endpoint = endpoint, component = component })
    end
  end

  return {
    profile = profile,
    zcl_clusters = zcl_clusters,
    configure = bind_light_endpoints(2),
  }
end

local basic_single_dimmer = build_basic_single_dimmer("lights-dimmer")
local basic_single_dimmer_min = build_basic_single_dimmer_min("lights-dimmer-min")
local basic_dual_dimmer = build_basic_dual_dimmer("lights-dimmer-2")
local basic_dual_dimmer_min = build_basic_dual_dimmer_min("lights-dimmer-2-min")
local single_dimmer = build_single_dimmer("lights-dimmer-options-ts110", {
  power_on_behavior = true,
  switch_type = true,
  countdown = true,
  min_brightness = true,
  max_brightness = true,
  light_type = true,
})
local single_dimmer_countdown30 = build_single_dimmer("lights-dimmer-options-ts110-countdown30", {
  power_on_behavior = true,
  switch_type = true,
  countdown = true,
  countdown_step = 30,
  min_brightness = true,
  max_brightness = true,
  light_type = true,
})
local single_power_switch_minmax = build_single_dimmer("lights-dimmer-ts110-power-switch-minmax", {
  power_on_behavior = true, switch_type = true, min_brightness = true, max_brightness = true,
})
local single_power_switch = build_single_dimmer("lights-dimmer-ts110-power-switch", {
  power_on_behavior = true, switch_type = true,
})
local single_minmax = build_single_dimmer("lights-dimmer-ts110-minmax", {
  min_brightness = true, max_brightness = true,
})
local single_power_minmax = build_single_dimmer("lights-dimmer-ts110-power-minmax", {
  power_on_behavior = true, min_brightness = true, max_brightness = true,
})
local single_min = build_single_dimmer("lights-dimmer-ts110-min", { min_brightness = true })
local dual_power_switch_minmax = build_dual_dimmer("lights-dimmer-2-options-ts110", {
  power_on_behavior = true, switch_type = true, min_brightness = true, max_brightness = true,
})
local dual_power_switch = build_dual_dimmer("lights-dimmer-2-ts110-power-switch", {
  power_on_behavior = true, switch_type = true,
})
local dual_power_switch_min = build_dual_dimmer("lights-dimmer-2-ts110-power-switch-min", {
  power_on_behavior = true, switch_type = true, min_brightness = true,
})
local dual_min = build_dual_dimmer("lights-dimmer-2-ts110-min", { min_brightness = true })

register_device_definition(basic_single_dimmer, device_helpers.create_fingerprints("TS110F", {
  "_TZ3000_estfrmup",
  "_TZ3000_ktuoyvt5",
  "_TZ3210_lfbz816s",
  "_TZ3210_ebbfkvoy",
}))

register_device_definition(basic_dual_dimmer, device_helpers.create_fingerprints("TS110F", {
  "_TZ3000_hexqj6ls",
  "_TZ3000_92chsky7",
}))

register_device_definition(basic_single_dimmer_min, device_helpers.create_fingerprints("TS110F", {
  "_TYZB01_qezuin6k",
}))

register_device_definition(basic_dual_dimmer_min, device_helpers.create_fingerprints("TS110F", {
  "_TYZB01_v8gtiaed",
}))

register_device_definition(single_power_switch_minmax, device_helpers.create_fingerprints("TS110E", {
  "_TZ3210_zxbtub8r",
  "_TZ3210_cyuyd5az",
}))

register_device_definition(single_dimmer_countdown30, device_helpers.create_fingerprints("TS110E", {
  "_TZ3210_ngqk6jia",
}))

register_device_definition(single_dimmer, device_helpers.create_fingerprints("TS110E", {
  "_TZ3210_weaqkhab",
  "_TZ3210_k1msuvg6",
  "_TZ3210_o235agwx",
}))

register_device_definition(single_power_switch, device_helpers.create_fingerprints("TS110E", {
  "_TZ3210_hzdhb62z",
  "_TZ3210_v5yquxma",
}))

register_device_definition(single_power_minmax, device_helpers.create_fingerprints("TS110E", {
  "_TZ3210_ysfo0wla",
}))

register_device_definition(single_minmax, device_helpers.create_fingerprints("TS110E", {
  "_TZ3210_guijtl8k",
  "_TZ3210_hquixjeg",
}))

register_device_definition(single_min, device_helpers.create_fingerprints("TS1101", {
  "_TZ3000_xfs39dbf",
}))

register_device_definition(dual_power_switch_minmax, device_helpers.create_fingerprints("TS110E", {
  "_TZ3210_wdexaypg",
}))

register_device_definition(dual_power_switch_minmax, device_helpers.create_fingerprints("TS110E", {
  "_TZ3210_pagajpog",
  "_TZ3210_4ubylghk",
  "_TZ3210_vfwhhldz",
  "_TZ3210_3mpwqzuu",
  "_TZ3210_mt5xjoy6",
}))

register_device_definition(dual_power_switch, device_helpers.create_fingerprints("TS110E", {
  "_TZ3210_tkkb1ym8",
}))

register_device_definition(dual_min, device_helpers.create_fingerprints("TS1101", {
  "_TZ3000_7ysdnebc",
}))

register_device_definition(dual_power_switch_min, device_helpers.create_fingerprints("TS0052", {
  "_TZ3000_zjtxnoft",
  "_TZ3000_kvwrdf47",
  "_TZ3000_sfibawtr",
}))

return {
  id = "zcl.lights.dimmers",
  registrations = device_definitions,
}
