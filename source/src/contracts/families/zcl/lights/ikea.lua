local zcl = require "protocol.zcl"
local device_helpers = require "contracts.helpers.family"

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

register_device_definition(dimmer_light, {
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 opal 1000lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 W opal 1000lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WW globe 800lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WW globe 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WW globe 810lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WW globe 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE26WWglobeclear250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WW G95 CL 470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WW G95 CL 450lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WW G95 CL 440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WW G95 CL 470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WW clear 250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WW clear 250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE27WWclear250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE26WWclear250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 opal 1000lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 W opal 1000lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WW 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WW 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 W op/ch 400lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 W op/ch 400lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E17 W op/ch 400lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE14WWclear250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE12WWclear250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE17WWclear250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE12WWcandleclear250lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 WW 345lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 WW 380lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 W 400lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 WW 400lm"),
})

register_device_definition(cct_light, {
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WS opal 980lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WS opal 980lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WS�opal 980lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WS clear 950lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WS clear 950lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WS�clear 950lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbG125E27WSopal470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbG125E26WSopal450lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbG125E26WSopal470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbG125E26WSopal440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE27WSglobeopal1055lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE26WSglobeopal1100lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE26WSglobeopal1160lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE26WSglobeopal1055lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE26WSglobeclear800lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE27WSglobeclear806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE26WSglobeclear806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE26WSglobeclear810lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 opal 470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 W opal 470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbT120E27WSopal470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbT120E26WSopal450lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbT120E26WSopal470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WS opal 440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbT120E26WSopal440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WS opal 1000lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WS opal 1000lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WS clear 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WS clear 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 WS globe 1055lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WS globe 1055lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WS globe 1100lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 WS globe 1160lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbPAR38WS900lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbB22WSglobeopal1055lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 WS candle 470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 WS candle 450lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 WS opal 400lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 WS opal 400lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 WS 470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 WS 450lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E17 WS 440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E17 WS candle 440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 WS globe 470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 WS globe 450lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 WS opal 600lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE14WSglobeopal470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE12WSglobeopal470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E17 WS globe 440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE17WSglobeopal470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 WS opal 600lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E17 WS opal 600lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE14WScandleopal470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE12WScandleopal450lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbE17WScandleopal440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 WS 400lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI_bulb_GU10_WS_345lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbGU10WS345lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 WS 345lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRIbulbGU10WS380lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 WS 380lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "LEPTITER Recessed spot light"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JETSTROM 40100"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JETSTROM 40100 NA"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JETSTROM 6060"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JETSTROM 6060 JP"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JETSTROM 6060 NA"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JORMLIEN door WS 40x80"),
  device_helpers.create_fingerprint("IKEA of Sweden", "FLOALT panel WS 30x30"),
  device_helpers.create_fingerprint("IKEA of Sweden", "FLOALT panel WS 60x60"),
  device_helpers.create_fingerprint("IKEA of Sweden", "FLOALT panel WS 30x90"),
  device_helpers.create_fingerprint("IKEA of Sweden", "SURTE door WS 38x64"),
  device_helpers.create_fingerprint("IKEA of Sweden", "GUNNARP panel round"),
  device_helpers.create_fingerprint("IKEA of Sweden", "GUNNARP panel 40*40"),
})

register_device_definition(color_cct_light, {
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 CWS globe 800lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 CWS globe 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 CWS globe 810lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 CWS globe 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 CWS 800lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 CWS 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 CWS 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 CWS 810lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 CWS 470lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 CWS 450lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E17 CWS 440lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 CWS globe 806lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 CWS globe 800lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E17 CWS globe 810lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 CWS 380lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb GU10 CWS 345lm"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JETSTROM 3030 wall"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JETSTROM 3030 NA wall"),
  device_helpers.create_fingerprint("IKEA of Sweden", "JETSTROM 3030 ceiling"),
})

