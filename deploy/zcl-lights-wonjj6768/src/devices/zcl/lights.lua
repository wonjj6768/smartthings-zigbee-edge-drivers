local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local capabilities = require "st.capabilities"
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
local function build_cct_light(mired_minimum, mired_maximum, options)
options = options or {}
local light = {
profile = "lights-color-temperature",
zcl_clusters = {
zcl.switch(),
zcl.level(),
zcl.color_temperature(),
},
}
if options.tuya_magic == true then
table.insert(light.zcl_clusters, 1, zcl.tuya_magic_packet())
end
light.color_temperature_range = {
minimum = math.floor((1000000 / mired_maximum) + 0.5),
maximum = math.floor((1000000 / mired_minimum) + 0.5),
}
light.runtime_start = function(device)
device:emit_component_event(
{ id = "main" },
capabilities.colorTemperature.colorTemperatureRange({
value = light.color_temperature_range,
unit = "K",
})
)
return true
end
return light
end
local function build_color_cct_light(mired_minimum, mired_maximum, options)
local light = build_cct_light(mired_minimum, mired_maximum, options)
light.profile = "lights-color-temperature-color"
light.zcl_clusters[#light.zcl_clusters + 1] = zcl.color_hue()
light.zcl_clusters[#light.zcl_clusters + 1] = zcl.color_saturation()
light.zcl_clusters[#light.zcl_clusters + 1] = zcl.color()
return light
end
local domraem_cct_light = build_cct_light(158, 495)
local paulmann_cct_i_light = build_cct_light(153, 370)
local qa_cct_light = build_cct_light(153, 500, { tuya_magic = true })
local tuya_ts0505b_1_light = build_color_cct_light(153, 500)
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
register_device_definition(dimmer_light, device_helpers.create_fingerprints("TS0501A", {
"_TZ3000_j2w1dw29",
"_TZ3000_nosnx7im",
"_TZ3000_7dcddnye",
"_TZ3000_nbnmw9nc",
}))
register_device_definition(dimmer_light, device_helpers.create_fingerprints("TS0501B", {
"_TZ3210_dxroobu3",
"_TZ3210_dbilpfqk",
"_TZ3000_juq7i1fr",
"_TZ3210_yluvwhjc",
"_TZ3000_4whigl8i",
"_TZ3210_9q49basr",
"_TZ3210_4zinq6io",
"_TZ3210_e5t9bfdv",
"_TZ3210_i680rtja",
"_TZ3210_agjx0pxt",
"_TZ3210_d062rv7j",
"_TZ3210_syh4kuef",
}))
register_device_definition(dimmer_light, device_helpers.create_fingerprints("TS0501B", {
"_TZB210_g01ie5wu",
}))
register_device_definition(dimmer_light, device_helpers.create_fingerprints("TS0052", {
"_TZ3000_mgusv51k",
}))
register_device_definition(cct_light, device_helpers.create_fingerprints("TS0501B", {
"_TZB210_rkgngb5o",
}))
register_device_definition(cct_light, device_helpers.create_fingerprints("TS0502A", {
"_TZ3000_oborybow",
"_TZ3000_el5kt5im",
"_TZ3000_49qchf10",
"_TZ3000_rylaozuc",
"_TZ3000_5fkufhn1",
"_TZ3000_8uaoilu9",
"_TZ3000_9evm3otq",
"_TZ3000_oh7jddmx",
}))
register_device_definition(cct_light, device_helpers.create_fingerprints("TS0502B", {
"_TZ3000_zw7wr5uo",
"_TZ3000_g1glzzfk",
"_TZ3000_bumeauzp",
"_TZ3210_frm6149r",
"_TZ3210_jtifm80b",
"_TZ3210_xwqng7ol",
"_TZB210_ue01a0s2",
"_TZB210_ayx58ft5",
"_TZB210_eiwanbeb",
"_TZB210_0bkzabht",
"_TZ3210_c2iwpxf1",
"_TZ3210_09hzmirw",
"_TZ3000_6dwfra5l",
"_TZ3210_claeh5ds",
}))
register_device_definition(cct_light, {
device_helpers.create_fingerprint("Aqara", "lumi.dimmer.acn004"),
device_helpers.create_fingerprint("Aqara", "lumi.light.acn003"),
device_helpers.create_fingerprint("Aqara", "lumi.light.acn006"),
device_helpers.create_fingerprint("Aqara", "lumi.light.acn026"),
device_helpers.create_fingerprint("Aqara", "lumi.light.acn040"),
device_helpers.create_fingerprint("Aqara", "lumi.light.acn128"),
device_helpers.create_fingerprint("LUMI", "lumi.dimmer.acn003"),
device_helpers.create_fingerprint("LUMI", "lumi.dimmer.acn004"),
device_helpers.create_fingerprint("LUMI", "lumi.dimmer.acn005"),
device_helpers.create_fingerprint("LUMI", "lumi.light.acn004"),
device_helpers.create_fingerprint("LUMI", "lumi.light.acn006"),
device_helpers.create_fingerprint("LUMI", "lumi.light.acn003"),
device_helpers.create_fingerprint("LUMI", "lumi.light.acn014"),
device_helpers.create_fingerprint("LUMI", "lumi.light.acn023"),
device_helpers.create_fingerprint("LUMI", "lumi.light.acn024"),
device_helpers.create_fingerprint("LUMI", "lumi.light.acn025"),
device_helpers.create_fingerprint("LUMI", "lumi.light.acn026"),
device_helpers.create_fingerprint("LUMI", "lumi.light.acn040"),
device_helpers.create_fingerprint("LUMI", "lumi.light.acn128"),
device_helpers.create_fingerprint("LUMI", "lumi.light.aqcn02"),
device_helpers.create_fingerprint("LUMI", "lumi.light.cwac02"),
device_helpers.create_fingerprint("LUMI", "lumi.light.cwacn1"),
device_helpers.create_fingerprint("LUMI", "lumi.light.cwjwcn01"),
device_helpers.create_fingerprint("LUMI", "lumi.light.cwjwcn02"),
device_helpers.create_fingerprint("LUMI", "lumi.light.cwopcn01"),
device_helpers.create_fingerprint("LUMI", "lumi.light.cwopcn02"),
device_helpers.create_fingerprint("LUMI", "lumi.light.cwopcn03"),
})
register_device_definition(domraem_cct_light, {
device_helpers.create_fingerprint("DOMRAEM", "CCT"),
})
register_device_definition(paulmann_cct_i_light, {
device_helpers.create_fingerprint("Paulmann Licht GmbH", "CCT-I"),
})
register_device_definition(qa_cct_light, device_helpers.create_fingerprints("TS0502B", {
"_TZ3218_op6ztaju",
}))
register_device_definition(dimmer_light, {
{ manufacturer = "Megaman" .. string.char(0), model = "ZLL-DimmableLight" },
})
register_device_definition(dimmer_light, {
device_helpers.create_fingerprint("LUMI", "lumi.light.cbacn1"),
})
register_device_definition(cct_light, {
device_helpers.create_fingerprint("_TZB210_lmqquxus", "TS0503B"),
})
register_device_definition(color_light, device_helpers.create_fingerprints("TS0503A", {
"_TZ3000_obacbukl",
}))
register_device_definition(color_light, device_helpers.create_fingerprints("TS0503B", {
"_TZB210_zdvrsts8",
}))
register_device_definition(color_cct_light, device_helpers.create_fingerprints("TS0505A", {
"_TZ3000_sosdczdl",
"_TZ3000_odygigth",
"_TZ3000_kdpxju99",
"_TZ3000_dbou1ap4",
"_TZ3000_9cpuaca6",
"_TZ3000_gek6snaj",
"_TZ3000_evag0pvn",
"_TZ3000_riwp3k79",
"_TZ3000_keabpigv",
}))
register_device_definition(color_cct_light, {
device_helpers.create_fingerprint("Aqara", "lumi.light.acn132"),
device_helpers.create_fingerprint("LUMI", "lumi.light.acn132"),
device_helpers.create_fingerprint("LUMI", "lumi.light.rgbac1"),
})
register_device_definition(color_cct_light, device_helpers.create_fingerprints("TS0505B", {
"_TZ3210_iystcadi",
"_TZ3210_it1u8ahz",
"_TZB210_3zfp8mki",
"_TZB210_gj0ccsar",
"_TZ3210_jaap6jeb",
"_TZ3210_bfwvfyx1",
}))
register_device_definition(tuya_ts0505b_1_light, device_helpers.create_fingerprints("TS0505B", {
"_TZ3210_htdm5hvw",
"_TZ3210_r3wubmyh",
}))
register_device_definition(color_cct_light, device_helpers.create_fingerprints("TS0505B", {
"_TZ3000_7hcgjxpc",
"_TZ3000_bwlvyjwk",
"_TZ3000_gb5gaeca",
"_TZ3000_iivsrikg",
"_TZ3000_j0gtlepx",
"_TZ3000_q50zhdsc",
"_TZ3000_qd7hej8u",
"_TZ3000_quqaeew6",
"_TZ3000_taspddvq",
"_TZ3000_th6zqqy6",
"_TZ3000_v1srfw9x",
"_TZ3000_wr6g6olr",
"_TZ3210_b3kiq1i0",
"_TZ3210_b8jdosxo",
"_TZ3210_c0s1xloa",
"_TZ3210_cieijuw1",
"_TZ3210_dkul5xix",
"_TZ3210_dn5higyl",
"_TZ3210_dwzfzfjc",
"_TZ3210_hicxa0rh",
"_TZ3210_hxtfthp5",
"_TZ3210_ifga63rg",
"_TZ3210_iw0zkcu8",
"_TZ3210_jd3z4yig",
"_TZ3210_jicmoite",
"_TZ3210_jjqdqxfq",
"_TZ3210_ljoasixl",
"_TZ3210_mja6r5ix",
"_TZ3210_p9ao60da",
"_TZ3210_qigbovcq",
"_TZ3210_r0xgkft5",
"_TZ3210_r5afgmkl",
"_TZ3210_rcggc0ys",
"_TZ3210_s9lumfhn",
"_TZ3210_sln7ah6r",
"_TZ3210_sw9uxoea",
"_TZ3210_umi6vbsz",
"_TZ3210_wbsgmojq",
"_TZ3210_wxa85bwk",
"_TZ3210_x13bu7za",
"_TZ3210_z1vlyufu",
"_TZ3210_zbabx9wh",
"_TZ3210_zrvxvydd",
"_TZB210_417ikxay",
"_TZB210_6eed09b9",
"_TZB210_endmggws",
"_TZB210_lnnkh3f9",
"_TZB210_rs0ufzwg",
"_TZB210_rwy5hexp",
"_TZB210_u3ri0968",
"_TZB210_uoiqhjqe",
"_TZB210_w9hcix2r",
"_TZB210_wxazcmsh",
"_TZB210_wy1pyu1q",
"_TZB210_yatkpuha",
"_TZB210_zmppwawa",
"_TZ3000_lxw3zcdk",
"_TZ3000_xr5m6kfg",
"_TZ3210_hzy4rjz3",
"_TZ3210_klsm24op",
"_TZ3210_mcm6m1ma",
"_TZ3210_mntza0sw",
"_TZ3210_pdqu9pot",
"_TZ3210_pwauw3g2",
"_TZ3210_r0vzq1oj",
}))
register_device_definition(dimmer_light, {
device_helpers.create_fingerprint("Candeo", "Candeo Zigbee Dimmer"),
device_helpers.create_fingerprint("Candeo", "HK-DIM-A"),
device_helpers.create_fingerprint("Candeo", "Dimmer-Switch-ZB3.0"),
device_helpers.create_fingerprint("HZC", "Dimmer-Switch-ZB3.0"),
device_helpers.create_fingerprint("Heatit Controls AB", "Dimmer-Switch-ZB3.0"),
device_helpers.create_fingerprint("Hilux", "Dimmer-Switch-ZB3.0"),
device_helpers.create_fingerprint("Light Solutions", "Dimmer-Switch-ZB3.0"),
device_helpers.create_fingerprint("Samotech", "Dimmer-Switch-ZB3.0"),
device_helpers.create_fingerprint("Shyugj", "Dimmer-Switch-ZB3.0"),
device_helpers.create_fingerprint("Smart Dim", "Dimmer-Switch-ZB3.0"),
device_helpers.create_fingerprint("idinio", "Dimmer-Switch-ZB3.0"),
})
register_device_definition(dimmer_light, {
device_helpers.create_fingerprint("Samotech", "HK_DIM_A"),
device_helpers.create_fingerprint("Shyugj", "HK_DIM_A"),
})
register_device_definition(dimmer_light, {
device_helpers.create_fingerprint("DOMRAEM", "DIMMER"),
device_helpers.create_fingerprint("NorLum Dim OP", "DIMMER"),
})
register_device_definition(dimmer_light, {
device_helpers.create_fingerprint("Iluminize", "DIM Lighting"),
device_helpers.create_fingerprint("Namron As", "DIM Lighting"),
device_helpers.create_fingerprint("Sunricher", "DIM Lighting"),
})
register_device_definition(dimmer_light, {
device_helpers.create_fingerprint("Nordtronic", "98426061"),
device_helpers.create_fingerprint("Nordtronic A/S", "98426061"),
})
register_device_definition(dimmer_light, {
device_helpers.create_fingerprint("Nordtronic", "WSZ 98426061"),
device_helpers.create_fingerprint("Nordtronic A/S", "WSZ 98426061"),
})
register_device_definition(dimmer_light, {
device_helpers.create_fingerprint("Candeo", "C-ZB-DM204"),
device_helpers.create_fingerprint("Candeo", "C-ZB-LC20-Dim"),
device_helpers.create_fingerprint("Candeo", "C-ZB-LC20v2-Dim"),
device_helpers.create_fingerprint("Candeo", "C-ZB-RD1"),
device_helpers.create_fingerprint("Candeo", "C-ZB-RD1P-DIM"),
})
register_device_definition(cct_light, {
device_helpers.create_fingerprint("Astuta/ZB-CCT", "CCT Light"),
device_helpers.create_fingerprint("Paulmann lamp", "CCT Light"),
device_helpers.create_fingerprint("ZB/Ajax Online", "CCT Light"),
device_helpers.create_fingerprint("ZigBee/CCT", "CCT Light"),
})
register_device_definition(cct_light, {
device_helpers.create_fingerprint("Candeo", "C-ZB-LC20-CCT"),
device_helpers.create_fingerprint("Candeo", "C-ZB-LC20v2-CCT"),
})
register_device_definition(color_light, {
device_helpers.create_fingerprint("DOMRAEM", "RGB"),
device_helpers.create_fingerprint("Paulmann Licht GmbH", "RGB"),
})
register_device_definition(color_light, {
device_helpers.create_fingerprint("DOMRAEM", "RGBW"),
device_helpers.create_fingerprint("Paulmann Licht", "RGBW"),
device_helpers.create_fingerprint("Paulmann Licht GmbH", "RGBW"),
})
register_device_definition(color_cct_light, device_helpers.create_fingerprints("TS0504B", {
"_TZ3210_sroezl0s",
"_TZ3210_ttkgurpb",
}))
register_device_definition(color_light, {
device_helpers.create_fingerprint("Candeo", "C-ZB-LC20-RGB"),
device_helpers.create_fingerprint("Candeo", "C-ZB-LC20v2-RGB"),
})
register_device_definition(color_cct_light, {
device_helpers.create_fingerprint("_TZ3210_f0byevky", "TS0503B"),
device_helpers.create_fingerprint("KURVIA", "ZB-CL01"),
device_helpers.create_fingerprint("YSRSAI", "ZB-CL01"),
device_helpers.create_fingerprint("YSRSAI", "ZB-CL03"),
device_helpers.create_fingerprint([[eWeLi\u0001\u0010]], "ZB-CL01"),
device_helpers.create_fingerprint("eWeLight", "ZB-CL01"),
device_helpers.create_fingerprint("eWeLink", "ZB-CL01"),
})
register_device_definition(color_cct_light, {
device_helpers.create_fingerprint("Candeo", "C-ZB-LC20-RGBCCT"),
device_helpers.create_fingerprint("Candeo", "C-ZB-LC20v2-RGBCCT"),
device_helpers.create_fingerprint("Candeo", "C-ZB-LC20-RGBW"),
device_helpers.create_fingerprint("Candeo", "C-ZB-LC20v2-RGBW"),
})
return device_definitions
