local h,D,s=require "protocol.zcl",require "capabilities.events.all",require "contracts.helpers.family"


local f,p,c,J,w,af,aA=s.create_fingerprint,require "contracts.helpers.zcl",require "st.zigbee.data_types",require "st.capabilities",require "st.zigbee.device_management",require "st.zigbee.cluster_base",require "st.zigbee.generic_body"







local u, e = s.definition_registry()

local function x(ag, aC)
  local B = {}
  for _, aH in ipairs(aC) do
    B[#B + 1] = s.create_fingerprint(ag, aH)
  end
  return B
end

local function d(X, Y)
  local k = {}
  for at, endpoint in ipairs(Y) do
    k[#k + 1] = h.switch{
      endpoint = endpoint,
      component = at == 1 and "main" or ("switch" .. tostring(at))
    }
  end
  return {
    profile = X,
    zcl_clusters = k,
    configure = function(K, a)
      for _, endpoint in ipairs(Y) do
        a:send(w.build_bind_request(
          a,
          h.CLUSTER_ON_OFF,
          K.environment_info.hub_zigbee_eui,
          endpoint
        ))
      end
    end
  }
end

local t,ai,G,y=d("switches-switch-1", { 1 }),d("switches-switch-2", { 1, 2 }),{minimum_interval=0,maximum_interval=3600},{minimum_interval=300,maximum_interval=3600,reportable_change=1}



local function v(X, ao)
  local k = {}
  for endpoint = 1, ao do
    k[#k+1] = h.switch{endpoint=endpoint,component=endpoint==1 and "main" or "switch"..endpoint,
      configure_reporting=false,read_on_configure=false,suppress_optimistic_state=true,data_type=c.Boolean,
      reporting_defaults=ao==1 and G or nil}
  end
  k[#k+1] = h.cluster_attribute(2,0,{name="device_temperature",endpoint=1,component="main",
    data_type=c.Int16,read_only=true,read_on_configure=false,emit=D.temperature"C",
    reporting_defaults=y})
  return {profile=X,zcl_clusters=k,
    configure=function(K,a)
      local aJ=K.environment_info.hub_zigbee_eui
      for endpoint=1,ao do h.bind_cluster(a,6,aJ,endpoint) end
      h.bind_cluster(a,2,aJ,1)
      for _,l in ipairs(k) do
        local F=l.reporting_defaults
        if F then h.configure_reporting(a,{
          cluster=l.cluster_id,attribute=l.attribute_id,data_type=l.data_type,
          minimum_interval=F.minimum_interval,maximum_interval=F.maximum_interval,
          reportable_change=F.reportable_change},l.endpoint,{defer_on_override=true}) end
      end
    end
  }
end
local T,U,V,aa,ab,ac,ar,aj,z=v("switches-heiman-one",1),v("switches-heiman-two",2),v("switches-switch-3-device-temperature",3),d("switches-switch-1", { 10 }),d("switches-switch-2", { 10, 11 }),d("switches-switch-3", { 10, 11, 12 }),d("switches-switch-4", { 1, 2, 3, 4 }),d("switches-switch-5", { 1, 2, 3, 4, 5 }),d("switches-switch-5-tuya-options", { 1, 2, 3, 4, 5 })









