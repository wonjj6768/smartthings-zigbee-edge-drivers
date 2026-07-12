# Devices Layout

`src/devices` is organized by role first, then protocol.

- `ef00/`
  Active Tuya EF00 device registrations loaded by `registry.lua`.
- `zcl/`
  Active Zigbee ZCL device registrations loaded by `registry.lua`.
- `hybrid/`
  Active mixed EF00 + ZCL device registrations.
  Use this when one device needs both `datapoints` and `zcl_clusters`.
- `shared/`
  Shared helpers used by device definition files.
- `examples/`
  Reference-only templates that are not loaded by `registry.lua`.

Recommended layout inside each protocol folder:

- `switches.lua`
- `sensors.lua`
- `plugs.lua`
- `covers.lua`
- `lights.lua`
- `thermostats.lua`

When adding a new real device:

1. Put EF00-only definitions in `ef00/`.
2. Put ZCL-only definitions in `zcl/`.
3. Put mixed definitions in `hybrid/`.
4. Put reusable helper code in `shared/`.
5. Put copy/paste templates in `examples/`.

## Deploy Boundaries

Source modules are now organized to match deploy package ownership as closely as possible.

- `ef00/covers.lua`
  Owned by the `ef00-covers` deploy package.
- `ef00/lights.lua`
  Owned by the `ef00-lights` deploy package.
- `ef00/switches.lua`, `ef00/din_rail.lua`
  Owned by the `ef00-switch` deploy package.
- `ef00/sensors.lua`
  Owned by the `ef00-sensors` deploy package.
  Keep environmental, soil, air-quality, illuminance, and pressure devices here.
- `ef00/safety.lua`
  Owned by the `ef00-safety` deploy package.
  Keep smoke, gas, CO, water leak, vibration, and all contact-family devices here.
- `ef00/motion/pir.lua`, `ef00/motion/presence.lua`
  Shared family definitions used by the split motion/presence packages.
- `ef00/motion_pir.lua`
  Owned by the `ef00-pir-motion` deploy package.
  Wrapper around `ef00/motion/pir.lua`.
- `ef00/presence_general.lua`, `ef00/presence_switch.lua`, `ef00/presence_advanced.lua`
  Owned by the split EF00 presence deploy packages.
  Wrappers around selected entries from `ef00/motion/presence.lua`.
  See `docs/ef00_motion_split.md`.

Rule of thumb:

1. If a device has `contact` as a primary capability, put it in `ef00/safety.lua`.
2. Do not share one EF00 source file across deploy packages unless there is no other choice.
3. Prefer moving the source entry to the correct package-owned module over fixing it later in `build_dist.py`.
4. EF00 motion/presence split packages use wrapper modules plus `include_device_files` for their shared family definitions.

## Runtime vs Publish Responsibilities

There are now three explicit layers for device composition.

- `ef00/modules.lua`, `zcl/modules.lua`
  Runtime composition only.
  These files answer: "what does the driver load when it starts?"
- `package_manifest.json`
  Publish composition only.
  This file answers: "which modules belong to which deploy package?"
- `tools/build_dist.py`
  Assembly only.
  This script should not be the source of truth for package boundaries anymore.
  It reads `package_manifest.json`, copies the requested modules, trims shared code, and generates deploy outputs.

Rule of thumb:

1. If runtime load order changes, update `modules.lua`.
2. If deploy package ownership changes, update `package_manifest.json`.
3. Do not hard-code package ownership inside `build_dist.py` unless the manifest format itself changes.

## File Responsibilities

- `src/devices/shared/module_loader.lua`
  Tiny runtime helper that merges module lists into one registry payload.
- `src/core/custom_capabilities.lua`
  Shared custom capability metadata.
  Keep capability IDs, labels, command names, mapping names, fallback ranges,
  and supported enum values here so `emitters.lua` and `app/driver.lua` stay aligned.
- `src/devices/<protocol>/modules.lua`
  Ordered runtime module list for that protocol.
- `src/devices/<protocol>/*.lua`
  Actual device-family definitions only.
  Keep helpers out unless they are truly local to that file.
- `source/package_manifest.json`
  Deploy package ownership, names, descriptions, generic fingerprint IDs.
- `source/tools/build_dist.py`
  Reads the manifest, builds deploy outputs, validates package/module references and fingerprint consistency, and enforces raw size limits.

Explicit fingerprint source of truth:

1. Register the pair and profile in `source/fingerprints.yml`; SmartThings matches devices from this file.
2. Connect the same pair to its handler in `source/src/devices/**/*.lua`.
3. Do not edit `deploy/**/fingerprints.yml`; run `python source/tools/build_dist.py` to generate it.
4. Run `python source/tools/build_dist.py --check` for a non-mutating source/runtime consistency check.

Mixed-device rule of thumb:

1. If the primary state/control path is EF00 and only metering or battery comes from ZCL, keep it in `hybrid/`.
2. If all control and reports are standard ZCL, keep it in `zcl/`.
3. If everything is Tuya DP/EF00, keep it in `ef00/`.

## Scene / Action-Centric Variants

These devices are usually not blocked by missing basic state parsing.
They are blocked because the main user value is button/action events rather than a stable state attribute.

- Examples in Zigbee2MQTT:
  `TS004F` smart knob/remotes, some `TS0041/TS0042/TS0043` remotes, and action-heavy contact/motion variants.
- Why they are different:
  they often emit cluster commands, multi-tap sequences, rotate events, hold/release, or mode-dependent events.
- Why they are easy to half-port incorrectly:
  battery may work, and sometimes a fallback state attribute exists, but the important feature is still the action stream.
- What is usually required before porting:
  `button` or custom action capability mapping, command/event parsing, operation-mode handling, and duplicate/debounce policy.
- Good rule:
  if the Z2M expose list is centered on `action`, treat it as an event device first and a sensor second.

## Option / Setting-Heavy Devices

These are devices where core state may be easy, but users still consider the port incomplete unless settings are exposed.

- Presence/radar sensors:
  sensitivity, minimum/maximum range, detection delay, fading time, self-test, target distance.
- Dimmers and light controllers:
  power-on behavior, minimum brightness, switch type, indicator behavior, do-not-disturb.
- Plugs/relays/meters:
  indicator mode, power restore state, child lock, calibration, reporting interval, polling expectations.
- Thermostat / valve / HVAC variants:
  calibration, deadband, child lock, preset/program modes, sensor source selection.

Good porting rule for these devices:

1. If the device still makes sense with just the core capabilities, port it now and document the missing options.
2. If the main selling point is the option set itself, hold it until the option path exists.
3. If Z2M exposes more settings than states, assume the settings are part of the device identity, not just extras.

## Metering Notes

ZCL metering devices in this driver now support two layers:

- Standard multiplier/divisor scaler reads for `SimpleMetering` and `ElectricalMeasurement`
- Optional polling reinforcement via per-mapping `poll_interval`

Use static `scale` only as a fallback when the device does not provide usable scaler attributes.
If a device has reliable `Multiplier/Divisor` or `AC*Multiplier/Divisor` attributes, prefer those over hard-coded scale guesses.
