local zcl = require "protocol.zcl"
local device_helpers = require "contracts.helpers.family"
local emit = require "capabilities.events.all"
local device_management = require "st.zigbee.device_management"
local data_types = require "st.zigbee.data_types"

local device_definitions, register_device_definition = device_helpers.definition_registry()

-- Z2M v26.99.0 sonoff.ts: IAS alarm_1 is the CO alarm,
-- msCarbonMonoxide/measuredValue is ppm, and the eWeLink battery helper
-- reports percentage and voltage on a 3600..7200 second cadence.
local ewelink_7037_co_sensor = {
  profile = "safety-co-detector-battery-voltage-ewelink-7037",
  zcl_clusters = {
    zcl.carbon_monoxide({ read_on_configure = true }),
    zcl.cluster_attribute(0x040C, 0x0000, {
      name = "ewelink_7037_carbon_monoxide_level",
      endpoint = 1,
      emit = emit.carbon_monoxide_level(),
      data_type = data_types.SinglePrecisionFloat,
      read_on_configure = true,
    }),
    zcl.battery({
      endpoint = 1,
      minimum_interval = 3600,
      maximum_interval = 7200,
      reportable_change = 2,
      read_on_configure = true,
    }),
    zcl.battery_voltage({
      endpoint = 1,
      minimum_interval = 3600,
      maximum_interval = 7200,
      reportable_change = 100,
      read_on_configure = true,
    }),
  },
  configure = function(driver, device)
    for _, cluster_id in ipairs({
      zcl.CLUSTER_POWER_CONFIGURATION,
      0x0020, -- genPollCtrl
      0x040C, -- msCarbonMonoxide
      0x0500, -- ssIasZone
    }) do
      device:send(device_management.build_bind_request(
        device,
        cluster_id,
        driver.environment_info.hub_zigbee_eui,
        1
      ))
    end
  end,
}

register_device_definition(ewelink_7037_co_sensor, {
  device_helpers.create_fingerprint("eWeLink", "CK-TLSR8656-Z123SE24DY-01(7037)"),
})

return {
  id = "zcl.sensors.z2m_absorption_ewelink_7037",
  registrations = device_definitions,
}
