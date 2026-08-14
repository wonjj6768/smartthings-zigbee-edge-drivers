local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local zcl_device_helpers = require "devices.zcl.helpers"
local emit = require "emitters"
local data_types = require "st.zigbee.data_types"
local device_management = require "st.zigbee.device_management"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function bind_metered_endpoints(endpoint_count, include_level)
return function(driver, device)
for endpoint = 1, endpoint_count do
local cluster_ids = {
zcl.CLUSTER_ON_OFF,
zcl.CLUSTER_ELECTRICAL_MEASUREMENT,
zcl.CLUSTER_SIMPLE_METERING,
}
if include_level then table.insert(cluster_ids, 2, zcl.CLUSTER_LEVEL_CONTROL) end
for _, cluster_id in ipairs(cluster_ids) do
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
local metered_plug = {
profile = "plugs-switch-power-energy-voltage-current",
zcl_clusters = zcl_device_helpers.metering_clusters({
include_switch = true,
include_current = true,
}),
configure = bind_metered_endpoints(1, false),
}
local power_strip = {
profile = "plugs-shelly-power-strip-4",
zcl_clusters = {},
configure = bind_metered_endpoints(4, false),
}
for endpoint = 1, 4 do
local component = endpoint == 1 and "main" or ("switch" .. endpoint)
for _, cluster in ipairs({
zcl.switch({ endpoint = endpoint, component = component }),
zcl.power({ endpoint = endpoint, component = component }),
zcl.energy({ endpoint = endpoint, component = component }),
zcl.voltage({ endpoint = endpoint, component = component }),
zcl.current({ endpoint = endpoint, component = component }),
}) do
power_strip.zcl_clusters[#power_strip.zcl_clusters + 1] = cluster
end
end
local dimmer_light = {
profile = "lights-dimmer-power-voltage-current",
zcl_clusters = {
zcl.switch(),
zcl.level(),
zcl.power(),
zcl.voltage(),
zcl.current(),
zcl.energy(),
},
configure = bind_metered_endpoints(1, true),
}
local water_sensor = {
profile = "safety-water-leak-tamper-battery-low-battery-hardware-fault-shelly",
zcl_clusters = {
zcl.water(),
zcl.tamper(),
zcl.battery_low(),
zcl.hardware_fault(),
zcl.battery(),
},
}
local temp_humidity = {
profile = "sensors-temp-humidity-battery",
zcl_clusters = {
zcl.temperature(),
zcl.humidity(),
zcl.battery(),
},
}
local temp_humidity_illuminance = {
profile = "sensors-illuminance-temp-humidity-battery",
zcl_clusters = {
zcl.temperature(),
zcl.humidity(),
zcl.illuminance(),
zcl.battery(),
},
}
local weather_station = {
profile = "sensors-weather-temp-humidity-pressure-illuminance-battery-ws90",
zcl_clusters = {
zcl.temperature(),
zcl.humidity(),
zcl.pressure(),
zcl.illuminance(),
zcl.battery(),
zcl.cluster_attribute(0xFC01, 0x0000, {
name = "ws90_wind_speed",
emit = emit.ws90WindSpeed(),
data_type = data_types.Uint16,
scale = 10,
mfg_code = 0x1490,
minimum_interval = 10,
maximum_interval = 3600,
reportable_change = 1,
read_on_configure = true,
}),
zcl.cluster_attribute(0xFC01, 0x0004, {
name = "ws90_wind_direction",
emit = emit.ws90WindDirection(),
data_type = data_types.Uint16,
scale = 10,
mfg_code = 0x1490,
minimum_interval = 10,
maximum_interval = 3600,
reportable_change = 1,
read_on_configure = true,
}),
zcl.cluster_attribute(0xFC01, 0x0007, {
name = "ws90_gust_speed",
emit = emit.ws90GustSpeed(),
data_type = data_types.Uint16,
scale = 10,
mfg_code = 0x1490,
minimum_interval = 10,
maximum_interval = 3600,
reportable_change = 1,
read_on_configure = true,
}),
zcl.cluster_attribute(0xFC02, 0x0000, {
name = "ws90_uv_index",
emit = emit.ws90UvIndex(),
data_type = data_types.Uint8,
scale = 10,
mfg_code = 0x1490,
minimum_interval = 10,
maximum_interval = 3600,
reportable_change = 1,
read_on_configure = true,
}),
zcl.cluster_attribute(0xFC03, 0x0000, {
name = "ws90_rain_status",
emit = emit.ws90RainStatus(),
data_type = data_types.Boolean,
mfg_code = 0x1490,
from_device = function(value) return value and "raining" or "dry" end,
minimum_interval = 10,
maximum_interval = 3600,
reportable_change = 1,
read_on_configure = true,
}),
zcl.cluster_attribute(0xFC03, 0x0001, {
name = "ws90_precipitation",
emit = emit.ws90Precipitation(),
data_type = data_types.Uint24,
scale = 10,
mfg_code = 0x1490,
minimum_interval = 10,
maximum_interval = 3600,
reportable_change = 1,
read_on_configure = true,
}),
},
}
local contact_illuminance = {
profile = "safety-contact-illuminance-battery-low-handle-shelly",
zcl_clusters = {
zcl.contact(),
zcl.shelly_handle_position(),
zcl.battery_low(),
zcl.illuminance(),
zcl.battery(),
},
}
local motion_illuminance = {
profile = "safety-motion-illuminance-battery-low-battery",
zcl_clusters = { zcl.motion(), zcl.illuminance(), zcl.battery_low(), zcl.battery() },
}
register_device_definition(metered_plug, {
device_helpers.create_fingerprint("Shelly", "Plug US"),
})
register_device_definition(power_strip, {
device_helpers.create_fingerprint("Shelly", "Power Strip"),
})
register_device_definition(dimmer_light, {
device_helpers.create_fingerprint("Shelly", "Dimmer"),
device_helpers.create_fingerprint("Shelly", "Dimmer US"),
})
register_device_definition(water_sensor, {
device_helpers.create_fingerprint("Shelly", "Flood"),
device_helpers.create_fingerprint("Shelly", "Flood S"),
})
register_device_definition(temp_humidity, {
device_helpers.create_fingerprint("Shelly", "BLU H&T ZB"),
})
register_device_definition(temp_humidity_illuminance, {
device_helpers.create_fingerprint("Shelly", "BLU H&T Display ZB"),
})
register_device_definition(weather_station, {
device_helpers.create_fingerprint("Shelly", "Ecowitt WS90"),
})
register_device_definition(contact_illuminance, {
device_helpers.create_fingerprint("Shelly", "BLU DoorWindow ZB"),
})
register_device_definition(motion_illuminance, {
device_helpers.create_fingerprint("Shelly", "BLU Motion ZB"),
})
return device_definitions
