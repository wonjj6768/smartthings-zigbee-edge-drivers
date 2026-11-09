local j,B,r=require "protocol.zcl",require "capabilities.events.all",require "contracts.helpers.family"


local e,o,c,E,v,aa,au=r.create_fingerprint,require "contracts.helpers.zcl",require "st.zigbee.data_types",require "st.capabilities",require "st.zigbee.device_management",require "st.zigbee.cluster_base",require "st.zigbee.generic_body"







local t, d = r.definition_registry()

local function w(ab, aw)
  local A = {}
  for _, aA in ipairs(aw) do
    A[#A + 1] = r.create_fingerprint(ab, aA)
  end
  return A
end

local function b(S, T)
  local k = {}
  for ao, endpoint in ipairs(T) do
    k[#k + 1] = j.switch{
      endpoint = endpoint,
      component = ao == 1 and "main" or ("switch" .. tostring(ao))
    }
  end
  return {
    profile = S,
    zcl_clusters = k,
    configure = function(F, g)
      for _, endpoint in ipairs(T) do
        g:send(v.build_bind_request(
          g,
          j.CLUSTER_ON_OFF,
          F.environment_info.hub_zigbee_eui,
          endpoint
        ))
      end
    end
  }
end

local s,ad,D,x=b("switches-switch-1", { 1 }),b("switches-switch-2", { 1, 2 }),{minimum_interval=0,maximum_interval=3600},{minimum_interval=300,maximum_interval=3600,reportable_change=1}



local function u(S, ai)
  local k = {}
  for endpoint = 1, ai do
    k[#k+1] = j.switch{endpoint=endpoint,component=endpoint==1 and "main" or "switch"..endpoint,
      configure_reporting=false,read_on_configure=false,suppress_optimistic_state=true,data_type=c.Boolean,
      reporting_defaults=ai==1 and D or nil}
  end
  k[#k+1] = j.cluster_attribute(2,0,{name="device_temperature",endpoint=1,component="main",
    data_type=c.Int16,read_only=true,read_on_configure=false,emit=B.temperature"C",
    reporting_defaults=x})
  return {profile=S,zcl_clusters=k,
    configure=function(F,g)
      local aC=F.environment_info.hub_zigbee_eui
      for endpoint=1,ai do j.bind_cluster(g,6,aC,endpoint) end
      j.bind_cluster(g,2,aC,1)
      for _,p in ipairs(k) do
        local C=p.reporting_defaults
        if C then j.configure_reporting(g,{
          cluster=p.cluster_id,attribute=p.attribute_id,data_type=p.data_type,
          minimum_interval=C.minimum_interval,maximum_interval=C.maximum_interval,
          reportable_change=C.reportable_change},p.endpoint,{defer_on_override=true}) end
      end
    end
  }
end
local O,P,Q,V,W,X,am,ae,y=u("switches-heiman-one",1),u("switches-heiman-two",2),u("switches-switch-3-device-temperature",3),b("switches-switch-1", { 10 }),b("switches-switch-2", { 10, 11 }),b("switches-switch-3", { 10, 11, 12 }),b("switches-switch-4", { 1, 2, 3, 4 }),b("switches-switch-5", { 1, 2, 3, 4, 5 }),b("switches-switch-5-tuya-options", { 1, 2, 3, 4, 5 })









