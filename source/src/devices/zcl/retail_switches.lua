local zcl = require "zcl_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local zcl_device_helpers = require "devices.zcl.helpers"

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

local function switch_definition(profile, endpoints)
  local clusters = {}
  for index, endpoint in ipairs(endpoints) do
    clusters[#clusters + 1] = zcl.switch({
      endpoint = endpoint,
      component = index == 1 and "main" or ("switch" .. tostring(index)),
    })
  end
  return {
    profile = profile,
    zcl_clusters = clusters,
  }
end

local switch_1 = switch_definition("switches-switch-1", { 1 })
local switch_2 = switch_definition("switches-switch-2", { 1, 2 })
local switch_3 = switch_definition("switches-switch-3", { 1, 2, 3 })
local switch_1_ep10 = switch_definition("switches-switch-1", { 10 })
local switch_2_ep10 = switch_definition("switches-switch-2", { 10, 11 })
local switch_3_ep10 = switch_definition("switches-switch-3", { 10, 11, 12 })
local switch_4 = switch_definition("switches-switch-4", { 1, 2, 3, 4 })
local switch_5 = switch_definition("switches-switch-5", { 1, 2, 3, 4, 7 })
local switch_5_ep5 = switch_definition("switches-switch-5", { 1, 2, 3, 4, 5 })
local switch_5_ep5_tuya_options = switch_definition("switches-switch-5-tuya-options", { 1, 2, 3, 4, 5 })
zcl_device_helpers.append_clusters(switch_5_ep5_tuya_options.zcl_clusters,
  zcl.tuya_magic_packet(),
  zcl.tuya_power_outage_memory(),
  zcl.child_lock()
)
local plug_1 = switch_definition("plugs-switch", { 1 })
local plug_2 = switch_definition("plugs-switch-2", { 1, 2 })
local battery_switch = {
  profile = "switches-switch-1-battery",
  zcl_clusters = {
    zcl.switch(),
    zcl.battery(),
  },
}
local single_power_switch = {
  profile = "switches-switch-1-power-options",
  zcl_clusters = zcl_device_helpers.metering_clusters({
    include_switch = true,
    include_current = true,
  }),
}
local dual_power_switch = {
  profile = "switches-switch-2-power-options",
  zcl_clusters = zcl_device_helpers.metering_clusters({
    include_switch = true,
    include_current = true,
  }),
}
local dual_metered_switch_ep3 = switch_definition("switches-switch-2-power-options", { 1, 2 })
for _, cluster in ipairs(zcl_device_helpers.metering_clusters({
  endpoint = 3,
  include_switch = false,
  include_current = true,
})) do
  dual_metered_switch_ep3.zcl_clusters[#dual_metered_switch_ep3.zcl_clusters + 1] = cluster
end
local metered_plug = {
  profile = "plugs-switch-power-energy-voltage",
  zcl_clusters = zcl_device_helpers.metering_clusters({
    include_switch = true,
    include_current = false,
  }),
}
local metered_din_relay = {
  profile = "din-rail-switch-power-energy-voltage-current",
  zcl_clusters = zcl_device_helpers.metering_clusters({
    include_switch = true,
    include_current = true,
  }),
}
local threshold_din_clusters = zcl_device_helpers.metering_clusters({
  include_switch = true,
  include_current = true,
})
zcl_device_helpers.append_clusters(threshold_din_clusters,
  zcl.indicator_mode(),
  zcl.power_outage_memory(),
  zcl.power_threshold(),
  zcl.power_breaker(),
  zcl.over_current_threshold(),
  zcl.over_current_breaker(),
  zcl.over_voltage_threshold(),
  zcl.over_voltage_breaker(),
  zcl.under_voltage_threshold(),
  zcl.under_voltage_breaker(),
  zcl.temperature(),
  zcl.temperature_threshold(),
  zcl.temperature_breaker()
)
local threshold_din_relay = {
  profile = "din-rail-switch-power-energy-voltage-current-threshold",
  zcl_clusters = threshold_din_clusters,
}
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
  },
}

