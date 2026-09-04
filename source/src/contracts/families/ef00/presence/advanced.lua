-- presence-advanced package-owned presence family definitions.

local capabilities = require "st.capabilities"
local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local zcl = require "protocol.zcl"
local device_helpers = require "contracts.helpers.family"
local common = require "contracts.helpers.ef00_presence"

local converter = tuya.converter
local device_definitions, register_device_definition = common.isolated_definition_registry(device_helpers.definition_registry)
local function register_presence_definition(definitions_or_table, fingerprint_list, ranges)
  return common.register_presence_definition(
    register_device_definition, definitions_or_table, fingerprint_list, ranges
  )
end
local ts0601_fingerprints = common.ts0601_fingerprints
local on_off_enum1_converter = converter.lookup_from_to({ on = 1, off = 0 })
local breaker_mode_converter = converter.lookup_from_to({ standard = 0, ["local"] = 1 })
local radar_scene_yxz_converter = converter.lookup_from_to({
  default = 0, bathroom = 1, bedroom = 2, sleeping = 3, unknown = 4,
})
local detection_method_converter = converter.lookup_from_to({ only_move = 0, exist_move = 1 })
local sensor_state_mode_converter = converter.lookup_from_to({
  on = 0, off = 1, occupied = 2, unoccupied = 3,
})
-- `Novato / ZIS-04` is the Z2M whiteLabel product row for `_TZE204_f2rflfa6`,
-- not an interviewed manufacturer/model pair, so it is not registered.



-- ══════════════════════════════════════════════════════════════

-- 2-12. presence_model_zy_m100_24g: ZY-M100-24G (AC, 조도 DP104)

-- Z2M: _TZE204_ijxvkhd0 (ZY-M100-24G)

-- ══════════════════════════════════════════════════════════════

-- Z2M Tuya ZY-M100-24G (tuya.ts:17930)
-- DP104 illuminance, DP105 read-only state none/presence/move,
-- DP106 motion sensitivity /10 from-only, DP107 max range /100,
-- DP109 target distance /100, DP110 presence timeout, DP111 presence
-- sensitivity /10 from-only, DP112 presence trueFalse1.  Z2M declares no
-- expose for DP102/DP103 illuminance thresholds, so they stay log-only.
local presence_model_zy_m100_24g = {

  profile = "safety-presence-zym10024g-illuminance",
  package_group = "presence-advanced",

  named_datapoints = true,

  tuya.dp_numeric(102, { name = "illuminance_threshold_max" }),

  tuya.dp_numeric(103, { name = "illuminance_threshold_min" }),

  tuya.dp_illuminance(104, { emit = emit.illuminance() }),

  tuya.dp_enum(105, {
    name = "state",
    read_only = true,
    emit = emit.zym10024gState(),
    converter = converter.lookup_from_to({
      none = 0,
      presence = 1,
      move = 2,
    }),
  }),

  tuya.dp_numeric(106, {
    name = "move_sensitivity",
    emit = emit.zym10024gMoveSensitivity(),
    converter = converter.divide_by_from_only(10),
  }),

  tuya.dp_numeric(107, {
    name = "max_range",
    emit = emit.zym10024gMaxRange(),
    converter = converter.divide_by_pair(100),
  }),

  tuya.dp_numeric(109, {
    name = "target_distance",
    read_only = true,
    emit = emit.zym10024gTargetDistance(),
    converter = converter.divide_by_from_only(100),
  }),

  tuya.dp_numeric(110, { name = "presence_timeout", emit = emit.zym10024gTimeout() }),

  tuya.dp_numeric(111, {
    name = "presence_sensitivity",
    emit = emit.zym10024gSensitivity(),
    converter = converter.divide_by_from_only(10),
  }),

  tuya.dp_presence(112, { emit = emit.presence(), converter = converter.true_false1() }),

}

