-- Wave14 QA QAT44Z4H/QAT44Z6H source-only candidates.
-- Frozen Zigbee2MQTT v26.99.0: src/devices/qa.ts:182-251 and
-- src/lib/legacy.ts fz.tuya_switch/tz.tuya_switch_state.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local device_management = require "st.zigbee.device_management"

local device_definitions, register_device_definition = device_helpers.definition_registry()
local CLUSTER_ON_OFF = 0x0006

local function bind_legacy_switch_endpoints(endpoint_count)
  return function(driver, device)
    for endpoint = 1, endpoint_count do
      device:send(device_management.build_bind_request(
        device,
        CLUSTER_ON_OFF,
        driver.environment_info.hub_zigbee_eui,
        endpoint
      ))
    end
  end
end

local function qa_definition(profile, gang_count)
  local datapoints = {}
  local component_to_endpoint_map = {}
  local endpoint_to_component_map = { [1] = "main" }

  for channel = 1, gang_count do
    local component = channel == 1 and "main" or ("switch" .. tostring(channel))
    datapoints[#datapoints + 1] = tuya.dp_on_off(channel, {
      name = "switch",
      component = component,
      endpoint = 1,
      emit = emit.switch(),
    })
    component_to_endpoint_map[component] = 1
  end

  return {
    profile = profile,
    package_group = "wave14-switch",
    transport_classification = "EF00_LEGACY_DP",
    z2m_converter_source = "legacy.fz.tuya_switch + legacy.tz.tuya_switch_state",
    wire_cluster = "manuSpecificTuya",
    magic_packet = false,
    query_on_configure = false,
    datapoints = datapoints,
    component_to_endpoint_map = component_to_endpoint_map,
    endpoint_to_component_map = endpoint_to_component_map,
    configure = bind_legacy_switch_endpoints(gang_count),
  }
end

local qat44z4h = qa_definition("switches-wave14-qa-qat44z4h", 4)
local qat44z6h = qa_definition("switches-wave14-qa-qat44z6h", 6)

register_device_definition(qat44z4h, {
  device_helpers.create_fingerprint("_TZE204_kyzjsjo3", "TS0601"),
})
register_device_definition(qat44z6h, {
  device_helpers.create_fingerprint("_TZE204_4cl0dzt4", "TS0601"),
})

return {
  id = "wave14.qa.legacy_switches",
  registrations = device_definitions,
}