do
  -- ZHC cff1de47 LED1624G9: XY color, including mired-to-XY CCT.
  local emit = require "capabilities.events.all"
  local capabilities = require "st.capabilities"
  local clusters = require "st.zigbee.zcl.clusters"
  local types = require "st.zigbee.data_types"
  local cluster_base = require "st.zigbee.cluster_base"
  local ReadAttribute = require "st.zigbee.zcl.global_commands.read_attribute"
  local color = require "contracts.helpers.ikea1624_color"

  local prefix = "ikea1624:"
  local transient, persistent = {persist = false}, {persist = true}
  local event = {
    switch = emit.switch(), level = emit.level(), hue = emit.color_hue(),
    saturation = emit.color_saturation(), kelvin = emit.color_temperature(),
    mired = emit.ikea1624ColorMired(), power_on = emit.ikea1624PowerOn(),
    level_off = emit.ikea1624LevelOff(), start_level = emit.ikea1624StartLevel(),
    color_off = emit.ikea1624ColorOff(),
    xy = function(_, value)
      return capabilities["concertmirror08464.ikea1624XyColor"].colorXy(value)
    end,
  }
  local power_on = {off = 0, on = 1, toggle = 2, previous = 255}
  local power_on_name = {[0] = "off", [1] = "on", [2] = "toggle", [255] = "previous"}
  local effects = {blink = 0, breathe = 1, okay = 2, channel_change = 11, finish_effect = 254, stop_effect = 255}

  local function valid(value, minimum, maximum, integer)
    return color.finite(value) and value >= minimum and value <= maximum and (not integer or value % 1 == 0)
  end

  local function send(device, request)
    return device:send(request:to_endpoint(1)) ~= false
  end

  local function read(device, cluster, attributes)
    local request = cluster_base.read_attribute(device, types.ClusterId(cluster), types.AttributeId(attributes[1]))
    local ids = {}
    for _, id in ipairs(attributes) do ids[#ids + 1] = types.AttributeId(id) end
    request.body.zcl_body = ReadAttribute.ReadAttribute(ids)
    return send(device, request)
  end

  local function read_color(device)
    return read(device, 0x0300, {0x0008, 0x0003, 0x0004})
  end

  local function later(device, delay, callback, label)
    device.thread:call_with_delay(delay, callback, label)
  end

  local function publish(device, name, value)
    if value == nil then return end
    local output = event[name](device, value)
    if output ~= nil then device:emit_event(output) end
  end

  local function transition(device)
    local value = device.preferences and device.preferences.ikea1624TransitionTenths
    if value == nil then return 0, false end
    if not valid(value, 0, 65535, true) then return nil end
    return value, true
  end

  -- Native clock is loaded only when an option-bearing converter needs it.
  -- Effects/Identify/settings and the unfreeze_support=false path do not call it.
  local function wrapped(device, color_change, tenths, unfreezes, action)
    local enabled = not (device.preferences and device.preferences.ikea1624Unfreeze == false)
    if enabled then
      local now = require("cosock.socket").gettime() * 1000
      local until_time = device:get_field(prefix .. "frozen_until")
      if until_time ~= nil and now <= until_time and not unfreezes then
        send(device, clusters.Level.server.commands.Stop(device, 0, 0))
      end
    end
    local function finish(ok)
      if ok and enabled then
        local next_until
        if color_change and tenths > 0 then
          next_until = require("cosock.socket").gettime() * 1000 + tenths * 100
        end
        device:set_field(prefix .. "frozen_until", next_until, transient)
      end
      return ok
    end
    local ok, waiting = action(finish)
    if waiting then return true end
    return finish(ok)
  end

  -- Basic SWBuildID is a short CharString (not an SDK firmware metadata field).
  -- Match loose numeric triples, optional v/=, prerelease and ignored build ids.
  -- The threshold has no prerelease: equality never satisfies strictly-greater.
  local function firmware_after_fix(value)
    if type(value) ~= "string" then return false end
    local major, minor, patch, tail = value:match("^[v=%s]*(%d+)%.(%d+)%.(%d+)(.-)%s*$")
    if major == nil then return false end
    major, minor, patch = tonumber(major), tonumber(minor), tonumber(patch)
    if major > 9007199254740991 or minor > 9007199254740991 or patch > 9007199254740991 then return false end
    local prerelease, build = tail:match("^(.-)%+(.+)$")
    if tail:find("+", 1, true) and build == nil then return false end
    prerelease = prerelease or tail
    local function identifiers(text)
      return text ~= "" and not text:find("[^A-Za-z0-9%.%-]") and
        text:sub(1, 1) ~= "." and text:sub(-1) ~= "." and not text:find("..", 1, true)
    end
    if build ~= nil and not identifiers(build) then return false end
    if prerelease ~= "" then
      if #prerelease > 1 and prerelease:sub(1, 1) == "-" then prerelease = prerelease:sub(2) end
      if not identifiers(prerelease) then return false end
    end
    if major ~= 1 then return major > 1 end
    if minor ~= 0 then return minor > 0 end
    return patch > 12
  end

  -- Hold later family operations while a native OnLevel read is outstanding.
  -- This also keeps settings/refresh read responses from being mistaken for an
  -- OnLevel response missing its requested attribute. SDK dispatch is untouched.
  local function serial(device, action)
    local pending = device:get_field(prefix .. "on_level_pending")
    if pending ~= nil then
      pending.queue[#pending.queue + 1] = action
      return true
    end
    return action()
  end

  local function resume_on_level(device, value, failed)
    local pending = device:get_field(prefix .. "on_level_pending")
    if pending == nil then return end
    if pending.timer ~= nil then
      device.thread:cancel_timer(pending.timer)
      pending.timer = nil
    end
    device:set_field(prefix .. "on_level_pending", nil, transient)
    if failed or value == 0 then
      device:set_field(prefix .. "on_level_supported", false, persistent)
      value = 255
    end
    -- A successful response with no OnLevel produces undefined in primary;
    -- that takes native On, rather than marking unsupported or inventing 254.
    local ok = pending.send(value)
    pending.finish(ok)
    if ok and pending.after ~= nil then pending.after() end
    for index, action in ipairs(pending.queue) do
      action()
      local next_pending = device:get_field(prefix .. "on_level_pending")
      if next_pending ~= nil then
        for rest = index + 1, #pending.queue do next_pending.queue[#next_pending.queue + 1] = pending.queue[rest] end
        break
      end
    end
  end

  -- E17 meta: turnsOffAtBrightness1=false, moveToLevelWithOnOffDisable=false,
  -- optional Level parameters are present. Remaining branch choices are primary.
  local function light_command(device, message, tenths, specified, after)
    local state, brightness = message.state, message.brightness
    if state == nil then state = brightness == 0 and "off" or "on" end
    local target = state
    if state == "toggle" then target = device:get_field(prefix .. "switch") == true and "off" or "on" end
    if target == "off" then
      brightness = (specified or brightness == 0) and 0 or nil
      if brightness ~= nil and device:get_field(prefix .. "switch") == false and
          firmware_after_fix(device:get_field(prefix .. "sw_build_id")) then brightness = nil end
      local current = device:get_field(prefix .. "raw_level")
      if current ~= nil and device:get_field(prefix .. "switch") == true then
        -- Primary software store: captured BEFORE fade/reporting can clobber RX.
        device:set_field(prefix .. "stored_brightness", current, transient)
        device:set_field(prefix .. "turned_off_with_transition", brightness ~= nil, transient)
      end
    end
    local function send_level_or_state(level)
      if level == 255 and target == "on" then
        level = device:get_field(prefix .. "stored_brightness")
        if level == nil then level = device:get_field(prefix .. "raw_level") end
        if level == nil then level = 254 end -- primary's explicit previous fallback
      end
      if level == nil then
        if state == "on" and message.on_time ~= nil then
          return send(device, clusters.OnOff.server.commands.OnWithTimedOff(device, 0, message.on_time, message.off_wait_time))
        end
        local command = state == "toggle" and clusters.OnOff.server.commands.Toggle or
          (state == "off" and clusters.OnOff.server.commands.Off or clusters.OnOff.server.commands.On)
        return send(device, command(device))
      end
      if not valid(level, 0, 255, true) then return false end
      if level == 0 and (target == "on" or state == false) then level = 1 end
      if target ~= "off" then
        device:set_field(prefix .. "stored_brightness", level, transient)
        device:set_field(prefix .. "turned_off_with_transition", nil, transient)
      end
      local command = state == false and clusters.Level.server.commands.MoveToLevel or clusters.Level.server.commands.MoveToLevelWithOnOff
      return send(device, command(device, level, tenths, 0, 0))
    end
    return wrapped(device, false, tenths, false, function(finish)
      if target == "on" and brightness == nil and
          (specified or device:get_field(prefix .. "turned_off_with_transition") == true) then
        local on_level = device:get_field(prefix .. "on_level") or 0
        if on_level == 0 and device:get_field(prefix .. "on_level_supported") ~= false then
          local pending = {send = send_level_or_state, finish = finish, after = after, queue = {}}
          device:set_field(prefix .. "on_level_pending", pending, transient)
          -- Herdsman11.1.0 read(): response enabled, default timeout10000ms.
          -- Cancellation cannot retract an already queued callback; identity also
          -- protects a newer request from an old timeout running late.
          pending.timer = device.thread:call_with_delay(10, function()
            if device:get_field(prefix .. "on_level_pending") == pending then
              pending.timer = nil
              resume_on_level(device, nil, true)
            end
          end, "LED1624 OnLevel read timeout")
          if pending.timer == nil then
            resume_on_level(device, nil, true)
            return nil, true
          end
          local ok, sent = pcall(read, device, 8, {0x0011})
          if not ok or not sent then resume_on_level(device, nil, true) end
          return nil, true
        end
        if on_level == 0 then
          device:set_field(prefix .. "on_level_supported", false, persistent)
          on_level = 255
        end
        brightness = on_level
      end
      local ok = send_level_or_state(brightness)
      if ok and after ~= nil then
        -- Complete this transition BEFORE an attached color command starts one.
        finish(ok)
        after()
        return nil, true
      end
      return ok
    end)
  end

  local function set_switch(device, _, value)
    if type(value) ~= "boolean" then return false end
    local tenths, specified = transition(device)
    if tenths == nil then return false end
    return light_command(device, {state = value and "on" or "off"}, tenths, specified)
  end

  local function set_level(device, mapping, value, command_context)
    local tenths, specified = transition(device)
    -- The actual SDK setLevel default puts rate directly in the U16 field.
    -- Use the existing family protocol_writer to retain this optional argument.
    local rate = command_context and command_context.args and command_context.args.rate
    if rate ~= nil then
      if not valid(rate, 0, 65535, true) then return false end
      tenths, specified = rate, true
    end
    if tenths == nil then return false end
    local raw
    if mapping.name == "brightness" then
      if not valid(value, 0, 100) then return false end
      raw = color.round(value * 254 / 100)
    elseif mapping.name == "ikea1624_brightness_percent" then
      if not valid(value, 0, 100) then return false end
      raw = math.min(254, color.round(value * 255 / 100))
    else
      if not valid(value, 0, 255, true) then return false end
      raw = math.min(value, 254)
    end
    local state
    if mapping.name == "ikea1624_brightness_keep_power" then state = false end
    return light_command(device, {brightness = raw, state = state}, tenths, specified)
  end

  local function set_color(device, mapping, value)
    local tenths = transition(device)
    if tenths == nil then return false end
    local name, x, y, mired = mapping.name
    local projected = device:get_field(prefix .. "hs_projection") or {}
    local hue, saturation
    local level, switch
    if name == "color" then
      if type(value) ~= "table" then return false end
      if value.level ~= nil then
        if not valid(value.level, 0, 100, true) then return false end
        level = color.round(value.level * 254 / 100)
      end
      if value.switch ~= nil then
        if type(value.switch) ~= "string" then return false end
        switch = value.switch:lower()
        if switch ~= "on" and switch ~= "off" then return false end
      end
      if value.hue == nil and value.saturation == nil and value.hex == nil then
        if level == nil and switch == nil then return false end
        local _, specified = transition(device)
        return light_command(device, {state = switch, brightness = level}, tenths, specified)
      end
    end
    if name == "color_temperature" or name == "ikea1624_color_mired" then
      if name == "color_temperature" then
        if not valid(value, 2000, 6536, true) then return false end
        mired = math.max(153, math.min(500, 1000000 / value))
      else
        if not valid(value, 153, 500) then return false end
        mired = value
      end
      x, y = color.mired_xy(mired)
    elseif name == "ikea1624_color_xy" then
      if type(value) ~= "table" or not valid(value.x, 0, 1) or not valid(value.y, 0, 1) then return false end
      for key in pairs(value) do
        if key ~= "x" and key ~= "y" then return false end
      end
      x, y = value.x, value.y
    elseif name == "ikea1624_color_rgb" then
      if type(value) ~= "table" or not valid(value.red, 0, 1) or not valid(value.green, 0, 1) or not valid(value.blue, 0, 1) then return false end
      x, y = color.rgb_xy(value.red, value.green, value.blue, true)
    elseif name == "color" and value.hex ~= nil then
      -- Primary Color.fromConverterArg gives hex priority over HSV fields.
      if type(value.hex) ~= "string" then return false end
      local hex = value.hex:gsub("^#", "")
      if #hex ~= 6 or hex:find("[^0-9a-fA-F]") then return false end
      local rgb = tonumber(hex, 16)
      x, y = color.rgb_xy(math.floor(rgb / 65536) / 255,
        math.floor(rgb / 256) % 256 / 255, rgb % 256 / 255, true)
    else
      if name == "color_hue" then
        if not valid(value, 0, 100) then return false end
        hue, saturation = value, projected.saturation
      elseif name == "color_saturation" then
        if not valid(value, 0, 100) then return false end
        hue, saturation = projected.hue, value
      elseif type(value) == "table" then
        hue, saturation = value.hue, value.saturation
        if hue == nil and saturation == nil then return false end
      else return false end
      -- Missing components default for encoding only. No optimistic companion event.
      hue, saturation = hue == nil and 0 or hue, saturation == nil and 100 or saturation
      if not valid(hue, 0, 100) or not valid(saturation, 0, 100) then return false end
      x, y = color.hsv_xy(hue * 3.6, saturation)
    end
    if x == nil then return false end
    local function send_color()
      local ok = wrapped(device, true, tenths, false, function()
        return send(device, clusters.ColorControl.server.commands.MoveToColor(
          device, color.round(x * 65535), color.round(y * 65535), tenths, 0, 0))
      end)
      if ok then
        if mired ~= nil then device:set_field(prefix .. "mired_target", true, transient) end
        later(device, math.max(2, tenths / 10), function() read_color(device) end, "LED1624 color readback")
      end
      return ok
    end
    if level ~= nil or switch ~= nil then
      -- One explicit ColorMap composite: primary IKEA brightness transition=0,
      -- specified=false; color retains its transition. No merging separate calls.
      return light_command(device, {state = switch, brightness = level}, 0, false, send_color)
    end
    return send_color()
  end

  local function effect(device, _, value)
    local explicit_transition
    if type(value) == "table" then
      explicit_transition, value = value.transition, value.effect
    end
    if type(value) ~= "string" then return false end
    if effects[value] ~= nil then
      return send(device, clusters.Identify.server.commands.TriggerEffect(device, effects[value], 0))
    end
    if value == "colorloop" then
      local seconds = explicit_transition
      if seconds == nil then
        seconds = (device.preferences and device.preferences.ikea1624LoopTenths or 150) / 10
      end
      if not color.finite(seconds) or seconds < 0 then return false end
      local rate = seconds == 0 and 255 or math.min(255, math.max(1, color.round(255 / seconds)))
      return send(device, clusters.ColorControl.server.commands.MoveHue(device, 1, rate, 0, 0))
    elseif value == "stop_colorloop" then
      if not send(device, clusters.ColorControl.server.commands.MoveHue(device, 0, 1, 0, 0)) then return false end
      later(device, 0.1, function() read(device, 0x0300, {0, 8}) end, "E17 loop stop readback")
      return true
    end
    return false
  end

  local function identify(device, _, value)
    if not valid(value, 1, 30, true) then return false end
    return send(device, clusters.Identify.server.commands.Identify(device, value))
  end

  local function toggle(device)
    local tenths, specified = transition(device)
    if tenths == nil then return false end
    return light_command(device, {state = "toggle"}, tenths, specified)
  end

  local settings = {
    ikea1624_power_on = {0x0006, 0x4003, types.Enum8, power_on},
    ikea1624_level_off = {0x0008, 0x000F, types.Bitmap8, {disabled = 0, enabled = 1}},
    ikea1624_start_level = {0x0008, 0x4000, types.Uint8},
    ikea1624_color_off = {0x0300, 0x000F, types.Bitmap8, {disabled = 0, enabled = 1}},
  }
  local function set_setting(device, mapping, value)
    local setting = settings[mapping.name]
    local encoded
    if setting[4] ~= nil then encoded = setting[4][value]
    elseif valid(value, 0, 255, true) then encoded = value end
    if encoded == nil then return false end
    if not send(device, cluster_base.write_attribute(device, types.ClusterId(setting[1]), types.AttributeId(setting[2]), setting[3](encoded))) then return false end
    -- A sent WriteAttribute is not acknowledgment or confirmed device state.
    return read(device, setting[1], {setting[2]})
  end

  -- Converter-only routes; no custom UI, no claim of native color motion support.
  local function level_motion(device, mapping, value)
    local is_step = mapping.name:find("step", 1, true) ~= nil
    local onoff = mapping.name:find("onoff", 1, true) ~= nil
    local tenths = transition(device)
    if tenths == nil then return false end
    if not is_step and (value == "stop" or value == 0) then
      -- light_brightness_move has no orig.options, so no freeze wrapper.
      send(device, clusters.Level.server.commands.Stop(device, 0, 0))
      later(device, 0.5, function()
        serial(device, function() read(device, 6, {0}); return read(device, 8, {0}) end)
      end, "E17 level stop readback")
      return true
    end
    if not valid(value, -255, 255, true) then return false end
    local mode = value > 0 and 0 or 1
    if is_step then
      return wrapped(device, false, tenths, true, function()
        local command = onoff and clusters.Level.server.commands.StepWithOnOff or clusters.Level.server.commands.Step
        return send(device, command(device, mode, math.abs(value), tenths, 0, 0))
      end)
    end
    local command = onoff and clusters.Level.server.commands.MoveWithOnOff or clusters.Level.server.commands.Move
    return send(device, command(device, mode, math.abs(value), 0, 0))
  end

  local function timed_on(device, _, value)
    if type(value) ~= "table" then return false end
    local on_time = value.on_time == nil and 0 or value.on_time
    local off_wait = value.off_wait_time == nil and 0 or value.off_wait_time
    if not color.finite(on_time) or not color.finite(off_wait) then return false end
    on_time, off_wait = color.round(on_time * 10), color.round(off_wait * 10)
    if not valid(on_time, 0, 65534, true) or not valid(off_wait, 0, 65534, true) then return false end
    local tenths, specified = transition(device)
    if tenths == nil then return false end
    return light_command(device, {state = "on", on_time = on_time, off_wait_time = off_wait}, tenths, specified)
  end

  local function save(device, name, value)
    device:set_field(prefix .. name, value, persistent)
  end

  -- Main integration slot: preset.zigbee_message_handler(device, zb_rx).
  -- Runs before unchanged SDK dispatch. Keep this L3 callback separate from L2
  -- capture_reporting; main composes both functions in the same opt-in slot.
  local reporting_types = {
    [0x0006] = {[0] = types.Boolean, [0x4003] = types.Enum8},
    [0x0008] = {[0] = types.Uint8, [0x000F] = types.Bitmap8, [0x0011] = types.Uint8, [0x4000] = types.Uint8},
    [0x0300] = {[0] = types.Uint8, [1] = types.Uint8, [3] = types.Uint16, [4] = types.Uint16,
      [7] = types.Uint16, [8] = types.Enum8, [0x000F] = types.Bitmap8},
  }

  local function capture_reporting(device, rx)
    local header = rx.body.zcl_header
    if header == nil or header.frame_ctrl:is_cluster_specific_set() or header.frame_ctrl:is_mfg_specific_set()
        or not header.frame_ctrl:is_direction_set()
        or header.cmd.value ~= 9 or rx.address_header.src_endpoint.value ~= 1 then return end
    local cluster = rx.address_header.cluster.value
    local attributes = reporting_types[cluster]
    if attributes == nil then return end
    local stored = device:get_field(prefix .. "reporting") or {}
    local changed = false
    for _, record in ipairs(rx.body.zcl_body.read_reporting_records) do
      if record.status.value == 0 and record.direction.value == 0 then
        local id = record.attr_id.value
        local data_type = attributes[id]
        if data_type and data_type.ID == record.data_type.value then
          stored[string.format("%04x:%04x", cluster, id)] = {cluster, id,
            record.minimum_reporting_interval.value, record.maximum_reporting_interval.value,
            record.reportable_change and record.reportable_change.value}
          changed = true
        end
      end
    end
    if changed then device:set_field(prefix .. "reporting", stored, persistent) end
  end

  local function replay_reporting(device)
    local management = require "st.zigbee.device_management"
    local records = {}
    -- Previously acknowledged shared controls used these five generic defaults.
    for _, old in ipairs({{6, 0, 0, 300}, {8, 0, 1, 3600, 1},
        {0x0300, 0, 1, 300, 1}, {0x0300, 1, 1, 300, 1}, {0x0300, 7, 1, 300, 1}}) do
      local saved = device:get_field(string.format("zcl_reporting:zr%04x%04xauto", old[1], old[2]))
      if saved then
        local change = saved.reportable_change
        if change == nil then change = old[5] end
        local maximum = saved.maximum_interval or old[4]
        if maximum == 65535 and change ~= nil then change = 0 end
        records[string.format("%04x:%04x", old[1], old[2])] = {old[1], old[2],
          saved.minimum_interval or old[3], maximum, change}
      end
    end
    for key, record in pairs(device:get_field(prefix .. "reporting") or {}) do records[key] = record end
    local keys = {}
    for key in pairs(records) do keys[#keys + 1] = key end
    table.sort(keys)
    for _, key in ipairs(keys) do
      local record = records[key]
      local data_type = reporting_types[record[1]][record[2]]
      send(device, management.attr_config(device, {cluster = record[1], attribute = record[2], data_type = data_type,
        minimum_interval = record[3], maximum_interval = record[4],
        reportable_change = not data_type.is_discrete and data_type(record[5]) or nil}))
    end
  end

  local function read_response(device, rx)
    local header = rx.body and rx.body.zcl_header
    if header == nil or rx.address_header.src_endpoint.value ~= 1 or
        header.frame_ctrl:is_cluster_specific_set() or header.frame_ctrl:is_mfg_specific_set() or
        not header.frame_ctrl:is_direction_set() then return end
    local cmd, cluster, body = header.cmd.value, rx.address_header.cluster.value, rx.body.zcl_body
    if cmd ~= 1 and cmd ~= 11 then return end
    if cmd == 11 and (body.cmd.value ~= 0 or body.status.value == 0) then return end
    local function record_for(attribute)
      local selected
      if cmd == 1 then
        for _, record in ipairs(body.attr_records) do
          if record.attr_id.value == attribute then selected = record end
        end
      end
      return selected
    end
    if cluster == 0x0000 then
      local record = record_for(0x4000)
      if record and record.status.value == 0 and type(record.data.value) == "string" then
        save(device, "sw_build_id", record.data.value)
      end
    elseif cluster == 0x0300 and device:get_field(prefix .. "await_bounds") then
      local record = record_for(0x400A)
      if record == nil and cmd == 1 and #body.attr_records > 0 then return end
      device:set_field(prefix .. "await_bounds", false, transient)
      if record and record.status.value == 0 and valid(record.data.value, 0, 65535, true) then
        read(device, 0x0300, {0x400B, 0x400C})
      end
    elseif cluster == 8 and device:get_field(prefix .. "on_level_pending") ~= nil then
      if cmd == 11 then return resume_on_level(device, nil, true) end
      local record = record_for(0x0011)
      if record == nil then
        -- An in-flight Level read for other attributes cannot complete OnLevel.
        if #body.attr_records > 0 then return end
        return resume_on_level(device, nil, false)
      end
      if record.status.value ~= 0 then return resume_on_level(device, nil, true) end
      local value = record.data.value
      if valid(value, 0, 255, true) then
        save(device, "on_level", value) -- predispatch: do not wait for attr handler
        return resume_on_level(device, value, false)
      end
      return resume_on_level(device, false, false) -- malformed success: no TX
    end
  end

  local function receive(device, _, context)
    local rx = context.zb_rx
    if device:get_field(prefix .. "last_rx") == rx then return end
    device:set_field(prefix .. "last_rx", rx, transient)
    local cluster = context.cluster_id
    local values = {}
    -- Same attribute: last successful record, not SDK per-record callback order.
    -- Wrong data type with a numeric value is accepted only within its carrier.
    for _, record in ipairs(rx.body.zcl_body.attr_records) do
      if record.status == nil or record.status.value == 0 then
        local value = record.data and record.data.value
        if type(value) == "number" or type(value) == "boolean" or type(value) == "string" then
          values[record.attr_id.value] = value
        end
      end
    end
    if cluster == 0x0000 then
      if type(values[0x4000]) == "string" then save(device, "sw_build_id", values[0x4000]) end
    elseif cluster == 0x0006 then
      local value = values[0]
      if value == true or value == false or value == 0 or value == 1 then
        value = value == true or value == 1
        save(device, "switch", value)
        publish(device, "switch", value)
      end
      if power_on_name[values[0x4003]] then publish(device, "power_on", power_on_name[values[0x4003]]) end
    elseif cluster == 0x0008 then
      local raw = values[0]
      if valid(raw, 0, 255, true) then
        save(device, "raw_level", raw)
        publish(device, "level", math.min(100, color.round(raw * 100 / 254)))
      end
      if valid(values[0x000F], 0, 255, true) then
        local enabled = values[0x000F] % 2 == 1
        save(device, "level_off", enabled)
        publish(device, "level_off", enabled and "enabled" or "disabled")
      end
      if valid(values[0x4000], 0, 255, true) then publish(device, "start_level", values[0x4000]) end
      if valid(values[0x0011], 0, 255, true) then save(device, "on_level", values[0x0011]) end
    elseif cluster == 0x0300 then
      if valid(values[0x000F], 0, 255, true) then
        local enabled = values[0x000F] % 2 == 1
        save(device, "color_off", enabled)
        publish(device, "color_off", enabled and "enabled" or "disabled")
      end
      local old = device:get_field(prefix .. "color") or {color = {}}
      local new = {color = {}}
      for id, key in pairs({[3] = "x", [4] = "y"}) do
        if valid(values[id], 0, 65535, true) then new.color[key] = color.round(values[id] / 65535, 4) end
      end
      if valid(values[0], 0, 255, true) then new.color.hue = color.round(values[0] * 360 / 254) end
      if valid(values[1], 0, 255, true) then new.color.saturation = color.round(values[1] * 100 / 254) end
      if valid(values[8], 0, 255, true) then new.mode = values[8] end
      if valid(values[7], 0, 65535, true) then new.mired = values[7] end
      if next(new.color) == nil then new.color = nil end
      if valid(values[0x400B], 0, 65535, true) then old.physical_min = values[0x400B] end
      if valid(values[0x400C], 0, 65535, true) then old.physical_max = values[0x400C] end
      local enabled = not (device.preferences and device.preferences.ikea1624ColorSync == false)
      local synced = color.sync(new, old, enabled)
      local merged = {color = {}, physical_min = old.physical_min, physical_max = old.physical_max,
        mode = synced.mode or new.mode or old.mode, mired = old.mired}
      for key, value in pairs(old.color or {}) do merged.color[key] = value end
      for key, value in pairs(new.color or {}) do merged.color[key] = value end
      for key, value in pairs(synced.color or {}) do merged.color[key] = value end
      if new.mired ~= nil then merged.mired = new.mired end
      if synced.mired ~= nil then merged.mired = synced.mired end
      save(device, "color", merged)
      local output = synced.color or new.color or {}
      if output.x ~= nil and output.y ~= nil then
        -- Existing emit.value passes this structured attribute payload unchanged.
        publish(device, "xy", {value = {x = output.x, y = output.y}})
      end
      -- Projection to the ST HSV surface does not create primary HS/CCT targets.
      local hue, saturation = output.hue, output.saturation
      if enabled and hue == nil and output.x ~= nil and output.y ~= nil then hue, saturation = color.xy_hs(output.x, output.y) end
      if hue ~= nil or saturation ~= nil then
        local projected = device:get_field(prefix .. "hs_projection") or {}
        if color.finite(hue) then projected.hue = hue / 3.6; publish(device, "hue", projected.hue) end
        if color.finite(saturation) then projected.saturation = saturation; publish(device, "saturation", saturation) end
        save(device, "hs_projection", projected)
      end
      local mired = synced.mired or new.mired
      local mired_target = device:get_field(prefix .. "mired_target") or device:get_field(prefix .. "mired_projection") ~= nil
      if mired == nil and enabled and mired_target and output.x ~= nil and output.y ~= nil then
        mired = color.round(color.xy_mired(output.x, output.y))
        if old.physical_min ~= nil then mired = math.max(old.physical_min, mired) end
        if old.physical_max ~= nil then mired = math.min(old.physical_max, mired) end
      end
      if color.finite(mired) then
        save(device, "mired_projection", mired)
        publish(device, "mired", mired)
        if mired > 0 then
          local kelvin = color.round(1000000 / mired)
          if valid(kelvin, 1, 30000, true) then publish(device, "kelvin", kelvin) end
        end
      end
      if valid(values[0x400A], 0, 65535, true) then
        save(device, "capabilities", values[0x400A])
      end
    end
  end

  local function configure(_, device)
    return serial(device, function()
      device:set_field(prefix .. "await_bounds", true, transient)
      read(device, 0x0300, {0x400A})
      -- Explicit Edge adapter for ZHC interview softwareBuildID, never metadata
      -- or a literal fixture seed. Success populates the actual per-device field.
      return read(device, 0x0000, {0x4000})
    end)
  end

  local function refresh(device)
    return serial(device, function()
      read(device, 6, {0, 0x4003})
      read(device, 8, {0, 0x000F, 0x4000})
      read_color(device)
      read(device, 0x0300, {0x000F})
      return read(device, 0x0000, {0x4000})
    end)
  end

  local function announce(device)
    replay_reporting(device)
    if device:get_field(prefix .. "color_off") == true then
      send(device, cluster_base.write_attribute(device, types.ClusterId(0x0300), types.AttributeId(0x000F), types.Bitmap8(1)))
    end
    if device:get_field(prefix .. "level_off") == true then
      send(device, cluster_base.write_attribute(device, types.ClusterId(8), types.AttributeId(0x000F), types.Bitmap8(1)))
    end
    local on_level = device:get_field(prefix .. "on_level")
    if on_level ~= nil then
      send(device, cluster_base.write_attribute(device, types.ClusterId(8), types.AttributeId(0x0011), types.Uint8(math.max(1, math.min(255, on_level)))))
    end
    return true
  end

  local writers = {}
  local function dispatch(device, mapping, value, context)
    return serial(device, function() return writers[mapping.name](device, mapping, value, context) end)
  end

  local function attribute(cluster, id, name, sender)
    if sender ~= nil then writers[name] = sender end
    return zcl.cluster_attribute(cluster, id, {name = name, endpoint = 1, handler = receive,
      sender = sender ~= nil and dispatch or nil, read_only = sender == nil,
      read_on_configure = false, suppress_optimistic_state = true})
  end

  local function command(cluster, name, sender)
    writers[name] = sender
    return zcl.cluster_attribute(cluster, nil, {name = name, endpoint = 1, sender = dispatch,
      write_only = true, suppress_optimistic_state = true})
  end

  local led1624_xy_light = {
    profile = "lights-ikea-led1624g9",
    auto_on_before_light_command = false,
    initial_custom_state_query = false,
    configure = configure,
    announce_handler = announce,
    parent_refresh = refresh,
    zigbee_message_handler = function(device, rx)
      capture_reporting(device, rx)
      read_response(device, rx)
    end,
    color_temperature_range = {minimum = 2000, maximum = 6536},
    runtime_start = function(device)
      device:emit_event(capabilities.colorTemperature.colorTemperatureRange({
        value = {minimum = 2000, maximum = 6536}, unit = "K",
      }))
    end,
    protocol_writers = {
      brightness = function(device, value, command_context)
        return serial(device, function() return set_level(device, {name = "brightness"}, value, command_context) end)
      end,
    },
    capability_commands = {
      {capability_id = "concertmirror08464.ikea1624XyColor", command_name = "setColorXy", argument_name = "colorXy", mapping_name = "ikea1624_color_xy"},
      {capability_id = "concertmirror08464.ikea1624Identify", command_name = "setIdentifyTime", argument_name = "identifyTime", mapping_name = "ikea1624_identify"},
      {capability_id = "concertmirror08464.ikea1624Toggle", command_name = "toggle", value = true, mapping_name = "ikea1624_toggle"},
    },
    zcl_clusters = {
      attribute(0x0000, 0x4000, "ikea1624_firmware"),
      attribute(6, 0, "switch", set_switch),
      attribute(6, 0x4003, "ikea1624_power_on", set_setting),
      attribute(8, 0, "ikea1624_rx_level"),
      attribute(8, 0x000F, "ikea1624_level_off", set_setting),
      attribute(8, 0x4000, "ikea1624_start_level", set_setting),
      attribute(8, 0x0011, "ikea1624_on_level"),
      attribute(0x0300, 0x000F, "ikea1624_color_off", set_setting),
      attribute(0x0300, 0, "ikea1624_rx_hue"),
      attribute(0x0300, 1, "ikea1624_rx_saturation"),
      attribute(0x0300, 3, "ikea1624_rx_x"),
      attribute(0x0300, 4, "ikea1624_rx_y"),
      attribute(0x0300, 7, "ikea1624_rx_mired"),
      attribute(0x0300, 8, "ikea1624_color_mode"),
      attribute(0x0300, 0x400A, "ikea1624_color_capabilities"),
      attribute(0x0300, 0x400B, "ikea1624_physical_min"),
      attribute(0x0300, 0x400C, "ikea1624_physical_max"),
      command(0x0300, "color", set_color),
      command(0x0300, "color_hue", set_color),
      command(0x0300, "color_saturation", set_color),
      command(0x0300, "color_temperature", set_color),
      command(0x0300, "ikea1624_color_xy", set_color),
      command(0x0300, "ikea1624_color_rgb", set_color),
      command(0x0300, "ikea1624_color_mired", set_color),
      command(8, "ikea1624_brightness_raw", set_level),
      command(8, "ikea1624_brightness_percent", set_level),
      command(8, "ikea1624_brightness_keep_power", set_level),
      command(8, "ikea1624_brightness_move", level_motion),
      command(8, "ikea1624_brightness_move_onoff", level_motion),
      command(8, "ikea1624_brightness_step", level_motion),
      command(8, "ikea1624_brightness_step_onoff", level_motion),
      command(6, "ikea1624_timed_on", timed_on),
      command(6, "ikea1624_toggle", toggle),
      command(3, "ikea1624_effect", effect),
      command(3, "ikea1624_identify", identify),
    },
  }

  for _, choice in ipairs({{"blink", "blink"}, {"breathe", "breathe"}, {"okay", "okay"},
      {"channelChange", "channel_change"}, {"finishEffect", "finish_effect"}, {"stopEffect", "stop_effect"},
      {"colorLoop", "colorloop"}, {"stopColorLoop", "stop_colorloop"}}) do
    led1624_xy_light.capability_commands[#led1624_xy_light.capability_commands + 1] = {
      capability_id = "concertmirror08464.ikea1624Effect", command_name = choice[1],
      mapping_name = "ikea1624_effect", value = choice[2],
    }
  end

  register_device_definition(led1624_xy_light, {
    device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 CWS opal 600lm"),
    device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E26 CWS opal 600lm"),
    device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E14 CWS opal 600lm"),
    device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E12 CWS opal 600lm"),
    device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E27 C/WS opal 600"),
    device_helpers.create_fingerprint("IKEA of Sweden", "TRADFRI bulb E17 CWS opal 600lm"),
  })
end

-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(device_definitions, {
  {1, "rpt-tmf"},
  {2, "rpt-txx"},
  {3, "rpt-tkj"},
})
-- ZCL REPORTING CAPABILITIES END

return {
  id = "zcl.lights.ikea",
  registrations = device_definitions,
}
