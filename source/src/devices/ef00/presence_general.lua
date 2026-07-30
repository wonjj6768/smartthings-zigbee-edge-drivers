local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local entries = require "devices.ef00.motion.presence"

local converter = tuya.converter
local on_off_bool_converter = converter.lookup_from_to({
  on = true,
  off = false,
})

-- Index ranges are brittle: splitting a family in presence.lua shifts every
-- later entry.  The general package owns the registrations up to the ZG-302ZM
-- presence switch plus the standalone radar block near the end of the file, so
-- the boundaries are expressed as profile names and resolved below.
local INCLUDED_HEAD_LAST_PROFILE = "safety-presence-gnpflcoq-illuminance-temp-humidity-battery"
local INCLUDED_TAIL_FIRST_PROFILE = "safety-motion-tamper-battery"

local function entry_profile(entry)
  local definition = entry.definition or entry
  return definition.profile
end

local head_last_index, tail_first_index
for index, entry in ipairs(entries) do
  local profile = entry_profile(entry)
  if profile == INCLUDED_HEAD_LAST_PROFILE then
    head_last_index = math.max(head_last_index or 0, index)
  end
  if profile == INCLUDED_TAIL_FIRST_PROFILE and tail_first_index == nil then
    tail_first_index = index
  end
end
assert(head_last_index ~= nil, "presence_general: head boundary profile not found")
assert(tail_first_index ~= nil, "presence_general: tail boundary profile not found")

local include = {}
for index = 1, head_last_index do
  include[index] = true
end
for index = tail_first_index, #entries do
  include[index] = true
end

local out = {}
local zg204zq_entry = nil
for index, entry in ipairs(entries) do
  if entry.fingerprints then
    for _, fingerprint in ipairs(entry.fingerprints) do
      if fingerprint.manufacturer == "_TZE284_fwondbzy" and fingerprint.model == "TS0601" then
        entry.fingerprints[#entry.fingerprints + 1] = device_helpers.create_fingerprint("_TZE284_xpq2rzhq", "TS0601")
      elseif fingerprint.manufacturer == "_TZE200_p9zbdqgs" and fingerprint.model == "TS0601" then
        zg204zq_entry = entry
      end
    end
  end

  if include[index] then
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
