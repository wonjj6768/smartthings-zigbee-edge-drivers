local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local dimmer_light = {
  profile = "lights-dimmer",
  zcl_clusters = {
    zcl.switch(),
    zcl.level(),
  },
}

local cct_light = {
  profile = "lights-color-temperature",
  zcl_clusters = {
    zcl.switch(),
    zcl.level(),
    zcl.color_temperature(),
  },
}

local color_cct_light = {
  profile = "lights-color-temperature-color",
  zcl_clusters = {
    zcl.switch(),
    zcl.level(),
    zcl.color_temperature(),
    zcl.color_hue(),
    zcl.color_saturation(),
    zcl.color(),
  },
}

register_device_definition(dimmer_light, {
  device_helpers.create_fingerprint("IKEA", "E1603"),
  device_helpers.create_fingerprint("IKEA", "E1704"),
  device_helpers.create_fingerprint("IKEA", "E1705"),
  device_helpers.create_fingerprint("IKEA", "E2204"),
})

register_device_definition(cct_light, {
  device_helpers.create_fingerprint("IKEA", "E1702/E1703"),
  device_helpers.create_fingerprint("IKEA", "E1902"),
  device_helpers.create_fingerprint("IKEA", "E2206"),
  device_helpers.create_fingerprint("IKEA", "E2214"),
  device_helpers.create_fingerprint("IKEA", "E2220"),
})

register_device_definition(color_cct_light, {
  device_helpers.create_fingerprint("IKEA", "E2223"),
  device_helpers.create_fingerprint("IKEA", "E2224"),
})

register_device_definition(dimmer_light, {
  -- Z2M IKEA model-only dimmer lights
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 opal 1000lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 W opal 1000lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WW globe 800lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WW globe 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WW globe 810lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WW globe 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE26WWglobeclear250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WW G95 CL 470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WW G95 CL 450lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WW G95 CL 440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WW G95 CL 470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WW clear 250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WW clear 250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE27WWclear250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE26WWclear250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 opal 1000lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 W opal 1000lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WW 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WW 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 W op/ch 400lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 W op/ch 400lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E17 W op/ch 400lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE14WWclear250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE12WWclear250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE17WWclear250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE12WWcandleclear250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 WW 345lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 WW 380lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 W 400lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 WW 400lm"),
})

register_device_definition(cct_light, {
  -- Z2M IKEA model-only color-temperature lights
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WS opal 980lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WS opal 980lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WS�opal 980lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WS clear 950lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WS clear 950lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WS�clear 950lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbG125E27WSopal470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbG125E26WSopal450lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbG125E26WSopal470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbG125E26WSopal440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE27WSglobeopal1055lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE26WSglobeopal1100lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE26WSglobeopal1160lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE26WSglobeopal1055lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE26WSglobeclear800lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE27WSglobeclear806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE26WSglobeclear806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE26WSglobeclear810lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 opal 470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 W opal 470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbT120E27WSopal470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbT120E26WSopal450lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbT120E26WSopal470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WS opal 440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbT120E26WSopal440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WS opal 1000lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WS opal 1000lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WS clear 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WS clear 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WS globe 1055lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WS globe 1055lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WS globe 1100lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WS globe 1160lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbPAR38WS900lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbB22WSglobeopal1055lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 WS candle 470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 WS candle 450lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 WS opal 400lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 WS opal 400lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 WS 470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 WS 450lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E17 WS 440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E17 WS candle 440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 WS globe 470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 WS globe 450lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 WS opal 600lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE14WSglobeopal470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE12WSglobeopal470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E17 WS globe 440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE17WSglobeopal470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 WS opal 600lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E17 WS opal 600lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE14WScandleopal470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE12WScandleopal450lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE17WScandleopal440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 WS 400lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI_bulb_GU10_WS_345lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbGU10WS345lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 WS 345lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbGU10WS380lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 WS 380lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "LEPTITER Recessed spot light"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JETSTROM 40100"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JETSTROM 40100 NA"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JETSTROM 6060"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JETSTROM 6060 JP"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JETSTROM 6060 NA"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JORMLIEN door WS 40x80"),
  device_helpers.create_fingerprint("IKEA of Sweden", "FLOALT panel WS 30x30"),
  device_helpers.create_fingerprint("IKEA of Sweden", "FLOALT panel WS 60x60"),
  device_helpers.create_fingerprint("IKEA of Sweden", "FLOALT panel WS 30x90"),
  device_helpers.create_fingerprint("IKEA of Sweden", "SURTE door WS 38x64"),
  device_helpers.create_fingerprint("IKEA of Sweden", "GUNNARP panel round"),
  device_helpers.create_fingerprint("IKEA of Sweden", "GUNNARP panel 40*40"),
})

register_device_definition(color_cct_light, {
  -- Z2M IKEA model-only color-temperature-color lights
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 CWS globe 800lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 CWS globe 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 CWS globe 810lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 CWS globe 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 CWS 800lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 CWS 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 CWS 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 CWS 810lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 CWS opal 600lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 CWS opal 600lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 CWS opal 600lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 CWS opal 600lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 C/WS opal 600"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 CWS 470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 CWS 450lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E17 CWS 440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 CWS globe 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 CWS globe 800lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E17 CWS globe 810lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 CWS 380lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 CWS 345lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JETSTROM 3030 wall"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JETSTROM 3030 NA wall"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JETSTROM 3030 ceiling"),
})

return device_definitions