register_presence_definition(presence_model_zy_m100_24g, ts0601_fingerprints({

  "_TZE204_ijxvkhd0",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-13. presence_model_zy_m100_24gv2: ZY-M100-24GV2 (AC, 조도 DP103)

-- Z2M: _TZE204_7gclukjs (ZY-M100-24GV2)

-- ══════════════════════════════════════════════════════════════

-- Z2M Tuya ZY-M100-24GV2 (tuya.ts:17987)
-- Unlike V3, presence is its own DP104 trueFalse1 and DP1 only carries the
-- three-state label.  DP2 motion sensitivity 0..10, DP3/DP4 min/max range
-- /100 with 0..8.25 / 0.75..9.0 step 0.75, DP9 target distance /10,
-- DP102 presence sensitivity 0..10, DP103 illuminance, DP105 fade time
-- 1..1500 s.  The state DP was previously parsed but never exposed.
local presence_model_zy_m100_24gv2 = {

  profile = "safety-presence-zym10024gv2-move-range-illuminance",
  package_group = "presence-advanced",

  named_datapoints = true,

  datapoints = {

    tuya.dp_enum(1, {
      name = "state",
      read_only = true,
      emit = emit.zym24gv2State(),
      converter = converter.from_only(converter.lookup_value({
        [0] = "none",
        [1] = "presence",
        [2] = "move",
      })),
    }),

    tuya.dp_numeric(2, { name = "move_sensitivity", emit = emit.zym24gv2MoveSensitivity() }),

    tuya.dp_numeric(3, {
      name = "min_range",
      emit = emit.zym24gv2MinRange(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(4, {
      name = "max_range",
      emit = emit.zym24gv2MaxRange(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(9, {
      name = "target_distance",
      read_only = true,
      emit = emit.zym24gv2TargetDistance(),
      converter = converter.divide_by_from_only(10),
    }),

    tuya.dp_numeric(102, { name = "presence_sensitivity", emit = emit.zym24gv2Sensitivity() }),

    tuya.dp_illuminance(103, { emit = emit.illuminance() }),

    tuya.dp_presence(104, { emit = emit.presence(), converter = converter.true_false1() }),

    tuya.dp_numeric(105, { name = "presence_timeout", emit = emit.zym24gv2Timeout() }),

  },

}



register_presence_definition(presence_model_zy_m100_24gv2, ts0601_fingerprints({

  "_TZE204_7gclukjs",

}))



-- ══════════════════════════════════════════════════════════════

-- 2-14. presence_model_zy_m100_24gv3: ZY-M100-24GV3 (AC, 조도 DP103)

-- Z2M: _TZE204_ya4ft0w4 (ZY-M100-24GV3)

-- ══════════════════════════════════════════════════════════════

-- Z2M Tuya ZY-M100-24GV3 (tuya.ts:18037)
-- DP1 carries both the presence flag and the three-state presence label in a
-- single report: 0 none/absent, 1 presence, 2 move.  DP2 motion sensitivity
-- 1..10, DP3/DP4 min/max range /100, DP9 target distance /10, DP101 find
-- switch (no expose), DP102 presence sensitivity 1..10, DP103 illuminance and
-- DP105 fade time 1..15000 s.
--
-- Z2M builds `exposes` per manufacturerName, and the two exact groups do not
-- share a range: gkfbdvyx uses 0..6 / 0.5..9.0 step 0.5 (tuya.ts:18064) while
-- ya4ft0w4 uses 0..8.25 / 0.75..9.0 step 0.75 (tuya.ts:18083).  They therefore
-- get separate profiles and separate range capabilities.
local function zym24gv3_presence_from_state()
  local emitter = emit.presence()
  return function(device, value, dp_info, mapping_context)
    return emitter(device, value == "presence" or value == "move", dp_info, mapping_context)
  end
end

local zym24gv3_state_converter = converter.from_only(converter.lookup_value({
  [0] = "none",
  [1] = "presence",
  [2] = "move",
}))

local function build_zym24gv3_datapoints(min_range_emitter, max_range_emitter)
  return {

    tuya.dp_enum(1, {
      name = "presence_state",
      read_only = true,
      emit = emit.all(emit.zym24gv3State(), zym24gv3_presence_from_state()),
      converter = zym24gv3_state_converter,
    }),

    tuya.dp_numeric(2, { name = "move_sensitivity", emit = emit.zym24gv3MoveSensitivity() }),

    tuya.dp_numeric(3, {
      name = "min_range",
      emit = min_range_emitter,
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(4, {
      name = "max_range",
      emit = max_range_emitter,
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(9, {
      name = "target_distance",
      read_only = true,
      emit = emit.zym24gv3TargetDistance(),
      converter = converter.divide_by_from_only(10),
    }),

    tuya.dp_binary(101, { name = "find_switch" }),

    tuya.dp_numeric(102, { name = "presence_sensitivity", emit = emit.zym24gv3Sensitivity() }),

    tuya.dp_illuminance(103, { emit = emit.illuminance() }),

    tuya.dp_numeric(105, { name = "presence_timeout", emit = emit.zym24gv3Timeout() }),

  }
end

local presence_model_zy_m100_24gv3_b = {

  profile = "safety-presence-zym10024gv3-move-range-illuminance",
  package_group = "presence-advanced",

  named_datapoints = true,

  datapoints = build_zym24gv3_datapoints(emit.zym24gv3bMinRange(), emit.zym24gv3bMaxRange()),

}



register_presence_definition(presence_model_zy_m100_24gv3_b, ts0601_fingerprints({

  "_TZE204_ya4ft0w4",

  "_TZE200_ya4ft0w4",

}))

local presence_model_zy_m100_24gv3_a = {

  profile = "safety-presence-zym10024gv3a-move-range-illuminance",
  package_group = "presence-advanced",

  named_datapoints = true,

  datapoints = build_zym24gv3_datapoints(emit.zym24gv3aMinRange(), emit.zym24gv3aMaxRange()),

}



register_presence_definition(presence_model_zy_m100_24gv3_a, ts0601_fingerprints({

  "_TZE204_gkfbdvyx",

  "_TZE200_gkfbdvyx",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-15. presence_model_yxzbrb58: YXZBRB58 (AC, 조도 DP101)

-- Z2M: _TZE204_sooucan5 (YXZBRB58)

-- ══════════════════════════════════════════════════════════════

-- Z2M Tuya YXZBRB58 (tuya.ts:17688)
-- DP1 presence trueFalse1, DP2 radar sensitivity 0..9, DP3/DP4 min/max range
-- /100 with a 0..10 m step 0.1 expose, DP101 illuminance, DP102 detection
-- delay /10 0..10 s, DP103 fading time /10 0..1500 s, DP104 radar scene and
-- DP105 target distance /100.  DP105 previously had no scale, so the reported
-- distance was 100x too large.
local presence_model_yxzbrb58 = {

  profile = "safety-presence-yxzbrb58-range-delay-scene-illuminance",
  package_group = "presence-advanced",

  named_datapoints = true,

  datapoints = {

    tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),

    tuya.dp_numeric(2, { name = "radar_sensitivity", emit = emit.yxzbrb58Sensitivity() }),

    tuya.dp_numeric(3, {
      name = "min_range",
      emit = emit.yxzbrb58MinRange(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(4, {
      name = "max_range",
      emit = emit.yxzbrb58MaxRange(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_illuminance(101, { emit = emit.illuminance() }),

    tuya.dp_numeric(102, {
      name = "detection_delay",
      emit = emit.yxzbrb58DetectionDelay(),
      converter = converter.divide_by_pair(10),
    }),

    tuya.dp_numeric(103, {
      name = "fading_time",
      emit = emit.yxzbrb58FadingTime(),
      converter = converter.divide_by_pair(10),
    }),

    tuya.dp_enum(104, {
      name = "radar_scene",
      emit = emit.yxzbrb58RadarScene(),
      converter = radar_scene_yxz_converter,
    }),

    tuya.dp_numeric(105, {
      name = "target_distance",
      read_only = true,
      emit = emit.yxzbrb58TargetDistance(),
      converter = converter.divide_by_from_only(100),
    }),

  },

}



register_presence_definition(presence_model_yxzbrb58, ts0601_fingerprints({

  "_TZE204_sooucan5",

  "_TZE204_oqtpvx51",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-16. presence_model_ctl_r1_ty_zigbee: CTL-R1-TY-Zigbee (AC, 조도 DP101)

-- Z2M: _TZE204_e9ajs4ft (CTL-R1-TY-Zigbee)

-- ══════════════════════════════════════════════════════════════

-- Z2M Tuya CTL-R1-TY-Zigbee (tuya.ts:18148)
-- DP1 presence trueFalse1, DP2 presence sensitivity 0..100%, DP4 detection
-- range /10 1.5..4.5 m, DP101 illuminance, DP102/DP103 illuminance thresholds
-- 0..2000 lx, DP104 detection delay 1..600 s (the shared capability allowed
-- 0..3600, which this exact rejects), DP105 read-only light state, DP106 light
-- linkage trueFalseEnum1, DP107 indicator light presence/off/on, DP108
-- detection method and DP109 threshold switch trueFalseEnum1.  DP113 find
-- switch has no Z2M expose, so it stays unexposed.
local presence_model_ctl_r1_ty_zigbee = {

  profile = "safety-presence-ctlr1-threshold-min-delay-illuminance",
  package_group = "presence-advanced",

  named_datapoints = true,

  datapoints = {

    tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),

    tuya.dp_numeric(2, { name = "presence_sensitivity", emit = emit.ctlr1Sensitivity() }),

    tuya.dp_numeric(4, {
      name = "detection_range",
      emit = emit.ctlr1DetectionRange(),
      converter = converter.divide_by_pair(10),
    }),

    tuya.dp_illuminance(101, { emit = emit.illuminance() }),

    tuya.dp_numeric(102, { name = "illuminance_threshold_max", emit = emit.ctlr1ThresholdMax() }),

    tuya.dp_numeric(103, { name = "illuminance_threshold_min", emit = emit.ctlr1ThresholdMin() }),

    tuya.dp_numeric(104, { name = "detection_delay", emit = emit.ctlr1DetectionDelay() }),

    tuya.dp_binary(105, {
      name = "light_switch",
      read_only = true,
      emit = emit.ctlr1LightSwitch(),
      converter = converter.lookup_from_to({ ON = true, OFF = false }),
    }),

    tuya.dp_enum(106, {
      name = "light_linkage",
      emit = emit.ctlr1LightLinkage(),
      converter = on_off_enum1_converter,
    }),

    tuya.dp_enum(107, {
      name = "indicator_light",
      emit = emit.ctlr1IndicatorLight(),
      converter = converter.lookup_from_to({
        presence = 0,
        off = 1,
        on = 2,
      }),
    }),

    tuya.dp_enum(108, {
      name = "detection_method",
      emit = emit.ctlr1DetectionMethod(),
      converter = detection_method_converter,
    }),

    tuya.dp_enum(109, {
      name = "illuminance_switch",
      emit = emit.ctlr1ThresholdSwitch(),
      converter = on_off_enum1_converter,
    }),

  },

}



register_presence_definition(presence_model_ctl_r1_ty_zigbee, ts0601_fingerprints({

  "_TZE204_e9ajs4ft",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-17. presence_model_rt_zcz03z: RT_ZCZ03Z (AC, 조도 DP102)

-- Z2M: _TZE204_uxllnywp (RT_ZCZ03Z)

-- ══════════════════════════════════════════════════════════════

-- Z2M Tuya RT_ZCZ03Z (tuya.ts:20304)
-- DP1 presence uses trueFalse(4), and every distance on this exact is
-- reported in centimetres rather than metres: DP101 target distance,
-- DP107 max distance 0..840 cm, DP108 min distance 0..840 cm.  DP102
-- illuminance, DP103 delay 1..59 s, DP104 LED indicator, DP111 presence
-- sensitivity 1..10.  The shared metre-based capabilities cannot describe
-- this contract, so the family owns fixed centimetre capabilities.
local presence_model_rt_zcz03z = {

  profile = "safety-presence-rtzcz03z-range-illuminance",
  package_group = "presence-advanced",

  named_datapoints = true,

  datapoints = {

    tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false(4) }),

    tuya.dp_numeric(101, {
      name = "target_distance",
      read_only = true,
      emit = emit.rtzcz03zTargetDistance(),
    }),

    tuya.dp_illuminance(102, { emit = emit.illuminance() }),

    tuya.dp_numeric(103, { name = "fading_time", emit = emit.rtzcz03zFadingTime() }),

    tuya.dp_binary(104, {
      name = "indicator",
      emit = emit.rtzcz03zIndicator(),
      converter = converter.lookup_from_to({ ON = true, OFF = false }),
    }),

    tuya.dp_numeric(107, { name = "max_distance", emit = emit.rtzcz03zMaxDistance() }),

    tuya.dp_numeric(108, { name = "min_distance", emit = emit.rtzcz03zMinDistance() }),

    tuya.dp_numeric(111, { name = "presence_sensitivity", emit = emit.rtzcz03zSensitivity() }),

  },

}



register_presence_definition(presence_model_rt_zcz03z, ts0601_fingerprints({

  "_TZE204_uxllnywp",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-18. presence_model_mtg075_zb_rl: MTG075-ZB-RL (AC, 조도 DP104, 릴레이 포함)

-- Z2M: _TZE204_sbyx0lm6 (MTG075-ZB-RL)

-- ══════════════════════════════════════════════════════════════

-- Z2M Tuya MTG075-ZB-RL (tuya.ts:18240)
-- DP1 presence trueFalse1, DP2 radar sensitivity 0..9, DP3 shield range /100
-- 0..8 m, DP4 detection range /100 0..8 m, DP6 equipment status (no expose),
-- DP9 target distance /100, DP101 entry filter time /10 0..10 s, DP102
-- departure delay 0..600 s, DP104 illuminance /10, DP105 entry sensitivity
-- 0..9, DP106 entry distance indentation /100 0..8 m step 0.1, DP107 breaker
-- mode, DP108 breaker status, DP109 status indication, DP110 illuminance
-- threshold /10 0..420 lx, DP111 breaker polarity NC/NO, DP112 block time /10
-- 0..10 s, DP115 sensor state.  Entry filter time and block time previously
-- allowed 0..600 s and the breaker polarity was never exposed.
local presence_model_mtg075_zb_rl = {

  profile = "safety-presence-mtg075-entry-controls-illuminance",
  package_group = "presence-advanced",

  named_datapoints = true,

  datapoints = {

    tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),

    tuya.dp_numeric(2, { name = "radar_sensitivity", emit = emit.mtg075RadarSensitivity() }),

    tuya.dp_numeric(3, {
      name = "shield_range",
      emit = emit.mtg075ShieldRange(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(4, {
      name = "detection_range",
      emit = emit.mtg075DetectionRange(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(6, { name = "equipment_status", read_only = true }),

    tuya.dp_numeric(9, {
      name = "target_distance",
      read_only = true,
      emit = emit.mtg075TargetDistance(),
      converter = converter.divide_by_from_only(100),
    }),

    tuya.dp_numeric(101, {
      name = "entry_filter_time",
      emit = emit.mtg075EntryFilterTime(),
      converter = converter.divide_by_pair(10),
    }),

    tuya.dp_numeric(102, { name = "departure_delay", emit = emit.mtg075DepartureDelay() }),

    tuya.dp_illuminance(104, { emit = emit.illuminance(), scale = 10 }),

    tuya.dp_numeric(105, { name = "entry_sensitivity", emit = emit.mtg075EntrySensitivity() }),

    tuya.dp_numeric(106, {
      name = "entry_distance_indentation",
      emit = emit.mtg075EntryIndentation(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_enum(107, {
      name = "breaker_mode",
      emit = emit.mtg075BreakerMode(),
      converter = breaker_mode_converter,
    }),

    tuya.dp_enum(108, {
      name = "breaker_status",
      emit = emit.mtg075BreakerStatus(),
      converter = converter.lookup_from_to({ OFF = 0, ON = 1 }),
    }),

    tuya.dp_enum(109, {
      name = "status_indication",
      emit = emit.mtg075StatusIndication(),
      converter = converter.lookup_from_to({ OFF = 0, ON = 1 }),
    }),

    tuya.dp_numeric(110, {
      name = "illuminance_threshold",
      emit = emit.mtg075IlluminanceThreshold(),
      converter = converter.divide_by_pair(10),
    }),

    tuya.dp_enum(111, {
      name = "breaker_polarity",
      emit = emit.mtg075BreakerPolarity(),
      converter = converter.lookup_from_to({ NC = 0, NO = 1 }),
    }),

    tuya.dp_numeric(112, {
      name = "block_time",
      emit = emit.mtg075BlockTime(),
      converter = converter.divide_by_pair(10),
    }),

    tuya.dp_enum(115, {
      name = "sensor_state",
      emit = emit.mtg075SensorState(),
      converter = sensor_state_mode_converter,
    }),

  },

}



register_presence_definition(presence_model_mtg075_zb_rl, ts0601_fingerprints({

  "_TZE204_sbyx0lm6",

  "_TZE204_clrdrnya",

  "_TZE204_dtzziy1e",

  "_TZE204_iaeejhvf",

  "_TZE204_mtoaryre",

  "_TZE200_mp902om5",

  "_TZE204_pfayrzcw",

  "_TZE284_4qznlkbu",

  "_TZE200_clrdrnya",

  "_TZE200_sbyx0lm6",

}))

-- `Tuya / MTG275-ZB-RL`, `Tuya / MTG035-ZB-RL`, `Tuya / MTG235-ZB-RL` and
-- `QA / QASZ24R` are Z2M whiteLabel product rows for the exacts above, not
-- interviewed manufacturer/model pairs, so they are not registered.



-- ══════════════════════════════════════════════════════════════

-- 2-19. presence_model_zy_m100_s_3: ZY-M100-S_3 (AC, 조도 DP12, inverted)

-- Z2M: _TZE204_nbkshs6k (ZY-M100-S_3)

-- ══════════════════════════════════════════════════════════════

-- Z2M Tuya ZY-M100-S_3 (tuya.ts:20542)
-- DP1 presence with the inverted True=0/False=1 lookup, DP9 sensitivity
-- low/medium/high, DP10 keep time restricted to 30/60/120 only and DP12
-- illuminance.  The shared keep-time helper also offers 10 s, which this
-- exact does not accept, so both settings use fixed family capabilities.
local zym100s3_sensitivity_converter = converter.lookup_from_to({
  low = 0,
  medium = 1,
  high = 2,
})

local zym100s3_keep_time_converter = converter.lookup_from_to({
  ["30"] = 0,
  ["60"] = 1,
  ["120"] = 2,
})

local presence_model_zy_m100_s_3 = {

  profile = "safety-presence-zym100s3-keep-illuminance",
  package_group = "presence-advanced",

  named_datapoints = true,

  datapoints = {

    tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false0() }),

    tuya.dp_enum(9, {
      name = "sensitivity",
      emit = emit.zym100s3Sensitivity(),
      converter = zym100s3_sensitivity_converter,
    }),

    tuya.dp_enum(10, {
      name = "keep_time",
      emit = emit.zym100s3KeepTime(),
      converter = zym100s3_keep_time_converter,
    }),

    tuya.dp_illuminance(12, { emit = emit.illuminance() }),

  },

}



register_presence_definition(presence_model_zy_m100_s_3, ts0601_fingerprints({

  "_TZE204_nbkshs6k",

}))



-- ══════════════════════════════════════════════════════════════

-- 2-20. presence_model_zg_205z: ZG-205Z 5.8GHz (AC, 조도 DP102)

-- Z2M: _TZE204_dapwryy7 (ZG-205Z)

-- ══════════════════════════════════════════════════════════════

-- Z2M Tuya ZG-205Z (tuya.ts:20580)
-- DP1 has no direct presence value: Z2M derives both presence and the
-- five-state presence label from the same enum, where any state other than
-- none means presence.  DP101 target distance /100, DP102 illuminance,
-- DP103 hold delay 0..28800 s, DP104 indicator, DP107/DP108 move max/min /100
-- 0..10 m, DP109/DP110 breath max/min /100 0..6 m, DP114/DP115 small move
-- max/min /100 0..6 m, DP116..DP118 move/small move/breath sensitivity 0..10.
local function zg205z_presence_from_state()
  local emitter = emit.presence()
  return function(device, value, dp_info, mapping_context)
    return emitter(device, value ~= "none", dp_info, mapping_context)
  end
end

local presence_model_zg_205z = {

  profile = "safety-presence-zg205z-illuminance",
  package_group = "presence-advanced",

  named_datapoints = true,

  datapoints = {

    tuya.dp_enum(1, {
      name = "presence_state",
      read_only = true,
      emit = emit.all(emit.zg205zPresenceState(), zg205z_presence_from_state()),
      converter = converter.from_only(converter.lookup_value({
        [0] = "none",
        [1] = "presence",
        [2] = "peaceful",
        [3] = "small_movement",
        [4] = "large_movement",
      })),
    }),

    tuya.dp_numeric(101, {
      name = "target_distance",
      read_only = true,
      emit = emit.zg205zTargetDistance(),
      converter = converter.divide_by_from_only(100),
    }),

    tuya.dp_illuminance(102, { emit = emit.illuminance() }),

    tuya.dp_numeric(103, { name = "none_delay_time", emit = emit.zg205zNoneDelayTime() }),

    tuya.dp_binary(104, {
      name = "indicator",
      emit = emit.zg205zIndicator(),
      converter = converter.lookup_from_to({ ON = true, OFF = false }),
    }),

    tuya.dp_numeric(107, {
      name = "move_detection_max",
      emit = emit.zg205zMoveMax(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(108, {
      name = "move_detection_min",
      emit = emit.zg205zMoveMin(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(109, {
      name = "breath_detection_max",
      emit = emit.zg205zBreathMax(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(110, {
      name = "breath_detection_min",
      emit = emit.zg205zBreathMin(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(114, {
      name = "small_move_detection_max",
      emit = emit.zg205zSmallMoveMax(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(115, {
      name = "small_move_detection_min",
      emit = emit.zg205zSmallMoveMin(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(116, { name = "move_sensitivity", emit = emit.zg205zMoveSensitivity() }),

    tuya.dp_numeric(117, { name = "small_move_sensitivity", emit = emit.zg205zSmallMoveSensitivity() }),

    tuya.dp_numeric(118, { name = "breath_sensitivity", emit = emit.zg205zBreathSensitivity() }),

  },

}



register_presence_definition(presence_model_zg_205z, ts0601_fingerprints({

  "_TZE204_dapwryy7",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-21. presence_model_zg_205za: ZG-205Z/A (AC, 조도 DP106)

-- Z2M: _TZE200_crq3r3la / HOBEIAN (CK-BL702-MWS-01)

-- ══════════════════════════════════════════════════════════════

-- Z2M Tuya ZG-205Z/A (tuya.ts:14656)
-- DP1 presence trueFalse1, DP2/DP4 large sensitivity 0..10 and distance /100
-- 0..10 m, DP101 motion state, DP102 fading time 0..28800 s, DP104/DP105
-- medium distance /100 0..6 m and sensitivity 0..10, DP106 illuminance,
-- DP107 indicator, DP108/DP109 small distance /100 0..6 m and sensitivity
-- 0..10, DP122 target distance /100, DP123 minimum range /100 0..6 m.  The
-- Z2M expose caps minimum range at 6 m, not 10 m, and target distance and the
-- indicator were previously unexposed.  Z2M keeps DP3, DP103 and DP110..DP120
-- commented out as untested, so they stay unexposed here too.
local presence_model_zg_205za = {

  profile = "safety-presence-zg205za-illuminance",
  package_group = "presence-advanced",

  named_datapoints = true,

  datapoints = {

    tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),

    tuya.dp_numeric(2, {
      name = "large_motion_sensitivity",
      emit = emit.zg205zaLargeSensitivity(),
    }),

    tuya.dp_numeric(4, {
      name = "large_motion_distance",
      emit = emit.zg205zaLargeDistance(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_enum(101, {
      name = "motion_state",
      read_only = true,
      emit = emit.zg205zaMotionState(),
      converter = converter.from_only(converter.lookup_value({
        [0] = "none",
        [1] = "large",
        [2] = "medium",
        [3] = "small",
        [4] = "far",
        [5] = "near",
      })),
    }),

    tuya.dp_numeric(102, { name = "fading_time", emit = emit.zg205zaFadingTime() }),

    tuya.dp_numeric(104, {
      name = "medium_motion_distance",
      emit = emit.zg205zaMediumDistance(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(105, {
      name = "medium_motion_sensitivity",
      emit = emit.zg205zaMediumSensitivity(),
    }),

    tuya.dp_illuminance(106, { emit = emit.illuminance() }),

    tuya.dp_binary(107, {
      name = "indicator",
      emit = emit.zg205zaIndicator(),
      converter = converter.lookup_from_to({ ON = true, OFF = false }),
    }),

    tuya.dp_numeric(108, {
      name = "small_detection_distance",
      emit = emit.zg205zaSmallDistance(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(109, {
      name = "small_detection_sensitivity",
      emit = emit.zg205zaSmallSensitivity(),
    }),

    tuya.dp_numeric(122, {
      name = "target_distance",
      read_only = true,
      emit = emit.zg205zaTargetDistance(),
      converter = converter.divide_by_from_only(100),
    }),

    tuya.dp_numeric(123, {
      name = "minimum_range",
      emit = emit.zg205zaMinimumRange(),
      converter = converter.divide_by_pair(100),
    }),

  },

}



register_presence_definition(presence_model_zg_205za, {

  device_helpers.create_fingerprint("_TZE200_2aaelwxk", "TS0225"),

  device_helpers.create_fingerprint("_TZE200_crq3r3la", "TS0225"),

  device_helpers.create_fingerprint("HOBEIAN", "CK-BL702-MWS-01(7016)"),

  device_helpers.create_fingerprint("_TZE200_crq3r3la", "CK-BL702-MWS-01(7016)"),

})

-- ══════════════════════════════════════════════════════════════

-- 2-22. presence_model_zg_205zl: ZG-205ZL (AC, 조도 DP20)

-- Z2M: _TZE200_hl0ss9oa / ZGAF-205L / _TZE200_y4mdop0b

-- ══════════════════════════════════════════════════════════════

-- Z2M Tuya ZG-205ZL (tuya.ts:13985)
-- DP1 presence trueFalse1, DP11 motion state, DP12 fading time 0..3600 s,
-- DP13/DP15 large distance /100 0..10 m and sensitivity 0..10, DP14/DP16 small
-- distance /100 0..6 m and sensitivity 0..10, DP20 illuminance, DP24 LED mode,
-- DP101 alarm time 1..60 min, DP102 alarm volume, DP103/DP104 static distance
-- /100 0..6 m and sensitivity 0..10, DP105 working mode.  DP24 light mode and
-- the motion state were previously unexposed.
local presence_model_zg_205zl = {

  profile = "safety-presence-zg205zl-illuminance",
  package_group = "presence-advanced",

  named_datapoints = true,

  datapoints = {

    tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),

    tuya.dp_enum(11, {
      name = "motion_state",
      read_only = true,
      emit = emit.zg205zlMotionState(),
      converter = converter.from_only(converter.lookup_value({
        [0] = "none",
        [1] = "large",
        [2] = "small",
        [3] = "static",
        [4] = "far",
        [5] = "near",
      })),
    }),

    tuya.dp_numeric(12, { name = "fading_time", emit = emit.zg205zlFadingTime() }),

    tuya.dp_numeric(13, {
      name = "large_motion_distance",
      emit = emit.zg205zlLargeDistance(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(14, {
      name = "small_motion_distance",
      emit = emit.zg205zlSmallDistance(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(15, {
      name = "large_motion_sensitivity",
      emit = emit.zg205zlLargeSensitivity(),
    }),

    tuya.dp_numeric(16, {
      name = "small_motion_sensitivity",
      emit = emit.zg205zlSmallSensitivity(),
    }),

    tuya.dp_illuminance(20, { emit = emit.illuminance() }),

    tuya.dp_binary(24, {
      name = "light_mode",
      emit = emit.zg205zlLightMode(),
      converter = converter.lookup_from_to({ ON = true, OFF = false }),
    }),

    tuya.dp_numeric(101, { name = "alarm_time", emit = emit.zg205zlAlarmTime() }),

    tuya.dp_enum(102, {
      name = "alarm_volume",
      emit = emit.zg205zlAlarmVolume(),
      converter = converter.lookup_from_to({
        low = 0,
        medium = 1,
        high = 2,
        mute = 3,
      }),
    }),

    tuya.dp_numeric(103, {
      name = "static_distance",
      emit = emit.zg205zlStaticDistance(),
      converter = converter.divide_by_pair(100),
    }),

    tuya.dp_numeric(104, {
      name = "static_sensitivity",
      emit = emit.zg205zlStaticSensitivity(),
    }),

    tuya.dp_enum(105, {
      name = "working_mode",
      emit = emit.zg205zlMode(),
      converter = converter.lookup_from_to({
        arm = 0,
        off = 1,
        alarm = 2,
        doorbell = 3,
      }),
    }),

  },

}



register_presence_definition(presence_model_zg_205zl, {

  device_helpers.create_fingerprint("_TZE200_hl0ss9oa", "TS0225"),

  device_helpers.create_fingerprint("ZGAF-205L", "CK-BL702-MWS-01(7016)"),

  device_helpers.create_fingerprint("_TZE200_y4mdop0b", "TS0225"),

})



-- ══════════════════════════════════════════════════════════════

-- 2-22a. presence_model_mtd085_zb: MTD085-ZB (AC, 조도 DP107)

-- Z2M: _TZ321C_fkzihax8 / _TZ321C_4slreunp

-- ══════════════════════════════════════════════════════════════

local sensor_state_mode_mtd085_converter = converter.lookup_from_to({

  on = 0,

  occupied = 1,

  unoccupied = 2,

})

local debug_mode_mtd085_converter = converter.lookup_from_to({
  OFF = 0,
  ON = 1,
})

local scene_preset_mtd085_converter = converter.lookup_from_to({
  custom = 0,
  toilet = 1,
  kitchen = 2,
  hallway = 3,
  bedroom = 4,
  livingroom = 5,
  meetingroom = 6,
  factory_default = 7,
})

local distance_report_mode_mtd085_converter = converter.lookup_from_to({
  normal = 0,
  occupancy_detection = 1,
})

local presence_model_mtd085_zb = {

  profile = "safety-occupancy-mtd085-illuminance",
  package_group = "presence-advanced",

  datapoints = {

    tuya.dp_numeric(101, {
      name = "entry_sensitivity",
      emit = emit.mtd085EntrySensitivity(),
      command_id = tuya.SEND_DATA,
    }),

    tuya.dp_numeric(102, {
      name = "entry_distance",
      emit = emit.mtd085EntryDistance(),
      converter = converter.divide_by_pair(100),
      command_id = tuya.SEND_DATA,
    }),

    tuya.dp_numeric(103, {
      name = "departure_delay",
      emit = emit.mtd085DepartureDelay(),
      command_id = tuya.SEND_DATA,
    }),

    tuya.dp_numeric(104, {
      name = "entry_filter_time",
      emit = emit.mtd085EntryFilterTime(),
      converter = converter.divide_by_pair(100),
      command_id = tuya.SEND_DATA,
    }),

    tuya.dp_numeric(105, {
      name = "block_time",
      emit = emit.mtd085BlockTime(),
      converter = converter.divide_by_pair(10),
      command_id = tuya.SEND_DATA,
    }),

    tuya.dp_illuminance(107, {
      emit = emit.illuminance(),
      converter = converter.divide_by_pair(10),
      read_only = true,
    }),

    tuya.dp_enum(108, {
      name = "debug_mode",
      emit = emit.mtd085DebugMode(),
      converter = debug_mode_mtd085_converter,
      command_id = tuya.SEND_DATA,
    }),

    tuya.dp_numeric(109, {
      name = "debug_distance",
      emit = emit.mtd085DebugDistance(),
      converter = converter.divide_by_pair(100),
      read_only = true,
    }),

    tuya.dp_numeric(110, {
      name = "debug_countdown",
      emit = emit.mtd085DebugCountdown(),
      read_only = true,
    }),

    tuya.dp_enum(111, {
      name = "scene_preset",
      emit = emit.mtd085ScenePreset(),
      converter = scene_preset_mtd085_converter,
      command_id = tuya.SEND_DATA,
    }),

    tuya.dp_enum(112, {
      name = "sensor",
      emit = emit.mtd085Sensor(),
      converter = sensor_state_mode_mtd085_converter,
      command_id = tuya.SEND_DATA,
    }),

    tuya.dp_numeric(113, { name = "cline", read_only = true }),

    tuya.dp_enum(114, {
      name = "status_indication",
      emit = emit.mtd085StatusIndication(),
      converter = debug_mode_mtd085_converter,
      command_id = tuya.SEND_DATA,
    }),

    tuya.dp_numeric(115, {
      name = "radar_sensitivity",
      emit = emit.mtd085RadarSensitivity(),
      command_id = tuya.SEND_DATA,
    }),

    tuya.dp_numeric(116, {
      name = "shield_range",
      emit = emit.mtd085ShieldRange(),
      converter = converter.divide_by_pair(100),
      command_id = tuya.SEND_DATA,
    }),

    tuya.dp_numeric(117, {
      name = "detection_range",
      emit = emit.mtd085DetectionRange(),
      converter = converter.divide_by_pair(100),
      command_id = tuya.SEND_DATA,
    }),

    tuya.dp_numeric(118, { name = "equipment_status", read_only = true }),

    tuya.dp_numeric(119, {
      name = "target_distance",
      emit = emit.mtd085TargetDistance(),
      converter = converter.divide_by_pair(100),
      read_only = true,
    }),

    tuya.dp_enum(120, {
      name = "distance_report_mode",
      emit = emit.mtd085DistanceReportMode(),
      converter = distance_report_mode_mtd085_converter,
      command_id = tuya.SEND_DATA,
    }),

  },

  zcl_clusters = {
    zcl.occupancy({ ias_zone = true, read_only = true }),
  },

  query_on_configure = false,

}



register_device_definition(presence_model_mtd085_zb, {

  device_helpers.create_fingerprint("_TZ321C_fkzihax8", "TS0225"),

  device_helpers.create_fingerprint("_TZ321C_4slreunp", "TS0225"),

})

-- ══════════════════════════════════════════════════════════════

-- 2-23. presence_model_zp_301z: ZP-301Z (배터리 + 조도, 야간등 옵션)

-- Z2M: _TZE284_d4h8j2n6 / B3876M9

-- ══════════════════════════════════════════════════════════════

-- Z2M Arteco ZP-301Z (tuya.ts:25682)
-- DP1 presence trueFalse1, DP14 battery percentage, DP20 illuminance,
-- DP100 night-light brightness 5..100%, DP101 illuminance trigger 0..10000,
-- DP102 turn-on wait 0..60 s, DP103 turn-off delay 5..120 s, DP104 detection
-- cycle 10..1200 s step 5.  DP100 and DP101 were parsed but never exposed.
local presence_model_zp_301z = {

  profile = "safety-presence-zp301z-time-cycle-illuminance-battery",
  package_group = "presence-advanced",

  named_datapoints = true,

  datapoints = {

    tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),

    tuya.dp_battery(14, { emit = emit.battery() }),

    tuya.dp_illuminance(20, { emit = emit.illuminance() }),

    tuya.dp_numeric(100, { name = "brightness_value", emit = emit.zp301zBrightnessValue() }),

    tuya.dp_numeric(101, { name = "illuminance_trigger", emit = emit.zp301zIlluminanceTrigger() }),

    tuya.dp_numeric(102, { name = "presence_time", emit = emit.zp301zPresenceTime() }),

    tuya.dp_numeric(103, { name = "presence_delay", emit = emit.zp301zPresenceDelay() }),

    tuya.dp_numeric(104, { name = "detection_cycle", emit = emit.zp301zDetectionCycle() }),

  },

}



register_presence_definition(presence_model_zp_301z, {

  device_helpers.create_fingerprint("_TZE284_d4h8j2n6", "ZP-301Z"),

  device_helpers.create_fingerprint("B3876M9", "ZP-301Z"),

})

return {
  id = "ef00.presence.advanced",
  registrations = device_definitions,
}
