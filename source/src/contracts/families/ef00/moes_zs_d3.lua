local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

-- Frozen Zigbee2MQTT v26.99.0 src/devices/moes.ts:371-493.
-- Each raw numeric DP owns a family- and gang-specific capability.
local relay_status_converter = converter.lookup_from_to({
  off = 0,
  on = 1,
  memory = 2,
})

local light_mode_converter = converter.lookup_from_to({
  none = 0,
  relay = 1,
  pos = 2,
})

local backlight_converter = converter.lookup_from_to({
  OFF = false,
  ON = true,
})

local definition = {
  profile = "lights-moes-zs-d3",
  query_on_configure = false,
  time_start = "off",
  initial_custom_state_query = false,
  refresh_state_query = false,
  placeholder_custom_states = false,

  tuya.dp_on_off(1, {
    name = "switch",
    component = "main",
    emit = emit.switch(),
  }),
  tuya.dp_numeric(2, {
    name = "moes_zs_d_three_brightness_one",
    component = "main",
    emit = emit.moesZsDThreeBrightnessOne(),
  }),
  tuya.dp_numeric(3, {
    name = "moes_zs_d_three_brightness_min_one",
    component = "main",
    emit = emit.moesZsDThreeBrightnessMinOne(),
  }),
  tuya.dp_numeric(5, {
    name = "moes_zs_d_three_brightness_max_one",
    component = "main",
    emit = emit.moesZsDThreeBrightnessMaxOne(),
  }),
  tuya.dp_numeric(6, {
    name = "moes_zs_d_three_countdown_one",
    component = "main",
    emit = emit.moesZsDThreeCountdownOne(),
  }),
  tuya.dp_on_off(7, {
    name = "switch",
    component = "switch2",
    emit = emit.switch(),
  }),
  tuya.dp_numeric(8, {
    name = "moes_zs_d_three_brightness_two",
    component = "switch2",
    emit = emit.moesZsDThreeBrightnessTwo(),
  }),
  tuya.dp_numeric(9, {
    name = "moes_zs_d_three_brightness_min_two",
    component = "switch2",
    emit = emit.moesZsDThreeBrightnessMinTwo(),
  }),
  tuya.dp_numeric(11, {
    name = "moes_zs_d_three_brightness_max_two",
    component = "switch2",
    emit = emit.moesZsDThreeBrightnessMaxTwo(),
  }),
  tuya.dp_numeric(12, {
    name = "moes_zs_d_three_countdown_two",
    component = "switch2",
    emit = emit.moesZsDThreeCountdownTwo(),
  }),
  tuya.dp_enum(14, {
    name = "moes_zs_d_three_relay_status",
    component = "main",
    emit = emit.moesZsDThreeRelayStatus(),
    converter = relay_status_converter,
  }),
  tuya.dp_on_off(15, {
    name = "switch",
    component = "switch3",
    emit = emit.switch(),
  }),
  tuya.dp_numeric(16, {
    name = "moes_zs_d_three_brightness_three",
    component = "switch3",
    emit = emit.moesZsDThreeBrightnessThree(),
  }),
  tuya.dp_numeric(17, {
    name = "moes_zs_d_three_brightness_min_three",
    component = "switch3",
    emit = emit.moesZsDThreeBrightnessMinThree(),
  }),
  tuya.dp_numeric(19, {
    name = "moes_zs_d_three_brightness_max_three",
    component = "switch3",
    emit = emit.moesZsDThreeBrightnessMaxThree(),
  }),
  tuya.dp_numeric(20, {
    name = "moes_zs_d_three_countdown_three",
    component = "switch3",
    emit = emit.moesZsDThreeCountdownThree(),
  }),
  tuya.dp_enum(21, {
    name = "moes_zs_d_three_light_mode",
    component = "main",
    emit = emit.moesZsDThreeLightMode(),
    converter = light_mode_converter,
  }),
  tuya.dp_binary(26, {
    name = "moes_zs_d_three_backlight",
    component = "main",
    emit = emit.moesZsDThreeBacklight(),
    converter = backlight_converter,
  }),
}

register_device_definition(definition, {
  { manufacturer = "_TZE284_vizxbhco", model = "TS0601" },
})

return {
  id = "moes.zs_d3",
  registrations = device_definitions,
}