o.append_clusters(y.zcl_clusters,
  j.tuya_magic_packet(),
  j.tuya_power_outage_memory(),
  j.child_lock()
)
local ax = b("plugs-switch", { 1 })
local ay = b("plugs-switch-2", { 1, 2 })
local R = {
  profile = "switches-switch-1-battery",
  zcl_clusters = {
    j.switch(),
    j.battery()
  }
}
local f = b("switches-switch-2-power-options", { 1, 2 })
for _, af in ipairs(o.metering_clusters{
  endpoint = 3,
  include_switch = false,
  include_current = true
}) do
  af.use_reported_unity_scaler = true
  f.zcl_clusters[#f.zcl_clusters + 1] = af
end

local function n(endpoint, ak)
  return j.cluster_attribute(j.CLUSTER_ON_OFF, 16387, {
    name = "candeo_sm30_power_on_behavior",
    endpoint = endpoint,
    component = ak,
    emit = B.candeoSm30PowerBehavior(),
    from_device = function(a)
      a = type(a) == "table" and a.value or a
      return ({ [0] = "off", [1] = "on", [255] = "previous" })[a]
    end,
    to_device = function(a)
      return ({ off = 0, on = 1, previous = 255 })[a]
    end,
    data_type = c.Enum8,
    write_type = c.Enum8,
    read_on_configure = true
  })
end

f.profile = "switches-candeo-sm30-2g"
o.append_clusters(f.zcl_clusters,
  n(1, "main"),
  n(2, "switch2")
)
f.configure = function(F, g)
  for _, endpoint in ipairs{ 1, 2 } do
    g:send(v.build_bind_request(
      g,
      j.CLUSTER_ON_OFF,
      F.environment_info.hub_zigbee_eui,
      endpoint
    ))
    g:send(aa.configure_reporting(
      g,
      c.ClusterId(j.CLUSTER_ON_OFF),
      c.AttributeId(16387),
      c.ZigbeeDataType(c.Enum8.ID),
      0,
      65535,
      1
    ):to_endpoint(endpoint))
  end
end
--[[
The retail metered-plug definition now belongs to the ZCL plugs catalog.
This seven-line spacer preserves the source locations of the remaining
SONOFF functions, keeping their bytecode identities stable after the move.
No plug registration or executable definition remains in this module.
The package ownership boundary is enforced by the focused catalog test.
]]
local h,N,I=64529,4742,"concertmirror08464.sonoffZbminir2"



local function H(a)
  return (a == true or a == 1) and "on" or "off"
end

local function K(a)
  return a == "on" or a == true
end

local function q(Z, aE, ar, z)
  z = z or {}
  return j.cluster_attribute(h, Z, {
    name = aE,
    emit = ar,
    data_type = z.data_type or c.Boolean,
    write_type = z.write_type or c.Boolean,
    from_device = z.from_device or H,
    to_device = z.to_device or K,
    read_on_configure = true
  })
end

local function l(g, suffix, aq)
  local U,aj=I .. suffix,suffix:sub(1, 1):lower() .. suffix:sub(2)

  return g:get_latest_state("main", U, aj) or aq
end

local function m(g, p, a, ap)
  local ag,an,av=l(g, "InchingControl", "off"),tonumber(l(g, "InchingTime", 0.5)) or 0.5,l(g, "InchingMode", "off")



  if p.name == "sonoff_zbmini_r2_inching_control" then
    ag = a
  elseif p.name == "sonoff_zbmini_r2_inching_time" then
    an = tonumber(a) or an
  elseif p.name == "sonoff_zbmini_r2_inching_mode" then
    av = a
  end

  local G,al=math.floor((math.max(0.5, math.min(3599.5, an)) * 2) + 0.5),(ag == "on" and 128 or 0) + (av == "on" and 1 or 0)

  local Y,J={ 1, 23, 7, 128, al, 0, G % 256, math.floor(G / 256), 0, 0 },0

  for _, aD in ipairs(Y) do J = J ~ aD end
  Y[#Y + 1] = J

  return j.send_raw_cluster_command(
    g,
    h,
    1,
    string.char(table.unpack(Y)),
    ap.endpoint,
    nil,
    N
  )
end

local L = {
  profile = "switches-switch-1-sonoff-zbmini-r2",
  zcl_clusters = {
    j.switch(),
    j.cluster_attribute(j.CLUSTER_ON_OFF, 16387, {
      name = "sonoff_zbmini_r2_power_on_behavior",
      emit = B.sonoffZbminir2PowerOnBehavior(),
      data_type = c.Enum8,
      write_type = c.Enum8,
      from_device = function(a)
        return ({ [0] = "off", [1] = "on", [2] = "toggle", [255] = "previous" })[a]
      end,
      to_device = function(a)
        return ({ off = 0, on = 1, toggle = 2, previous = 255 })[a]
      end,
      read_on_configure = true
    }),
    j.cluster_attribute(j.CLUSTER_ON_OFF, j.ATTR_ON_OFF, {
      name = "sonoff_zbmini_r2_toggle",
      emit = B.switch(),
      read_only = true,
      command_id = 2,
      command_extractor = function(_, g)
        return g:get_latest_state("main", E.switch.ID, "switch") ~= "on"
      end
    }),
    q(1, "sonoff_zbmini_r2_network_indicator", B.sonoffZbminir2NetworkIndicator()),
    q(18, "sonoff_zbmini_r2_turbo_mode", B.sonoffZbminir2TurboMode(), {
      data_type = c.Int16,
      write_type = c.Int16,
      from_device = function(a) return a == 20 and "on" or "off" end,
      to_device = function(a) return a == "on" and 20 or 9 end
    }),
    q(20, "sonoff_zbmini_r2_delayed_power_on_state", B.sonoffZbminir2DelayPowerState()),
    j.cluster_attribute(h, 21, {
      name = "sonoff_zbmini_r2_delayed_power_on_time",
      emit = B.sonoffZbminir2DelayPowerTime(),
      data_type = c.Uint16,
      write_type = c.Uint16,
      from_device = function(a) return a / 2 end,
      to_device = function(a) return a * 2 end,
      numeric_range = { minimum = 0.5, maximum = 3599.5, step = 0.5, unit = "s" },
      read_on_configure = true
    }),
    q(23, "sonoff_zbmini_r2_detach_relay_mode", B.sonoffZbminir2DetachRelayMode()),
    j.cluster_attribute(h, 22, {
      name = "sonoff_zbmini_r2_external_trigger_mode",
      emit = B.sonoffZbminir2ExtTriggerMode(),
      data_type = c.Uint8,
      write_type = c.Uint8,
      from_device = function(a) return ({ [0] = "edge", [1] = "pulse", [2] = "following_off", [130] = "following_on" })[a] end,
      to_device = function(a) return ({ edge = 0, pulse = 1, following_off = 2, following_on = 130 })[a] end,
      read_on_configure = true
    }),
    j.cluster_attribute(h, nil, { name = "sonoff_zbmini_r2_inching_control", write_only = true, sender = m }),
    j.cluster_attribute(h, nil, { name = "sonoff_zbmini_r2_inching_time", write_only = true, sender = m }),
    j.cluster_attribute(h, nil, { name = "sonoff_zbmini_r2_inching_mode", write_only = true, sender = m })
  }
}

local M = {
  profile = "buttons-zunzunbee-sswz8t",
  button_actions = { "pushed", "held" },
  zcl_clusters = {
    j.cluster_attribute(j.CLUSTER_IAS_ZONE, j.ATTR_ZONE_STATUS, {
      name = "zunzunbee_button_action",
      endpoint = 1,
      read_only = true,
      read_on_refresh = false,
      data_type = c.Bitmap16,
      command_id = 0,
      command_extractor = function(aB)
        local as = aB.body.zcl_body
        local ac = as.zone_status or as.zonestatus
        return type(ac) == "table" and ac.value or ac
      end,
      from_device = function(a)
        a = type(a) == "table" and a.value or a
        local button = ({ [2] = 1, [4] = 2, [8] = 3, [16] = 4,
          [32] = 5, [64] = 6, [128] = 7, [256] = 8 })[bit32.band(a, 510)]
        if button == nil then return nil end
        return { component = "button" .. button, action = a % 2 == 1 and "held" or "pushed" }
      end,
      handler = function(g, ah)
        g:emit_component_event(
          { id = ah.component },
          E.button.button(ah.action, { state_change = true })
        )
        j.schedule_battery_refresh_after_button(g)
      end
    }),
    j.battery{ endpoint = 1, minimum_interval = 3600, maximum_interval = 65000, reportable_change = 10 },
    j.temperature{ endpoint = 1, minimum_interval = 10, maximum_interval = 3600, reportable_change = 100 }
  }
}

d(ax, {
  e("Third Reality", "3RSP0186Z"),
  e("Third Reality", "3RSPJ0187Z"),
  e("Third Reality", "3RSPE02065Z"),
  e("Third Reality", "3RSPU01080Z")
})

d(ay, {
  e("Third Reality", "3RWP01073Z")
})

d(R, {
  e("Third Reality, Inc", "3RSS009Z"),
  e("Third Reality, Inc", "3RSS008Z")
})

d(s, {
  e("Third Reality, Inc", "3RSS007Z")
})

d(L, {
  e("SONOFF", "MINI-ZBD"),
  e("SONOFF", "ZBMINIR2")
})

d(f, {
  e("Candeo", "C-ZB-SM30-2G")
})

d(s, {
  e("Candeo", "C205"),
  e("IKEA", "E2006")
})

d(O, {
  e("HEIMAN", "HS2SW1A-EF-3.0"),
  e("HEIMAN", "HS2SW1A-EFR-3.0"),
  e("HEIMAN", "HS2SW1L-EFR-3.0"),
  e("HEIMAN", "HS6SW1A-W-EF-3.0")
})

d(s, {
  e("KlikAanKlikUit", "Built-in Switch"),
  e("Oz Smart Things", "WSP403"),
  e("Sibling", "Powerswitch-ZK(W)"),
  e("Sunricher", "SR-ZG9101SAC-HP-SWITCH-B"),
  e("BTicino", "3584C"),
  e("BTicino", "3577C"),
  e("BTicino", "FC80AC"),
  e("BTicino", "FC80CC"),
  e("BTicino", "FC80RC"),
  e("BTicino", "LN4570CWI"),
  e("Elko", "EKO07250"),
  e("Elko", "EKO07251"),
  e("Elko", "EKO07252"),
  e("Elko", "EKO07253"),
  e("Elko", "EKO20004"),
  e("Elko", "EKO30198"),
  e("Elko", "EKO30199"),
  e("Gira", "2430-100"),
  e("Gira", "2435-10"),
  e("Jung", "ZLLHS4"),
  e("Legrand", "199142"),
  e("Sunricher", "SR-ZG9100A-S")
})

d(s, {
  e("Schneider Electric", "1GANG/SWITCH/1"),
  e("Schneider Electric", "CH10AX/SWITCH/1"),
  e("Schneider Electric", "CH2AX/SWITCH/1"),
  e("Schneider Electric", "NHPB/SWITCH/1"),
  e("Schneider Electric", "PUCK/SWITCH/1"),
  e("Schneider Electric", "U201SRY2KWZB")
})

d(s, {
  e("TERNCY", "TERNCY-LS01")
})

d(V, {
  e("Schneider Electric", "A3N31SR800ZB_xx_C1"),
  e("Schneider Electric", "E8331SRY800ZB")
})

d(W, {
  e("Schneider Electric", "A3N32SR800ZB_xx_C1"),
  e("Schneider Electric", "E8332SRY800ZB")
})

d(X, {
  e("Schneider Electric", "A3N33SR800ZB_xx_C1"),
  e("Schneider Electric", "E8333SRY800ZB")
})

d(s, w("Sunricher", {
  "ON/OFF",
  "ZIGBEE-SWITCH",
  "Micro Smart OnOff",
  "HK-SL-RELAY-A"
}))

d(ad, {
  e("Candeo", "C-ZB-SM205-2G")
})

d(P, {
  e("HEIMAN", "HS2SW2A-EF-3.0"),
  e("HEIMAN", "HS2SW2A-EFR-3.0"),
  e("HEIMAN", "HS2SW2L-EFR-3.0"),
  e("HEIMAN", "HS6SW2A-W-EF-3.0")
})

d(ad, {
  e("LED-Trading", "UP-SA-9127D"),
  e("Sunricher", "ON/OFF(2CH)"),
  e("Sunricher", "SR-ZG9101SAC-HP-SWITCH-2CH")
})

d(Q, {
  e("HEIMAN", "HS2SW3A-EF-3.0"),
  e("HEIMAN", "HS2SW3A-EFR-3.0"),
  e("HEIMAN", "HS2SW3L-EFR-3.0"),
  e("HEIMAN", "HS6SW3A-W-EF-3.0")
})

d(am, {
  e("Nova Digital", "TPZ-4"),
  e("Tuya", "DS-111"),
  e("MHCOZY", "TYWB 4ch-RF"),
  e("AVATTO", "TS0004_1"),
  e("AVATTO", "ZBTS60-04"),
  e("RSH", "SB04-Zigbee"),
  e("AVATTO", "ZWSM16-4"),
  e("Moes", "ZM4LT4"),
  e("iHseno", "_TZ3000_knoj8lpk"),
  e("AVATTO", "ZWOT12"),
  e("Coibeu", "ZB414"),
  e("Nova Digital", "SA-4"),
  e("Mercator Ikuü", "SSW04"),
  e("OXT", "SWTZ27"),
  e("TUYATEC", "GDKES-04TZXD"),
  e("MakeGood", "MG-ZG04W/B/G"),
  e("TERNCY", "TERNCY-WS01-S4"),
  e("_TZ3210_qjvi92wz", "TS0014"),
  e("_TZ3210_w3hl6rao", "TS0014"),
  e("_TZ3210_z4hgsevd", "TS0014"),
  e("Vizo", "VZ-221S"),
  e("Vizo", "VZ-222S"),
  e("Vizo", "VZ-223S"),
  e("LELLKI", "WP33-EU")
})

d(ae, {
  e("Sunricher", "SR-ZG9023A-EU")
})

d(M, {
  e("zunzunbee", "SSWZ8T")
})

-- ZCL REPORTING CAPABILITIES BEGIN
j.attach_reporting_capabilities(t, {
  {1, "rpt-zvs"},
  {2, "rpt-zef", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {3, "rpt-zej"},
  {4, "rpt-sit"},
  {5, "rpt-mcf"},
  {6, "rpt-cba", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {7, "rpt-sit"},
  {8, "rpt-hzd"},
  {9, "rpt-sit"},
  {10, "rpt-sit"},
  {11, "rpt-sit"},
  {12, "rpt-sit"},
  {13, "rpt-lpm", {zr0006000010 = "Switch", zr0006000011 = "SwitchTwo"}},
  {14, "rpt-lek", {zr0006000010 = "Switch", zr0006000011 = "SwitchTwo", zr0006000012 = "SwitchThree"}},
  {15, "rpt-sit"},
  {16, "rpt-lpm", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {17, "rpt-hjl"},
  {18, "rpt-lpm", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {19, "rpt-hns"},
  {20, "rpt-tmr", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree", zr000600004 = "SwitchFour"}},
  {21, "rpt-swt", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree", zr000600004 = "SwitchFour", zr000600005 = "SwitchFive"}},
  {22, "rpt-sfh"}
})
-- ZCL REPORTING CAPABILITIES END

return {
  id = "zcl.switches.retail_switches",
  registrations = t
}