register_aliases(plug_1, {
  device_helpers.create_fingerprint("ClickSmart+", "CMA30035"),
  device_helpers.create_fingerprint("Aubess", "TS011F_plug_1"),
  device_helpers.create_fingerprint("Bacchus", "Water_Station"),
  device_helpers.create_fingerprint("Bacchus", "Water_Station.Modkam"),
  device_helpers.create_fingerprint("BSEED", "S-PC86ZEUSK1B"),
  device_helpers.create_fingerprint("BSEED", "_TZ3000_o1jzcxou"),
  device_helpers.create_fingerprint("BSEED", "Zigbee Socket"),
  device_helpers.create_fingerprint("KTNNKG", "ZB1248-10A"),
  device_helpers.create_fingerprint("LELLKI", "TS011F_plug"),
  device_helpers.create_fingerprint("UseeLink", "SM-AZ713"),
  device_helpers.create_fingerprint("Teekar", "SWP86-01OG"),
  device_helpers.create_fingerprint("Tongou", "TO-Q-SY1-ZT"),
  device_helpers.create_fingerprint("Mumubiz", "ZJSB9-80Z"),
  device_helpers.create_fingerprint("Revolt", "NX-4911"),
  device_helpers.create_fingerprint("Shelly", "1"),
  device_helpers.create_fingerprint("Zemismart", "ZW-EU-01"),
})

register_aliases(plug_1, {
  device_helpers.create_fingerprint("Third Reality", "3RSP0186Z"),
  device_helpers.create_fingerprint("Third Reality", "3RSPJ0187Z"),
  device_helpers.create_fingerprint("Third Reality", "3RSPE02065Z"),
  device_helpers.create_fingerprint("Third Reality", "3RSPU01080Z"),
})

register_aliases(plug_1, {
  device_helpers.create_fingerprint("LEDVANCE", "4058075729261"),
  device_helpers.create_fingerprint("LEDVANCE", "AB3257001NJ"),
  device_helpers.create_fingerprint("LEDVANCE", "AC03360"),
  device_helpers.create_fingerprint("LEDVANCE", "AC10691"),
})

register_aliases(plug_1, {
  device_helpers.create_fingerprint("Woolley", "SA-028-1"),
  device_helpers.create_fingerprint("Woolley", "SA-029-1"),
})

register_aliases(plug_2, {
  device_helpers.create_fingerprint("ClickSmart+", "CMA30036"),
  device_helpers.create_fingerprint("Moes", "ZK-CH-2U"),
  device_helpers.create_fingerprint("Rylike", "RY-WS02Z"),
  device_helpers.create_fingerprint("Zemismart", "ZW-EU-02"),
  device_helpers.create_fingerprint("Nova Digital", "NT-S2"),
  device_helpers.create_fingerprint("Nova Digital", "QZ-S2Q"),
  device_helpers.create_fingerprint("Nova Digital", "NTS2-W-B"),
})

register_aliases(plug_2, {
  device_helpers.create_fingerprint("Third Reality", "3RWP01073Z"),
})

register_aliases(battery_switch, {
  device_helpers.create_fingerprint("Third Reality, Inc", "3RSS009Z"),
  device_helpers.create_fingerprint("Third Reality, Inc", "3RSS008Z"),
})

register_aliases(switch_1, {
  device_helpers.create_fingerprint("Third Reality, Inc", "3RSS007Z"),
})

register_aliases(metered_plug, {
  device_helpers.create_fingerprint("Zbeacon", "TS011F_plug_1_1"),
  device_helpers.create_fingerprint("BSEED", "TS011F_plug_1_2"),
  device_helpers.create_fingerprint("BSEED", "TS011F_plug_3_1"),
  device_helpers.create_fingerprint("BSEED", "_TZ3210_5ct6e7ye"),
  device_helpers.create_fingerprint("AVATTO", "MIUCOT10Z"),
})

register_aliases(metered_plug, {
  device_helpers.create_fingerprint("Bosch", "BSP-EZ2"),
  device_helpers.create_fingerprint("Bosch", "BSP-GZ2"),
  device_helpers.create_fingerprint("SONOFF", "S60ZBTPG"),
})

register_aliases(switch_1, {
  device_helpers.create_fingerprint("SONOFF", "MINI-ZBD"),
})

register_aliases(dual_metered_switch_ep3, {
  device_helpers.create_fingerprint("Candeo", "C-ZB-SM30-2G"),
})

register_aliases(metered_plug, {
  device_helpers.create_fingerprint("AduroSmart ERIA", "ONOFF_METER_RELAY"),
  device_helpers.create_fingerprint("HEIMAN", "SmartPlug-N"),
})

