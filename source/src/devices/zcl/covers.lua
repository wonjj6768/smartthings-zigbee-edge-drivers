-- 커버/블라인드 디바이스 정의

local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"

local device_definitions, register_device_definition = device_helpers.definition_registry()

-- Zigbee Window Covering의 표준 lift position은 0=open, 100=closed이다.
-- SmartThings windowShadeLevel은 0=closed, 100=open이므로 coverInverted=false
-- 기기에는 양방향 100-value 변환을 적용한다. Tuya TS130F처럼 Z2M이
-- coverInverted=true로 정의한 기기는 wire 값을 그대로 사용한다.
local function standard_cover_position_converter()
  return {
    from = function(value)
      if type(value) ~= "number" then
        return value
      end
      return 100 - math.max(0, math.min(100, value))
    end,
    to = function(value)
      if type(value) ~= "number" then
        return value
      end
      return 100 - math.max(0, math.min(100, value))
    end,
  }
end

local function standard_window_shade_state_converter()
  return {
    from = function(value)
      if type(value) ~= "number" then
        return value
      end
      if value <= 0 then
        return "open"
      end
      if value >= 100 then
        return "closed"
      end
      return "partially open"
    end,
  }
end

local ts130f_cover = {
  profile = "covers-cover",
  zcl_clusters = {
    zcl.tuya_magic_packet(),
    zcl.cover_position(),
    zcl.window_shade_state(),
    zcl.cover_state(),
  },
}

local ts130f_dual_cover = {
  profile = "covers-cover-2",
  zcl_clusters = {
    zcl.tuya_magic_packet(),
    zcl.cover_position({ endpoint = 1, component = "main" }),
    zcl.window_shade_state({ endpoint = 1, component = "main" }),
    zcl.cover_state({ endpoint = 1, component = "main" }),
    zcl.cover_position({ endpoint = 2, component = "shade2" }),
    zcl.window_shade_state({ endpoint = 2, component = "shade2" }),
    zcl.cover_state({ endpoint = 2, component = "shade2" }),
  },
}

local standard_cover_battery = {
  profile = "covers-cover-battery",
  zcl_clusters = {
    zcl.cover_position({ converter = standard_cover_position_converter() }),
    zcl.window_shade_state({ converter = standard_window_shade_state_converter() }),
    zcl.cover_state(),
    zcl.battery(),
  },
}

register_device_definition(ts130f_cover, device_helpers.create_fingerprints("TS130F", {
  "_TZ3000_bs93npae",
  "_TZ3000_dojqjapa",
  "_TZ3000_8h7wgocw",
  "_TZ3000_e3vhyirx",
  "_TZ3000_femsaaua",
  "_TZ3000_5iixzdo7",
  "_TZ3000_yruungrl",
  "_TZ3000_jwv3cwak",
  "_TZ3000_74hsp7qy",
  "_TZ3210_dwytrmda",
  "_TZ3000_vw8pawxa",
  "_TZ3210_xbpt8ewc",
  "_TZ3000_egq7y6pr",
  "_TZ3000_fccpjz5z",
  "_TZ3000_vd43bbfq",
  "_TZ3000_zirycpws",
  "_TZ3210_ol1uhvza",
}))

register_device_definition(ts130f_cover, {
  device_helpers.create_fingerprint("Aqara", "lumi.curtain.acn04"),
  device_helpers.create_fingerprint("LUMI", "lumi.curtain.acn04"),
  device_helpers.create_fingerprint("LUMI", "lumi.curtain.acn018"),
})

register_device_definition(ts130f_cover, device_helpers.create_fingerprints("TS130F", {
  "_TZ3000_1dd0d5yi",
}))

register_device_definition(ts130f_dual_cover, device_helpers.create_fingerprints("TS130F", {
  "_TZ3000_bmhwnl7s",
  "_TZ3000_esynmmox",
  "_TZ3000_j1xl73iw",
  "_TZ3000_kmsbwdol",
  "_TZ3000_l6iqph4f",
  "_TZ3000_xdo0hj1k",
}))

register_device_definition(standard_cover_battery, device_helpers.create_fingerprints("TS0301", {
  "_TZE200_9caxna4s",
}))

register_device_definition(standard_cover_battery, device_helpers.create_fingerprints("TS030F", {
  "_TZB000_42ha4rsc",
}))

register_device_definition(standard_cover_battery, {
  device_helpers.create_fingerprint("IKEA of Sweden", "FYRTUR block-out roller blind"),
  device_helpers.create_fingerprint("IKEA of Sweden", "KADRILJ roller blind"),
  device_helpers.create_fingerprint("IKEA of Sweden", "PRAKTLYSING cellular blind"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TREDANSEN block-out cellul blind"),
})

return device_definitions