p.append_clusters(z.zcl_clusters,
  h.tuya_magic_packet(),
  h.tuya_power_outage_memory(),
  h.child_lock()
)
local aD = d("plugs-switch", { 1 })
local aE = d("plugs-switch-2", { 1, 2 })
local W = {
  profile = "switches-switch-1-battery",
  zcl_clusters = {
    h.switch(),
    h.battery()
  }
}
local g = d("switches-switch-2-power-options", { 1, 2 })
for _, al in ipairs(p.metering_clusters{
  endpoint = 3,
  include_switch = false,
  include_current = true
}) do
  al.use_reported_unity_scaler = true
  g.zcl_clusters[#g.zcl_clusters + 1] = al
end

local function o(endpoint, ap)
  return h.cluster_attribute(h.CLUSTER_ON_OFF, 16387, {
    name = "candeo_sm30_power_on_behavior",
    endpoint = endpoint,
    component = ap,
    emit = D.candeoSm30PowerBehavior(),
    from_device = function(b)
      b = type(b) == "table" and b.value or b
      return ({ [0] = "off", [1] = "on", [255] = "previous" })[b]
    end,
    to_device = function(b)
      return ({ off = 0, on = 1, previous = 255 })[b]
    end,
    data_type = c.Enum8,
    write_type = c.Enum8,
    read_on_configure = true
  })
end

g.profile = "switches-candeo-sm30-2g"
p.append_clusters(g.zcl_clusters,
  o(1, "main"),
  o(2, "switch2")
)
g.configure = function(K, a)
  for _, endpoint in ipairs{ 1, 2 } do
    a:send(w.build_bind_request(
      a,
      h.CLUSTER_ON_OFF,
      K.environment_info.hub_zigbee_eui,
      endpoint
    ))
    a:send(af.configure_reporting(
      a,
      c.ClusterId(h.CLUSTER_ON_OFF),
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
local i,S,N=64529,4742,"concertmirror08464.sonoffZbminir2"



local function r(a)
  h.read_attribute(a, 6, 16387, 1)
end

local function E(a, aF)
  a.thread:call_with_delay(2, function()
    h.read_configured_attributes(a, aF.zcl_clusters)
    h.read_attribute(a, 0, 1, 1)
    h.read_attribute(a, 0, 16384, 1)
  end, "SONOFF stored settings")
end

local function C(a, ax)
  local ak = ax.address_header
  if ak.profile.value == 0 and ak.cluster.value == 19 then
    a.thread:call_with_delay(1, function()
      r(a)
      h.read_attribute(a, 0, 1, 1)
      h.read_attribute(a, 0, 16384, 1)
    end, "SONOFF rejoin settings")
  end
end

local function H(a, l, b)
  local aK = l.to_device(b)
  if aK == nil then return false end
  local I = h.get_generated_attribute(6, 16387)
  a:send(I:write(a, c.Enum8(aK)):to_endpoint(1))
  a.thread:call_with_delay(1, function() r(a) end, "SONOFF startup readback")
  return true
end

local function M(b)
  return (b == true or b == 1) and "on" or "off"
end

local function P(b)
  return b == "on" or b == true
end

local function q(ae, aM, aw, A)
  A = A or {}
  return h.cluster_attribute(i, ae, {
    name = aM,
    emit = aw,
    data_type = A.data_type or c.Boolean,
    write_type = A.write_type or c.Boolean,
    from_device = A.from_device or M,
    to_device = A.to_device or P,
    read_on_configure = true
  })
end

local function m(a, suffix, av)
  local Z,I=N .. suffix,suffix:sub(1, 1):lower() .. suffix:sub(2)

  return a:get_latest_state("main", Z, I) or av
end

local function n(a, l, b, au)
  local am,as,aB=m(a, "InchingControl", "off"),tonumber(m(a, "InchingTime", 0.5)) or 0.5,m(a, "InchingMode", "off")



  if l.name == "sonoff_zbmini_r2_inching_control" then
    am = b
  elseif l.name == "sonoff_zbmini_r2_inching_time" then
    as = tonumber(b) or as
  elseif l.name == "sonoff_zbmini_r2_inching_mode" then
    aB = b
  end

  local L,aq=math.floor((math.max(0.5, math.min(3599.5, as)) * 2) + 0.5),(am == "on" and 128 or 0) + (aB == "on" and 1 or 0)

  local ad,O={ 1, 23, 7, 128, aq, 0, L % 256, math.floor(L / 256), 0, 0 },0

  for _, aL in ipairs(ad) do O = O ~ aL end
  ad[#ad + 1] = O

  return h.send_raw_cluster_command(
    a,
    i,
    1,
    string.char(table.unpack(ad)),
    au.endpoint,
    nil,
    S
  )
end

local Q = {
  profile = "switches-switch-1-sonoff-zbmini-r2",
  runtime_start = E,
  zigbee_message_handler = C,
  zcl_clusters = {
    h.switch(),
    h.cluster_attribute(h.CLUSTER_ON_OFF, 16387, {
      name = "sonoff_zbmini_r2_power_on_behavior",
      endpoint = 1,
      suppress_optimistic_state = true,
      sender = H,
      emit = D.sonoffZbminir2PowerOnBehavior(),
      data_type = c.Enum8,
      write_type = c.Enum8,
      from_device = function(b)
        return ({ [0] = "off", [1] = "on", [2] = "toggle", [255] = "previous" })[b]
      end,
      to_device = function(b)
        return ({ off = 0, on = 1, toggle = 2, previous = 255 })[b]
      end,
      read_on_configure = true
    }),
    h.cluster_attribute(h.CLUSTER_ON_OFF, h.ATTR_ON_OFF, {
      name = "sonoff_zbmini_r2_toggle",
      emit = D.switch(),
      read_only = true,
      command_id = 2,
      command_extractor = function(_, a)
        return a:get_latest_state("main", J.switch.ID, "switch") ~= "on"
      end
    }),
    q(1, "sonoff_zbmini_r2_network_indicator", D.sonoffZbminir2NetworkIndicator()),
    q(18, "sonoff_zbmini_r2_turbo_mode", D.sonoffZbminir2TurboMode(), {
      data_type = c.Int16,
      write_type = c.Int16,
      from_device = function(b) return b == 20 and "on" or "off" end,
      to_device = function(b) return b == "on" and 20 or 9 end
    }),
    q(20, "sonoff_zbmini_r2_delayed_power_on_state", D.sonoffZbminir2DelayPowerState()),
    h.cluster_attribute(i, 21, {
      name = "sonoff_zbmini_r2_delayed_power_on_time",
      emit = D.sonoffZbminir2DelayPowerTime(),
      data_type = c.Uint16,
      write_type = c.Uint16,
      from_device = function(b) return b / 2 end,
      to_device = function(b) return b * 2 end,
      numeric_range = { minimum = 0.5, maximum = 3599.5, step = 0.5, unit = "s" },
      read_on_configure = true
    }),
    q(23, "sonoff_zbmini_r2_detach_relay_mode", D.sonoffZbminir2DetachRelayMode()),
    h.cluster_attribute(i, 22, {
      name = "sonoff_zbmini_r2_external_trigger_mode",
      emit = D.sonoffZbminir2ExtTriggerMode(),
      data_type = c.Uint8,
      write_type = c.Uint8,
      from_device = function(b) return ({ [0] = "edge", [1] = "pulse", [2] = "following_off", [130] = "following_on" })[b] end,
      to_device = function(b) return ({ edge = 0, pulse = 1, following_off = 2, following_on = 130 })[b] end,
      read_on_configure = true
    }),
    h.cluster_attribute(i, nil, { name = "sonoff_zbmini_r2_inching_control", write_only = true, sender = n }),
    h.cluster_attribute(i, nil, { name = "sonoff_zbmini_r2_inching_time", write_only = true, sender = n }),
    h.cluster_attribute(i, nil, { name = "sonoff_zbmini_r2_inching_mode", write_only = true, sender = n })
  }
}

local R = {
  profile = "buttons-zunzunbee-sswz8t",
  button_actions = { "pushed", "held" },
  zcl_clusters = {
    h.cluster_attribute(h.CLUSTER_IAS_ZONE, h.ATTR_ZONE_STATUS, {
      name = "zunzunbee_button_action",
      endpoint = 1,
      read_only = true,
      read_on_refresh = false,
      data_type = c.Bitmap16,
      command_id = 0,
      command_extractor = function(aI)
        local ay = aI.body.zcl_body
        local ah = ay.zone_status or ay.zonestatus
        return type(ah) == "table" and ah.value or ah
      end,
      from_device = function(b)
        b = type(b) == "table" and b.value or b
        local button = ({ [2] = 1, [4] = 2, [8] = 3, [16] = 4,
          [32] = 5, [64] = 6, [128] = 7, [256] = 8 })[bit32.band(b, 510)]
        if button == nil then return nil end
        return { component = "button" .. button, action = b % 2 == 1 and "held" or "pushed" }
      end,
      handler = function(a, an)
        a:emit_component_event(
          { id = an.component },
          J.button.button(an.action, { state_change = true })
        )
        h.schedule_battery_refresh_after_button(a)
      end
    }),
    h.battery{ endpoint = 1, minimum_interval = 3600, maximum_interval = 65000, reportable_change = 10 },
    h.temperature{ endpoint = 1, minimum_interval = 10, maximum_interval = 3600, reportable_change = 100 }
  }
}

e(aD, {
  f("Third Reality", "3RSP0186Z"),
  f("Third Reality", "3RSPJ0187Z"),
  f("Third Reality", "3RSPE02065Z"),
  f("Third Reality", "3RSPU01080Z")
})

e(aE, {
  f("Third Reality", "3RWP01073Z")
})

e(W, {
  f("Third Reality, Inc", "3RSS009Z"),
  f("Third Reality, Inc", "3RSS008Z")
})

e(t, {
  f("Third Reality, Inc", "3RSS007Z")
})

e(Q, {
  f("SONOFF", "MINI-ZBD"),
  f("SONOFF", "ZBMINIR2")
})

e(g, {
  f("Candeo", "C-ZB-SM30-2G")
})

e(t, {
  f("Candeo", "C205"),
  f("IKEA", "E2006")
})

e(T, {
  f("HEIMAN", "HS2SW1A-EF-3.0"),
  f("HEIMAN", "HS2SW1A-EFR-3.0"),
  f("HEIMAN", "HS2SW1L-EFR-3.0"),
  f("HEIMAN", "HS6SW1A-W-EF-3.0")
})

e(t, {
  f("KlikAanKlikUit", "Built-in Switch"),
  f("Oz Smart Things", "WSP403"),
  f("Sibling", "Powerswitch-ZK(W)"),
  f("Sunricher", "SR-ZG9101SAC-HP-SWITCH-B"),
  f("BTicino", "3584C"),
  f("BTicino", "3577C"),
  f("BTicino", "FC80AC"),
  f("BTicino", "FC80CC"),
  f("BTicino", "FC80RC"),
  f("BTicino", "LN4570CWI"),
  f("Elko", "EKO07250"),
  f("Elko", "EKO07251"),
  f("Elko", "EKO07252"),
  f("Elko", "EKO07253"),
  f("Elko", "EKO20004"),
  f("Elko", "EKO30198"),
  f("Elko", "EKO30199"),
  f("Gira", "2430-100"),
  f("Gira", "2435-10"),
  f("Jung", "ZLLHS4"),
  f("Legrand", "199142"),
  f("Sunricher", "SR-ZG9100A-S")
})

e(t, {
  f("Schneider Electric", "1GANG/SWITCH/1"),
  f("Schneider Electric", "CH10AX/SWITCH/1"),
  f("Schneider Electric", "CH2AX/SWITCH/1"),
  f("Schneider Electric", "NHPB/SWITCH/1"),
  f("Schneider Electric", "PUCK/SWITCH/1"),
  f("Schneider Electric", "U201SRY2KWZB")
})

e(t, {
  f("TERNCY", "TERNCY-LS01")
})

e(aa, {
  f("Schneider Electric", "A3N31SR800ZB_xx_C1"),
  f("Schneider Electric", "E8331SRY800ZB")
})

e(ab, {
  f("Schneider Electric", "A3N32SR800ZB_xx_C1"),
  f("Schneider Electric", "E8332SRY800ZB")
})

e(ac, {
  f("Schneider Electric", "A3N33SR800ZB_xx_C1"),
  f("Schneider Electric", "E8333SRY800ZB")
})

e(t, x("Sunricher", {
  "ON/OFF",
  "ZIGBEE-SWITCH",
  "Micro Smart OnOff",
  "HK-SL-RELAY-A"
}))

e(ai, {
  f("Candeo", "C-ZB-SM205-2G")
})

e(U, {
  f("HEIMAN", "HS2SW2A-EF-3.0"),
  f("HEIMAN", "HS2SW2A-EFR-3.0"),
  f("HEIMAN", "HS2SW2L-EFR-3.0"),
  f("HEIMAN", "HS6SW2A-W-EF-3.0")
})

e(ai, {
  f("LED-Trading", "UP-SA-9127D"),
  f("Sunricher", "ON/OFF(2CH)"),
  f("Sunricher", "SR-ZG9101SAC-HP-SWITCH-2CH")
})

e(V, {
  f("HEIMAN", "HS2SW3A-EF-3.0"),
  f("HEIMAN", "HS2SW3A-EFR-3.0"),
  f("HEIMAN", "HS2SW3L-EFR-3.0"),
  f("HEIMAN", "HS6SW3A-W-EF-3.0")
})

e(ar, {
  f("Nova Digital", "TPZ-4"),
  f("Tuya", "DS-111"),
  f("MHCOZY", "TYWB 4ch-RF"),
  f("AVATTO", "TS0004_1"),
  f("AVATTO", "ZBTS60-04"),
  f("RSH", "SB04-Zigbee"),
  f("AVATTO", "ZWSM16-4"),
  f("Moes", "ZM4LT4"),
  f("iHseno", "_TZ3000_knoj8lpk"),
  f("AVATTO", "ZWOT12"),
  f("Coibeu", "ZB414"),
  f("Nova Digital", "SA-4"),
  f("Mercator Ikuü", "SSW04"),
  f("OXT", "SWTZ27"),
  f("TUYATEC", "GDKES-04TZXD"),
  f("MakeGood", "MG-ZG04W/B/G"),
  f("TERNCY", "TERNCY-WS01-S4"),
  f("_TZ3210_qjvi92wz", "TS0014"),
  f("_TZ3210_w3hl6rao", "TS0014"),
  f("_TZ3210_z4hgsevd", "TS0014"),
  f("Vizo", "VZ-221S"),
  f("Vizo", "VZ-222S"),
  f("Vizo", "VZ-223S"),
  f("LELLKI", "WP33-EU")
})

e(aj, {
  f("Sunricher", "SR-ZG9023A-EU")
})

e(R, {
  f("zunzunbee", "SSWZ8T")
})

-- ZCL REPORTING CAPABILITIES BEGIN
h.attach_reporting_capabilities(u, {
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
  registrations = u
}