register_aliases(metered_plug, {
  device_helpers.create_fingerprint("Innr", "SP 242"),
  device_helpers.create_fingerprint("Innr", "SP 244"),
})

register_aliases(metered_plug, {
  device_helpers.create_fingerprint("Schneider Electric", "CCTFR6500"),
})

register_aliases(metered_din_relay, {
  device_helpers.create_fingerprint("Tongou", "TO-Q-SY1-JZT"),
  device_helpers.create_fingerprint("TOMZN", "TOB9Z-63M"),
  device_helpers.create_fingerprint("Nous", "DZ"),
  device_helpers.create_fingerprint("MatSee Plus", "ATMS1602Z"),
  device_helpers.create_fingerprint("BTicino", "F40T125A"),
  device_helpers.create_fingerprint("BTicino", "FC80GCS"),
  device_helpers.create_fingerprint("Legrand", "412172"),
  device_helpers.create_fingerprint("Schneider Electric", "A9MEM1570"),
})

register_aliases(threshold_din_relay, {
  device_helpers.create_fingerprint("_TZ3000_303avxxt", "TS011F"),
  device_helpers.create_fingerprint("_TZ3000_cayepv1a", "TS011F"),
  device_helpers.create_fingerprint("_TZ3000_ibefeicf", "TS011F"),
  device_helpers.create_fingerprint("_TZ3000_lepzuhto", "TS011F"),
  device_helpers.create_fingerprint("_TZ3000_qystbcjg", "TS011F"),
  device_helpers.create_fingerprint("_TZ3000_yi0n4xfd", "TS011F"),
  device_helpers.create_fingerprint("_TZ3000_zjchz7pd", "TS011F"),
  device_helpers.create_fingerprint("_TZ3000_zrm3oxsh", "TS011F"),
  device_helpers.create_fingerprint("_TZ3000_zv6x8bt2", "TS011F"),
  device_helpers.create_fingerprint("Tongou", "TO-Q-SY2-163JZT"),
  device_helpers.create_fingerprint("EARU", "EAKCB-T-M-Z"),
  device_helpers.create_fingerprint("EARU", "EAYCB-Z-2P"),
  device_helpers.create_fingerprint("UNSH", "SMKG-1KNL-EU-Z"),
  device_helpers.create_fingerprint("Moes", "A5"),
  device_helpers.create_fingerprint("Tomzn", "TOB9Z-VAP"),
})

register_aliases(switch_1, {
  device_helpers.create_fingerprint("Zemismart", "ZM-H7"),
  device_helpers.create_fingerprint("GIEX", "GX02"),
  device_helpers.create_fingerprint("Lmiot", "doorlock_5001"),
  device_helpers.create_fingerprint("Loginovo", "ZG-101ZL"),
  device_helpers.create_fingerprint("Tuya", "XMSJ"),
  device_helpers.create_fingerprint("Tuya", "ZG-001"),
  device_helpers.create_fingerprint("Nova Digital", "SA-1"),
  device_helpers.create_fingerprint("Nova Digital", "TPZ-1"),
  device_helpers.create_fingerprint("Colorock", "CR-MNZ1"),
  device_helpers.create_fingerprint("Tuya", "XSH01A"),
  device_helpers.create_fingerprint("Moes", "ZM-104-M"),
  device_helpers.create_fingerprint("AVATTO", "ZWSM16-1"),
  device_helpers.create_fingerprint("AVATTO", "ZBTS60-01"),
  device_helpers.create_fingerprint("Moes", "ZM4LT1"),
  device_helpers.create_fingerprint("PSMART", "T441"),
  device_helpers.create_fingerprint("PSMART", "T461"),
  device_helpers.create_fingerprint("Mercator Ikuü", "SSWM10-ZB"),
  device_helpers.create_fingerprint("Homeetec", "Homeetec_37022454"),
  device_helpers.create_fingerprint("RoomsAI", "RoomsAI_37022454"),
  device_helpers.create_fingerprint("iHseno", "_TZ3000_qq9ahj6z"),
  device_helpers.create_fingerprint("Mercator Ikuü", "SSW01"),
  device_helpers.create_fingerprint("Rely Electronics", "_TZ3000_5rpu3r0d"),
  device_helpers.create_fingerprint("Lonsonho", "X701"),
  device_helpers.create_fingerprint("Bandi", "BDS03G1"),
  device_helpers.create_fingerprint("OXT", "SWTZ21"),
  device_helpers.create_fingerprint("TUYATEC", "GDKES-01TZXD"),
  device_helpers.create_fingerprint("Vensi", "E321V000A03"),
  device_helpers.create_fingerprint("_TYST11_qtbrwrfv", "tbrwrfv"),
})

