local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local entries = require "devices.ef00.motion.presence"

local converter = tuya.converter
local on_off_bool_converter = converter.lookup_from_to({
  on = true,
  off = false,
})

local include = {
  [1] = true,
  [2] = true,
  [3] = true,
  [4] = true,
  [5] = true,
  [6] = true,
  [7] = true,
  [8] = true,
  [9] = true,
  [10] = true,
  [11] = true,
  [12] = true,
  [13] = true,
  [14] = true,
  [15] = true,
  [16] = true,
  [17] = true,
  [18] = true,
  [19] = true,
  [20] = true,
  [21] = true,
  [22] = true,
  [23] = true,
  [24] = true,
  [25] = true,
  [26] = true,
  [45] = true,
  [46] = true,
  [47] = true,
  [48] = true,
  [49] = true,
  [50] = true,
  [51] = true,
  [52] = true,
  [53] = true,
  [54] = true,
}

local out = {}
for index, entry in ipairs(entries) do
  if entry.fingerprints then
    for _, fingerprint in ipairs(entry.fingerprints) do
      if fingerprint.manufacturer == "_TZE284_fwondbzy" and fingerprint.model == "TS0601" then
        entry.fingerprints[#entry.fingerprints + 1] = device_helpers.create_fingerprint("_TZE284_xpq2rzhq", "TS0601")
        break
      end
    end
  end

  if include[index] then
    out[#out + 1] = entry
  end
end

out[#out + 1] = {
  profile = "safety-presence-battery-zg204zk",
  datapoints = {
    tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
    tuya.dp_static_detection_sensitivity(2, {
      emit = emit.staticDetectionSensitivityZg204zx(),
    }),
    tuya.dp_static_detection_distance(4, {
      name = "detection_distance",
      emit = emit.presenceDetectionRangeZg204zx(),
    }),
    tuya.dp_fading_time(102, {
      emit = emit.presenceFadingTimeZg204zx(),
    }),
    tuya.dp_indicator(107, {
      emit = emit.indicatorZg204zx(),
      converter = on_off_bool_converter,
    }),
    tuya.dp_battery(121, { emit = emit.battery() }),
    tuya.dp_binary(122, {
      name = "anti_interference",
      emit = emit.antiInterferenceZg204zx(),
      converter = on_off_bool_converter,
    }),
    tuya.dp_motion_detection_sensitivity(123, {
      emit = emit.motionDetectionSensitivityZg204zx(),
    }),
  },
  query_on_configure = true,
  fingerprints = {
    device_helpers.create_fingerprint("AOYAN", "AY-204ZX"),
  },
}

return out
