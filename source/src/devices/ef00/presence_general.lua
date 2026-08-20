local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local entries = require "devices.ef00.motion.presence"

local converter = tuya.converter
local on_off_bool_converter = converter.lookup_from_to({
  on = true,
  off = false,
})

local function copy_entry(entry)
  local copied = {}
  for key, value in pairs(entry) do
    copied[key] = value
  end

  if type(entry.fingerprints) == "table" then
    copied.fingerprints = {}
    for index, fingerprint in ipairs(entry.fingerprints) do
      copied.fingerprints[index] = fingerprint
    end
  end

  return copied
end

local out = {}
for _, source_entry in ipairs(entries) do
  if source_entry.package_group == nil or source_entry.package_group == "presence-general" then
    local entry = copy_entry(source_entry)
    if entry.fingerprints then
      for _, fingerprint in ipairs(entry.fingerprints) do
        if fingerprint.manufacturer == "_TZE284_fwondbzy" and fingerprint.model == "TS0601" then
          entry.fingerprints[#entry.fingerprints + 1] = device_helpers.create_fingerprint("_TZE284_xpq2rzhq", "TS0601")
          break
        end
      end
    end
    out[#out + 1] = entry
  end
end

out[#out + 1] = {
  -- Z2M lists AOYAN AY-204ZX as a ZG-204ZK whiteLabel (tuya.ts:24744), so it
  -- shares that model's datapoint contract and fixed capability ranges.
  profile = "safety-presence-zg204zk-battery",
  datapoints = {
    tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
    tuya.dp_static_detection_sensitivity(2, {
      emit = emit.zg204zkStaticSensitivity(),
    }),
    tuya.dp_static_detection_distance(4, {
      name = "detection_distance",
      emit = emit.zg204zkDetectionDistance(),
    }),
    tuya.dp_fading_time(102, {
      emit = emit.zg204zkFadingTime(),
    }),
    tuya.dp_indicator(107, {
      emit = emit.zg204zkIndicator(),
      converter = on_off_bool_converter,
    }),
    tuya.dp_battery(121, { emit = emit.battery() }),
    tuya.dp_binary(122, {
      name = "anti_interference",
      emit = emit.zg204zkAntiInterference(),
      converter = on_off_bool_converter,
    }),
    tuya.dp_motion_detection_sensitivity(123, {
      emit = emit.zg204zkMotionSensitivity(),
    }),
  },
  query_on_configure = true,
  fingerprints = {
    device_helpers.create_fingerprint("AOYAN", "AY-204ZX"),
  },
}

-- Z2M matches ZG-204ZQ through `zigbeeModel: ["ZG-204ZQ"]` (tuya.ts:25740), which
-- is a model-only rule with no manufacturer.  This project only accepts explicit
-- manufacturer + model pairs, and `HOBEIAN / ZG-204ZQ` was a guess at the raw
-- interview values rather than an observed pair, so it is no longer registered.
-- The supported exact is `_TZE200_p9zbdqgs / TS0601`.

return out