register_aliases(switch_1, {
  device_helpers.create_fingerprint("Candeo", "C205"),
  device_helpers.create_fingerprint("IKEA", "E2006"),
})

register_aliases(switch_1, {
  device_helpers.create_fingerprint("HEIMAN", "HS2SW1A-EF-3.0"),
  device_helpers.create_fingerprint("HEIMAN", "HS2SW1A-EFR-3.0"),
})

register_aliases(switch_1, {
  device_helpers.create_fingerprint("KlikAanKlikUit", "Built-in Switch"),
  device_helpers.create_fingerprint("Oz Smart Things", "WSP403"),
  device_helpers.create_fingerprint("Sibling", "Powerswitch-ZK(W)"),
  device_helpers.create_fingerprint("Sunricher", "SR-ZG9101SAC-HP-SWITCH-B"),
  device_helpers.create_fingerprint("BTicino", "3584C"),
  device_helpers.create_fingerprint("BTicino", "3577C"),
  device_helpers.create_fingerprint("BTicino", "FC80AC"),
  device_helpers.create_fingerprint("BTicino", "FC80CC"),
  device_helpers.create_fingerprint("BTicino", "FC80RC"),
  device_helpers.create_fingerprint("BTicino", "LN4570CWI"),
  device_helpers.create_fingerprint("Elko", "EKO07250"),
  device_helpers.create_fingerprint("Elko", "EKO07251"),
  device_helpers.create_fingerprint("Elko", "EKO07252"),
  device_helpers.create_fingerprint("Elko", "EKO07253"),
  device_helpers.create_fingerprint("Elko", "EKO20004"),
  device_helpers.create_fingerprint("Elko", "EKO30198"),
  device_helpers.create_fingerprint("Elko", "EKO30199"),
  device_helpers.create_fingerprint("Gira", "2430-100"),
  device_helpers.create_fingerprint("Gira", "2435-10"),
  device_helpers.create_fingerprint("Jung", "ZLLHS4"),
  device_helpers.create_fingerprint("Legrand", "199142"),
  device_helpers.create_fingerprint("Sunricher", "SR-ZG9100A-S"),
})

register_aliases(switch_1, {
  device_helpers.create_fingerprint("Schneider Electric", "1GANG/SWITCH/1"),
  device_helpers.create_fingerprint("Schneider Electric", "CH10AX/SWITCH/1"),
  device_helpers.create_fingerprint("Schneider Electric", "CH2AX/SWITCH/1"),
  device_helpers.create_fingerprint("Schneider Electric", "NHPB/SWITCH/1"),
  device_helpers.create_fingerprint("Schneider Electric", "PUCK/SWITCH/1"),
  device_helpers.create_fingerprint("Schneider Electric", "U201SRY2KWZB"),
})

register_aliases(switch_1, {
  device_helpers.create_fingerprint("TERNCY", "TERNCY-LS01"),
})

register_aliases(switch_1_ep10, {
  device_helpers.create_fingerprint("Schneider Electric", "A3N31SR800ZB_xx_C1"),
  device_helpers.create_fingerprint("Schneider Electric", "E8331SRY800ZB"),
})

register_aliases(switch_2_ep10, {
  device_helpers.create_fingerprint("Schneider Electric", "A3N32SR800ZB_xx_C1"),
  device_helpers.create_fingerprint("Schneider Electric", "E8332SRY800ZB"),
})

register_aliases(switch_3_ep10, {
  device_helpers.create_fingerprint("Schneider Electric", "A3N33SR800ZB_xx_C1"),
  device_helpers.create_fingerprint("Schneider Electric", "E8333SRY800ZB"),
})

register_aliases(switch_1, create_model_fingerprints("Sunricher", {
  "ON/OFF",
  "ZIGBEE-SWITCH",
  "Micro Smart OnOff",
  "HK-SL-RELAY-A",
}))

