local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function register_aliases(definition, aliases)
register_device_definition(definition, aliases)
end
local function create_model_fingerprints(manufacturer, models)
local fingerprints = {}
for _, model in ipairs(models) do
fingerprints[#fingerprints + 1] = device_helpers.create_fingerprint(manufacturer, model)
end
return fingerprints
end
local dimmer_light = {
profile = "lights-dimmer",
zcl_clusters = {
zcl.switch(),
zcl.level(),
},
}
local metered_dimmer_light = {
profile = "lights-dimmer-power-voltage-current",
zcl_clusters = {
zcl.switch(),
zcl.level(),
zcl.power(),
zcl.voltage(),
zcl.current(),
},
}
local dual_dimmer = {
profile = "lights-dimmer-2-options",
zcl_clusters = {},
}
for _, cluster in ipairs(zcl.multi_switch(2, { component_prefix = "switch" })) do
dual_dimmer.zcl_clusters[#dual_dimmer.zcl_clusters + 1] = cluster
end
for _, cluster in ipairs(zcl.multi_level(2, { component_prefix = "switch" })) do
dual_dimmer.zcl_clusters[#dual_dimmer.zcl_clusters + 1] = cluster
end
dual_dimmer.zcl_clusters[#dual_dimmer.zcl_clusters + 1] = zcl.power_on_behavior()
dual_dimmer.zcl_clusters[#dual_dimmer.zcl_clusters + 1] = zcl.switch_type()
dual_dimmer.zcl_clusters[#dual_dimmer.zcl_clusters + 1] = zcl.countdown_timer()
dual_dimmer.zcl_clusters[#dual_dimmer.zcl_clusters + 1] = zcl.min_brightness()
dual_dimmer.zcl_clusters[#dual_dimmer.zcl_clusters + 1] = zcl.max_brightness()
dual_dimmer.zcl_clusters[#dual_dimmer.zcl_clusters + 1] = zcl.light_type()
local cct_light = {
profile = "lights-color-temperature",
zcl_clusters = {
zcl.switch(),
zcl.level(),
zcl.color_temperature(),
},
}
local color_light = {
profile = "lights-color",
zcl_clusters = {
zcl.switch(),
zcl.level(),
zcl.color_hue(),
zcl.color_saturation(),
zcl.color(),
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
register_aliases(dimmer_light, {
device_helpers.create_fingerprint("Tuya", "FS-05R"),
device_helpers.create_fingerprint("Ledron", "YK-16"),
device_helpers.create_fingerprint("Ledron", "QS-Zigbee-D06-DC"),
})
register_aliases(dimmer_light, {
device_helpers.create_fingerprint("Candeo", "C203"),
device_helpers.create_fingerprint("Candeo", "C204"),
device_helpers.create_fingerprint("Candeo", "C210"),
device_helpers.create_fingerprint("Candeo", "HK-LN-DIM-A"),
})
register_aliases(dimmer_light, {
device_helpers.create_fingerprint("Philips", "929003822801"),
device_helpers.create_fingerprint("Philips", "929003845801"),
device_helpers.create_fingerprint("Philips", "929003845901"),
})
register_aliases(dimmer_light, {
device_helpers.create_fingerprint("MLI", "ZBT-DimmableLight"),
})
register_aliases(dimmer_light, {
device_helpers.create_fingerprint("EGLO", "12229"),
})
register_aliases(dimmer_light, {
device_helpers.create_fingerprint("Gledopto", "GL-C-009P_mini"),
})
register_aliases(dimmer_light, {
device_helpers.create_fingerprint("Paulmann Licht GmbH", "Dimmable"),
device_helpers.create_fingerprint("Paulmann lamp", "Dimmable Light"),
})
register_aliases(dimmer_light, {
device_helpers.create_fingerprint("Sunricher", "HK-SL-DIM-A"),
})
register_aliases(dimmer_light, {
device_helpers.create_fingerprint("Namron", "4512751"),
device_helpers.create_fingerprint("Samotech", "SM311"),
device_helpers.create_fingerprint("Schneider Electric", "550B1012"),
device_helpers.create_fingerprint("Sunricher", "SR-ZG9040A-S"),
device_helpers.create_fingerprint("YPHIX", "50208695"),
device_helpers.create_fingerprint("Yphix", "50208702"),
})
register_aliases(dimmer_light, {
device_helpers.create_fingerprint("CTM Lyng", "CTM_DimmerPille"),
device_helpers.create_fingerprint("Iluminize", "511.344"),
device_helpers.create_fingerprint("L&S Lighting", "756200028"),
device_helpers.create_fingerprint("L&S Lighting", "756200031"),
device_helpers.create_fingerprint("LED-Trading", "9125"),
device_helpers.create_fingerprint("LongLife LED", "3986"),
device_helpers.create_fingerprint("Paulmann", "984.43"),
device_helpers.create_fingerprint("Philips", "929003711301"),
device_helpers.create_fingerprint("Philips", "929003711401"),
device_helpers.create_fingerprint("Sunricher", "SR-ZG2835"),
device_helpers.create_fingerprint("Sunricher", "SR-ZG9040A"),
})
register_aliases(dual_dimmer, {
device_helpers.create_fingerprint("OXT", "SWTZ25"),
device_helpers.create_fingerprint("Candeo", "C-ZB-RD1P-DPM"),
device_helpers.create_fingerprint("Sunricher", "DIM"),
})
register_aliases(cct_light, {
device_helpers.create_fingerprint("Tuya", "L1(ZW)"),
})
register_aliases(cct_light, {
device_helpers.create_fingerprint("TERNCY", "DL001"),
device_helpers.create_fingerprint("TERNCY", "CL001"),
})
register_aliases(cct_light, {
device_helpers.create_fingerprint("Philips", "5633030P9"),
device_helpers.create_fingerprint("Philips", "929003099302"),
device_helpers.create_fingerprint("Philips", "929003777201"),
})
register_aliases(cct_light, {
device_helpers.create_fingerprint("Philips", "929003823001"),
device_helpers.create_fingerprint("Philips", "929003823101"),
device_helpers.create_fingerprint("Philips", "929003823201"),
device_helpers.create_fingerprint("Philips", "929003823301"),
device_helpers.create_fingerprint("Philips", "929003823401"),
device_helpers.create_fingerprint("Philips", "929003846001"),
device_helpers.create_fingerprint("Philips", "929003846101"),
device_helpers.create_fingerprint("Philips", "929003846401"),
device_helpers.create_fingerprint("Philips", "929003846501"),
})
register_aliases(cct_light, {
device_helpers.create_fingerprint("MLI", "Bulb white"),
})
register_aliases(cct_light, {
device_helpers.create_fingerprint("EGLO", "12239"),
device_helpers.create_fingerprint("EGLO", "900053"),
device_helpers.create_fingerprint("EGLO", "900316"),
device_helpers.create_fingerprint("EGLO", "900317"),
})
register_aliases(cct_light, {
device_helpers.create_fingerprint("Gledopto", "GL-C-003P_1"),
device_helpers.create_fingerprint("Gledopto", "GL-C-006P_mini"),
device_helpers.create_fingerprint("Gledopto", "GL-C-203P"),
})
register_aliases(cct_light, {
device_helpers.create_fingerprint("DOMRAEM", "WW/CW"),
device_helpers.create_fingerprint("LDS", "ZBT-CCTLight-GU100904"),
device_helpers.create_fingerprint("Ltech", "TY-75-24-G2Z2_CCT"),
device_helpers.create_fingerprint("_TZ3210_6pwpez2j", "TS0502C"),
})
register_aliases(cct_light, {
device_helpers.create_fingerprint("Paulmann Licht GmbH", "CCT"),
})
register_aliases(color_cct_light, {
device_helpers.create_fingerprint("Moes", "ZLD-RCW_1"),
device_helpers.create_fingerprint("Lidl", "HG08673-BS"),
device_helpers.create_fingerprint("TechToy", "_TZ3210_iw0zkcu8"),
device_helpers.create_fingerprint("Skydance", "WZ5_dim_2"),
device_helpers.create_fingerprint("QA", "QADZC5"),
device_helpers.create_fingerprint("LEDEPLY", "SG45-E26"),
})
register_aliases(color_cct_light, {
device_helpers.create_fingerprint("Third Reality", "3RCB02070Z"),
})
register_aliases(cct_light, {
device_helpers.create_fingerprint("Third Reality, Inc", "3RSL011Z"),
device_helpers.create_fingerprint("Third Reality, Inc", "3RSL012Z"),
})
register_aliases(color_cct_light, {
device_helpers.create_fingerprint("Philips", "8720169264212"),
device_helpers.create_fingerprint("Philips", "8720169264274"),
device_helpers.create_fingerprint("Philips", "9290012574"),
device_helpers.create_fingerprint("Philips", "929003115901"),
device_helpers.create_fingerprint("Philips", "929003116201"),
device_helpers.create_fingerprint("Philips", "929003853701"),
})
register_aliases(color_cct_light, {
device_helpers.create_fingerprint("Philips", "929003823601"),
device_helpers.create_fingerprint("Philips", "929003823701"),
device_helpers.create_fingerprint("Philips", "929003823801"),
device_helpers.create_fingerprint("Philips", "929003823901"),
device_helpers.create_fingerprint("Philips", "929003824001"),
device_helpers.create_fingerprint("Philips", "929003846201"),
device_helpers.create_fingerprint("Philips", "929003846301"),
device_helpers.create_fingerprint("Philips", "929003846601"),
device_helpers.create_fingerprint("Philips", "929003846701"),
})
register_aliases(color_cct_light, {
device_helpers.create_fingerprint("Philips", "929004608003"),
device_helpers.create_fingerprint("Philips", "929004608004"),
device_helpers.create_fingerprint("Philips", "929004608101"),
device_helpers.create_fingerprint("Philips", "929004608103"),
device_helpers.create_fingerprint("Philips", "929004608201"),
})
register_aliases(color_cct_light, {
device_helpers.create_fingerprint("MLI", "Bulb white+color"),
device_helpers.create_fingerprint("MLI", "Candle white+color"),
device_helpers.create_fingerprint("MLI", "Ceiling light"),
device_helpers.create_fingerprint("MLI", "Desk lamp"),
device_helpers.create_fingerprint("MLI", "GU10 white+color"),
})
register_aliases(color_cct_light, {
device_helpers.create_fingerprint("Müller Licht", "404115"),
device_helpers.create_fingerprint("Müller Licht", "404116"),
device_helpers.create_fingerprint("Müller Licht", "404117"),
device_helpers.create_fingerprint("Müller Licht", "404135"),
device_helpers.create_fingerprint("Müller Licht", "404136"),
device_helpers.create_fingerprint("Müller Licht", "404137"),
})
register_aliases(color_cct_light, {
device_helpers.create_fingerprint("MLI", "Garden light"),
device_helpers.create_fingerprint("MLI", "LED Strip"),
})
register_aliases(cct_light, {
device_helpers.create_fingerprint("HEIMAN", "TemperLight"),
})
register_aliases(color_cct_light, {
device_helpers.create_fingerprint("HEIMAN", "ColorLight"),
})
register_aliases(metered_dimmer_light, create_model_fingerprints("Sunricher", {
"HK-SL-DIM-UK",
"ZG2837RAC-K4",
"HK-SL-DIM-AU-K-A",
"HK-SL-DIM-US-A",
"Micro Smart Dimmer",
"SM311",
"HK-SL-RDIM-A",
"HK-SL-DIM-EU-A",
"HK-SL-DIM-AU-R-A",
}))
register_aliases(dimmer_light, create_model_fingerprints("Sunricher", {
"HK-SL-DIM-CLN",
"ZG9101SAC-HP",
"HK-ZD-DIM-A",
"HK-DIM",
}))
register_aliases(cct_light, create_model_fingerprints("Sunricher", {
"HK-ZD-CCT-A",
"CCT Lighting",
"3986",
}))
register_aliases(dimmer_light, create_model_fingerprints("LEDVANCE", {
"LEDVANCE DIM",
"A60 DIM T",
"B40 DIM T",
"PAR16 DIM T",
"P40 DIM T",
"DR_ZBD_NFC_P_45W_220-240V_1A2",
"A60 FIL DIM T",
"EDISON60 FIL DIM T",
"GLOBE60 FIL DIM T",
"Connected Tube Value II",
}))
register_aliases(cct_light, create_model_fingerprints("LEDVANCE", {
"A60S TW",
"Panel TW Z3",
"PL HCL300x1200 01",
"PL_HCL600_01",
"PL_HCL625_01",
"PAR16S TW",
"B40 TW Z3",
"P40S TW",
"B40S TW",
"P40 TW Value",
"Undercabinet TW Z3",
"Tibea TW Z3",
"CLA60 TW Value",
"A60 TW T",
"P40 TW T",
"PAR16 TW T",
"B40 TW T",
}))
register_aliases(color_cct_light, create_model_fingerprints("LEDVANCE", {
"Panel Light 2x2 TW",
"Panel TW 620 UGR19",
"A60 RGBW Value II",
"PAR16 RGBW Value",
"PAR16S RGBW",
"PAR16 RGBW T",
"FLEX RGBW Z3",
"Outdoor FLEX RGBW Z3",
"Gardenpole Mini RGBW Z3",
"CLA60 RGBW JP",
"A60S RGBW",
"A60 RGBW T",
"GARDENPOLE RGBW T",
"A60 RGBW B22D T",
"FLEX RGBW T",
"OUTDOOR FLEX RGBW T",
}))
register_aliases(color_light, create_model_fingerprints("OSRAM", {
"Gardenspot RGB",
}))
register_aliases(dimmer_light, create_model_fingerprints("OSRAM", {
"PAR16 DIM Z3",
"A60 DIM Z3",
"Classic A60 W clear - LIGHTIFY",
"LIGHTIFY PAR38 ON/OFF/DIM",
"Gardenspot W",
"B40 DIM Z3",
"SubstiTube",
"Connected Tube Z3",
}))
register_aliases(cct_light, create_model_fingerprints("OSRAM", {
"A60 TW Z3",
"CLA60 TW OSRAM",
"LIGHTIFY A19 Tunable White",
"Classic A60 TW",
"PAR16 50 TW",
"PAR16 TW Z3",
"Classic B40 TW - LIGHTIFY",
"Ceiling TW OSRAM",
"Surface Light TW",
"ZLO-CeilingTW-OS",
"Control box TW",
"MR16 TW OSRAM",
"Panel TW 595 UGR22",
"Zigbee 3.0 DALI CONV LI",
"LIGHTIFY Under Cabinet TW",
}))
register_aliases(color_cct_light, create_model_fingerprints("OSRAM", {
"Outdoor Lantern W RGBW OSRAM",
"Outdoor Lantern B50 RGBW OSRAM",
"LIGHTIFY RT RGBW",
"Classic A60 RGBW",
"CLA60 RGBW OSRAM",
"CLA60 RGBW Z3",
"CLA60 RGBW II Z3",
"Flex RGBW",
"LIGHTIFY Indoor Flex RGBW",
"LIGHTIFY Flex RGBW",
"LIGHTIFY Outdoor Flex RGBW",
"LIGHTIFY FLEX OUTDOOR RGBW",
"Flex Outdoor RGBW",
"Gardenpole RGBW-Lightify",
"Gardenpole RGBW Z3",
"Gardenpole Mini RGBW OSRAM",
"PAR 16 50 RGBW - LIGHTIFY",
"PAR16 RGBW Z3",
}))
register_aliases(color_cct_light, {
device_helpers.create_fingerprint("DOMRAEM", "RGBWC"),
device_helpers.create_fingerprint("EGLO", "900116"),
device_helpers.create_fingerprint("Letsleds China", "RGBW Down Light"),
device_helpers.create_fingerprint("Light", "01F"),
device_helpers.create_fingerprint("Ltech", "SE-20-250-1000-W2Z2"),
device_helpers.create_fingerprint("Seastar Intelligence", "07073L"),
device_helpers.create_fingerprint("eWeLight", "ZB-CL02"),
device_helpers.create_fingerprint("eWeLink", "Z102LG03-1"),
})
register_aliases(color_cct_light, {
device_helpers.create_fingerprint("EGLO", "900566"),
})
register_aliases(color_cct_light, {
device_helpers.create_fingerprint("Gledopto", "GL-C-001P"),
device_helpers.create_fingerprint("Gledopto", "GL-C-002P"),
device_helpers.create_fingerprint("Gledopto", "GL-C-007P_mini"),
device_helpers.create_fingerprint("Gledopto", "GL-C-008P_mini"),
device_helpers.create_fingerprint("Gledopto", "GL-C-011P"),
device_helpers.create_fingerprint("Gledopto", "GL-C-201P"),
device_helpers.create_fingerprint("Gledopto", "GL-C-202P"),
device_helpers.create_fingerprint("Gledopto", "GL-C-204P"),
device_helpers.create_fingerprint("Gledopto", "GL-C-301P"),
})
register_aliases(color_cct_light, {
device_helpers.create_fingerprint("Paulmann Licht", "RGBW Controller"),
})
register_aliases(color_cct_light, {
device_helpers.create_fingerprint("Iluminize", "RGBW-CCT"),
device_helpers.create_fingerprint("Iluminize", "RGBWW Lighting"),
device_helpers.create_fingerprint("Sunricher", "HK-ZD-RGBCCT-A"),
})
register_aliases(cct_light, {
device_helpers.create_fingerprint("GLEDOPTO", "GL-B-002P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-B-004P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-C-004P"),
})
register_aliases(cct_light, {
device_helpers.create_fingerprint("Innr", "AE 270 T"),
device_helpers.create_fingerprint("Innr", "AE 270 T-2"),
device_helpers.create_fingerprint("Innr", "RB 178 T"),
device_helpers.create_fingerprint("Innr", "RB 272 T"),
device_helpers.create_fingerprint("Innr", "RB 278 T"),
device_helpers.create_fingerprint("Innr", "RB 279 T"),
device_helpers.create_fingerprint("Innr", "RCL 231 T"),
device_helpers.create_fingerprint("Innr", "RF 271 T"),
device_helpers.create_fingerprint("Innr", "RF 273 T"),
device_helpers.create_fingerprint("Innr", "RF 274 T"),
})
register_aliases(color_cct_light, {
device_helpers.create_fingerprint("GLEDOPTO", "GL-B-001P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-B-001Z"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-B-001ZS"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-B-003P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-B-007P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-B-007Z"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-B-007ZS"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-B-008P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-B-008Z"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-B-008ZS"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-001P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-002P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-003P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-003Z"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-003ZS"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-004P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-004Z"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-004ZS"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-005P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-005Z"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-005ZS"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-006P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-007P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-008P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-009P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-010P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-013P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-D-015P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-FL-001P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-FL-004P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-FL-004TZ"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-FL-004TZP"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-FL-004TZS"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-FL-005P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-FL-005TZ"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-FL-005TZP"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-FL-005TZS"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-FL-006P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-FL-006TZ"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-FL-006TZP"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-FL-006TZS"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-FL-007P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-G-003P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-G-004P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-G-005P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-S-004P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-S-004Z"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-S-004ZS"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-S-005P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-S-005Z"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-S-007P"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-S-007Z"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-S-007Z(lk)"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-S-007ZS"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-S-008Z"),
device_helpers.create_fingerprint("GLEDOPTO", "GL-S-014P"),
})
register_aliases(color_cct_light, {
device_helpers.create_fingerprint("Innr", "AE 280 C"),
device_helpers.create_fingerprint("Innr", "AE 282 C"),
device_helpers.create_fingerprint("Innr", "AE 287 C"),
device_helpers.create_fingerprint("Innr", "BB 282 C"),
device_helpers.create_fingerprint("Innr", "BB 287 C"),
device_helpers.create_fingerprint("Innr", "BB 287 C-2"),
device_helpers.create_fingerprint("Innr", "BY 178 T"),
device_helpers.create_fingerprint("Innr", "BY 185 C"),
device_helpers.create_fingerprint("Innr", "BY 285 C"),
device_helpers.create_fingerprint("Innr", "BY 286 C"),
device_helpers.create_fingerprint("Innr", "FL 122 C"),
device_helpers.create_fingerprint("Innr", "FL 230 C"),
device_helpers.create_fingerprint("Innr", "FL 250 C"),
device_helpers.create_fingerprint("Innr", "OFL 120 C"),
device_helpers.create_fingerprint("Innr", "OFL 122 C"),
device_helpers.create_fingerprint("Innr", "OFL 140 C"),
device_helpers.create_fingerprint("Innr", "OFL 142 C"),
device_helpers.create_fingerprint("Innr", "OGL 130 C"),
device_helpers.create_fingerprint("Innr", "OPL 130 C"),
device_helpers.create_fingerprint("Innr", "RB 185 C"),
device_helpers.create_fingerprint("Innr", "RB 246 T"),
device_helpers.create_fingerprint("Innr", "RB 250 C"),
device_helpers.create_fingerprint("Innr", "RB 251 C"),
device_helpers.create_fingerprint("Innr", "RB 252 C"),
device_helpers.create_fingerprint("Innr", "RB 255 C"),
device_helpers.create_fingerprint("Innr", "RB 256 C"),
device_helpers.create_fingerprint("Innr", "RB 282 C"),
device_helpers.create_fingerprint("Innr", "RB 285 C"),
device_helpers.create_fingerprint("Innr", "RB 286 C"),
device_helpers.create_fingerprint("Innr", "RB 287 C"),
device_helpers.create_fingerprint("Innr", "RCL 232 C"),
})
register_aliases(color_light, {
device_helpers.create_fingerprint("GLEDOPTO", "GL-S-003Z"),
})
register_aliases(dimmer_light, {
device_helpers.create_fingerprint("Innr", "AE 260"),
device_helpers.create_fingerprint("Innr", "AE 262"),
device_helpers.create_fingerprint("Innr", "AE 264"),
device_helpers.create_fingerprint("Innr", "BB 262"),
device_helpers.create_fingerprint("Innr", "BE 220"),
device_helpers.create_fingerprint("Innr", "BF 263"),
device_helpers.create_fingerprint("Innr", "BF 265"),
device_helpers.create_fingerprint("Innr", "BY 165"),
device_helpers.create_fingerprint("Innr", "BY 265"),
device_helpers.create_fingerprint("Innr", "BY 266"),
device_helpers.create_fingerprint("Innr", "OLS 210"),
device_helpers.create_fingerprint("Innr", "PL 110"),
device_helpers.create_fingerprint("Innr", "PL 115"),
device_helpers.create_fingerprint("Innr", "RB 162"),
device_helpers.create_fingerprint("Innr", "RB 165"),
device_helpers.create_fingerprint("Innr", "RB 172 W"),
device_helpers.create_fingerprint("Innr", "RB 175 W"),
device_helpers.create_fingerprint("Innr", "RB 262"),
device_helpers.create_fingerprint("Innr", "RB 265"),
device_helpers.create_fingerprint("Innr", "RB 266"),
device_helpers.create_fingerprint("Innr", "RB 267"),
device_helpers.create_fingerprint("Innr", "RCL 110"),
device_helpers.create_fingerprint("Innr", "RF 261"),
device_helpers.create_fingerprint("Innr", "RF 262"),
device_helpers.create_fingerprint("Innr", "RF 263"),
device_helpers.create_fingerprint("Innr", "RF 264"),
device_helpers.create_fingerprint("Innr", "RF 265"),
device_helpers.create_fingerprint("Innr", "RSL 110"),
device_helpers.create_fingerprint("Innr", "RSL 115"),
device_helpers.create_fingerprint("Innr", "ST 110"),
device_helpers.create_fingerprint("Innr", "UC 110"),
})
return device_definitions
