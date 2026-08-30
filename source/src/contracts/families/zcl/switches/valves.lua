local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local device_management = require "st.zigbee.device_management"

local device_definitions, register_device_definition = device_helpers.definition_registry()

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

local function encode_uint32_be(value)
  return string.char(
    math.floor(value / 0x1000000) % 0x100,
    math.floor(value / 0x10000) % 0x100,
    math.floor(value / 0x100) % 0x100,
    value % 0x100
  )
end

local smart_valve = {
  profile = "valves-valve-indicator-mode",
  zcl_clusters = {
    zcl.switch("valve", {
      emit = emit.valve(),
      from_device = function(value)
        if value then
          return "open"
        end

        return "closed"
      end,
    }),
    zcl.indicator_mode(),
    zcl.tuya_magic_packet(),
  },
  configure = bind_on_off_endpoints(1),
}

local battery_valve = {
  profile = "valves-valve-battery",
  zcl_clusters = {
    zcl.switch("valve", {
      emit = emit.valve(),
      from_device = function(value)
        if value then
          return "open"
        end

        return "closed"
      end,
    }),
    zcl.battery(),
  },
}

local lyai14_valve = {
  profile = "valves-lyai14-minimal",
  zcl_clusters = {
    zcl.switch("valve", {
      emit = emit.valve(),
      from_device = function(value)
        if value then
          return "open"
        end

        return "closed"
      end,
    }),
    zcl.battery(),
  },
}

local haozee_countdown_valve = {
  profile = "valves-haozee-hz-wt02",
  zcl_clusters = {
    zcl.switch("valve", {
      emit = emit.valve(),
      from_device = function(value)
        if value then
          return "open"
        end

        return "closed"
      end,
    }),
    zcl.battery(),
    zcl.ts0049_countdown_timer({
      name = "haozee_hz_wt02_water_countdown",
      emit = emit.haozeeHzWt02WaterCountdown(),
      to_device = function(value)
        local minutes = math.floor(tonumber(value) + 0.5)
        return string.char(0x0B) .. encode_uint32_be(minutes * 60)
      end,
      numeric_range = {
        minimum = 1,
        maximum = 1440,
        step = 1,
        unit = "min",
      },
    }),
  },
}

local function build_valve_zone(endpoint, component)
  return zcl.switch("valve", {
    endpoint = endpoint,
    component = component,
    emit = emit.valve(),
    from_device = function(value)
      if value then
        return "open"
      end

      return "closed"
    end,
  })
end

local multi_zone_valve = {
  profile = "valves-valve-5",
  zcl_clusters = {
    build_valve_zone(1, "main"),
    build_valve_zone(2, "valve2"),
    build_valve_zone(3, "valve3"),
    build_valve_zone(4, "valve4"),
    build_valve_zone(5, "valve5"),
    zcl.tuya_magic_packet(),
    zcl.power_on_behavior(),
    zcl.child_lock(),
    zcl.countdown_timer(),
  },
  configure = bind_on_off_endpoints(5),
}

register_device_definition(smart_valve, device_helpers.create_fingerprints("TS0111", {
  "_TYZB01_ymcdbl3u",
}))

register_device_definition(smart_valve, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_rk2yzt0u",
  "_TZ3000_o4cjetlm",
}))

register_device_definition(smart_valve, device_helpers.create_fingerprints("TS0001", {
  "_TZ3000_o4cjetlm",
  "_TZ3000_iedbgyxt",
  "_TZ3000_h3noz0a5",
  "_TYZB01_4tlksk8a",
  "_TZ3000_5ucujjts",
  "_TZ3000_h8ngtlxy",
  "_TZ3000_w0ypwa1f",
  "_TZ3000_wpueorev",
  "_TZ3000_cmcjbqup",
}))

register_device_definition(smart_valve, device_helpers.create_fingerprints("TS0011", {
  "_TYZB01_rifa0wlb",
}))

register_device_definition(battery_valve, device_helpers.create_fingerprints("TS0049", {
  "_TZ3000_5af5r192",
  "_TZ3000_cjfmu5he",
  "_TZ3000_mq4wujmp",
  "_TZ3000_ogjpfoyn",
}))

register_device_definition(battery_valve, {
  device_helpers.create_fingerprint("UHome", "TWV"),
})

register_device_definition(haozee_countdown_valve, device_helpers.create_fingerprints("TS0049", {
  "_TZ3000_kz1anoi8",
}))

register_device_definition(lyai14_valve, device_helpers.create_fingerprints("TS0049", {
  "_TZ3290_ixd9mvv4",
}))

register_device_definition(multi_zone_valve, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_j0ktmul1",
}))

return {
  id = "zcl.switches.valves",
  registrations = device_definitions,
}