register_aliases(switch_2, {
  device_helpers.create_fingerprint("Moes", "ZM-104B-M"),
  device_helpers.create_fingerprint("Iolloi", "ID-EU20FW09"),
  device_helpers.create_fingerprint("pcblab.io", "RR620ZB"),
  device_helpers.create_fingerprint("Mercator Ikuü", "SSW02"),
  device_helpers.create_fingerprint("Aubess", "TMZ02"),
  device_helpers.create_fingerprint("RSH", "TS0002_basic_2"),
  device_helpers.create_fingerprint("EKAZA", "EKAC-T3092Z"),
  device_helpers.create_fingerprint("Nova Digital", "NTZB-01"),
  device_helpers.create_fingerprint("AVATTO", "ZWSM16-2"),
  device_helpers.create_fingerprint("PSMART", "T442"),
  device_helpers.create_fingerprint("PSMART", "T462"),
  device_helpers.create_fingerprint("Nova Digital", "FZB-2"),
  device_helpers.create_fingerprint("Nova Digital", "TPZ-2"),
  device_helpers.create_fingerprint("Moes", "ZM4LT2"),
  device_helpers.create_fingerprint("Hej", "BDS03G2"),
  device_helpers.create_fingerprint("Zemismart", "TB26-2"),
  device_helpers.create_fingerprint("Lonsonho", "X702A"),
  device_helpers.create_fingerprint("iHseno", "_TZ3000_zxrfobzw"),
  device_helpers.create_fingerprint("Tuya", "ZG-2002-RF"),
  device_helpers.create_fingerprint("Moes", "ZS-EUB_2gang"),
  device_helpers.create_fingerprint("Lonsonho", "X702"),
  device_helpers.create_fingerprint("OXT", "SWTZ22"),
  device_helpers.create_fingerprint("TUYATEC", "GDKES-02TZXD"),
  device_helpers.create_fingerprint("Earda", "ESW-2ZAA-EU"),
  device_helpers.create_fingerprint("Vrey", "VR-X712U-0013"),
  device_helpers.create_fingerprint("Moes", "ZS-US2-BK-MS"),
  device_helpers.create_fingerprint("Zemismart", "ZM-CSW002-D_switch"),
  device_helpers.create_fingerprint("AVATTO", "ZTS02"),
  device_helpers.create_fingerprint("Rely Electronics", "_TZ3000_dershnvx"),
})

register_aliases(switch_2, {
  device_helpers.create_fingerprint("Candeo", "C-ZB-SM205-2G"),
})

register_aliases(switch_2, {
  device_helpers.create_fingerprint("HEIMAN", "HS2SW2A-EF-3.0"),
  device_helpers.create_fingerprint("HEIMAN", "HS2SW2A-EFR-3.0"),
})

register_aliases(switch_2, {
  device_helpers.create_fingerprint("LED-Trading", "UP-SA-9127D"),
  device_helpers.create_fingerprint("Sunricher", "ON/OFF(2CH)"),
  device_helpers.create_fingerprint("Sunricher", "SR-ZG9101SAC-HP-SWITCH-2CH"),
})

register_aliases(single_power_switch, {
  device_helpers.create_fingerprint("Moes", "ZM-104-M-16AM"),
})

register_aliases(single_power_switch, create_model_fingerprints("Sunricher", {
  "ZG9100B-5A",
  "ON/OFF -M",
}))

register_aliases(dual_power_switch, {
  device_helpers.create_fingerprint("Tuya", "XSH01B"),
})

register_aliases(dual_metered_switch_ep3, create_model_fingerprints("Sunricher", {
  "ZG9041A-2R",
  "ZG9098A-Light",
  "ZG9098A-WinLight",
}))

register_aliases(switch_3, {
  device_helpers.create_fingerprint("Nova Digital", "FZB-3"),
  device_helpers.create_fingerprint("Nova Digital", "TPZ-3"),
  device_helpers.create_fingerprint("Nova Digital", "SA-3"),
  device_helpers.create_fingerprint("Tuya", "TS0003_1"),
  device_helpers.create_fingerprint("Zemismart", "TB26-3"),
  device_helpers.create_fingerprint("Nova Digital", "NTZB-02"),
  device_helpers.create_fingerprint("AVATTO", "ZWSM16-3"),
  device_helpers.create_fingerprint("Moes", "ZM4LT3"),
  device_helpers.create_fingerprint("RSH", "SB03-Zigbee"),
  device_helpers.create_fingerprint("Moes", "MS-104CZ"),
  device_helpers.create_fingerprint("Lonsonho", "X703A"),
  device_helpers.create_fingerprint("Zemismart", "ZM-L03E-Z"),
  device_helpers.create_fingerprint("Zemismart", "KES-606US-L3"),
  device_helpers.create_fingerprint("AVATTO", "ZWOT16-W2"),
  device_helpers.create_fingerprint("AVATTO", "ZBTS60-03"),
  device_helpers.create_fingerprint("Tuya", "M10Z"),
  device_helpers.create_fingerprint("Zemismart", "ZMO-606-S2"),
  device_helpers.create_fingerprint("iHseno", "_TZ3000_mhhxxjrs"),
  device_helpers.create_fingerprint("OXT", "SWTZ23"),
  device_helpers.create_fingerprint("TUYATEC", "GDKES-03TZXD"),
  device_helpers.create_fingerprint("Nova Digital", "WS-US-ZB"),
  device_helpers.create_fingerprint("PLAID SYSTEMS", "PS-SPRZMS-SLP3"),
  device_helpers.create_fingerprint("Zemismart", "SPM02-3Z3"),
})

register_aliases(switch_3, {
  device_helpers.create_fingerprint("HEIMAN", "HS2SW3A-EF-3.0"),
  device_helpers.create_fingerprint("HEIMAN", "HS2SW3A-EFR-3.0"),
})

register_aliases(switch_4, {
  device_helpers.create_fingerprint("Nova Digital", "TPZ-4"),
  device_helpers.create_fingerprint("Tuya", "DS-111"),
  device_helpers.create_fingerprint("MHCOZY", "TYWB 4ch-RF"),
  device_helpers.create_fingerprint("AVATTO", "TS0004_1"),
  device_helpers.create_fingerprint("AVATTO", "ZBTS60-04"),
  device_helpers.create_fingerprint("RSH", "SB04-Zigbee"),
  device_helpers.create_fingerprint("AVATTO", "ZWSM16-4"),
  device_helpers.create_fingerprint("Moes", "ZM4LT4"),
  device_helpers.create_fingerprint("iHseno", "_TZ3000_knoj8lpk"),
  device_helpers.create_fingerprint("AVATTO", "ZWOT12"),
  device_helpers.create_fingerprint("Coibeu", "ZB414"),
  device_helpers.create_fingerprint("Nova Digital", "SA-4"),
  device_helpers.create_fingerprint("Mercator Ikuü", "SSW04"),
  device_helpers.create_fingerprint("OXT", "SWTZ27"),
  device_helpers.create_fingerprint("TUYATEC", "GDKES-04TZXD"),
  device_helpers.create_fingerprint("MakeGood", "MG-ZG04W/B/G"),
  device_helpers.create_fingerprint("TERNCY", "TERNCY-WS01-S4"),
  device_helpers.create_fingerprint("_TZ3210_qjvi92wz", "TS0014"),
  device_helpers.create_fingerprint("_TZ3210_w3hl6rao", "TS0014"),
  device_helpers.create_fingerprint("_TZ3210_z4hgsevd", "TS0014"),
  device_helpers.create_fingerprint("Vizo", "VZ-221S"),
  device_helpers.create_fingerprint("Vizo", "VZ-222S"),
  device_helpers.create_fingerprint("Vizo", "VZ-223S"),
  device_helpers.create_fingerprint("LELLKI", "WP33-EU"),
  device_helpers.create_fingerprint("zunzunbee", "SSWZ8T"),
})

register_aliases(switch_5_ep5_tuya_options, {
  device_helpers.create_fingerprint("UseeLink", "SM-0306E-2W"),
  device_helpers.create_fingerprint("UseeLink", "SM-O301-AZ"),
  device_helpers.create_fingerprint("Lotus", "Ref 2117"),
})

register_aliases(switch_5, {
  device_helpers.create_fingerprint("UseeLink", "SM-SO306E/K/M"),
})

register_aliases(switch_5_ep5, {
  device_helpers.create_fingerprint("Milfra", "M11Z"),
})

register_aliases(switch_5_ep5, {
  device_helpers.create_fingerprint("Sunricher", "SR-ZG9023A-EU"),
})

register_aliases(smart_valve, {
  device_helpers.create_fingerprint("Tuya", "SM-AW713Z"),
})

return device_definitions
