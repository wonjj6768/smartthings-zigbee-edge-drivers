
local function load_cluster_mapping(zcl)

  local log = require "log"

  local cluster_specs = {
    ON_OFF = "OnOff",
    LEVEL_CONTROL = "Level",
    POWER_CONFIGURATION = "PowerConfiguration",
    TEMPERATURE = "TemperatureMeasurement",
    RELATIVE_HUMIDITY = "RelativeHumidity",
    ILLUMINANCE = "IlluminanceMeasurement",
    PRESSURE = "PressureMeasurement",
    IAS_ZONE = "IASZone",
    ELECTRICAL_MEASUREMENT = "ElectricalMeasurement",
    SIMPLE_METERING = "SimpleMetering",
    OCCUPANCY_SENSING = "OccupancySensing",
    THERMOSTAT = "Thermostat",
    FAN_CONTROL = "FanControl",
    WINDOW_COVERING = "WindowCovering",
    COLOR_CONTROL = "ColorControl",
  }

  -- Cluster name, attribute name.
  local attribute_specs = {
    ON_OFF = { "OnOff", "OnOff" },
    LEVEL_CURRENT_LEVEL = { "Level", "CurrentLevel" },
    BATTERY_PERCENTAGE_REMAINING = { "PowerConfiguration", "BatteryPercentageRemaining" },
    BATTERY_VOLTAGE = { "PowerConfiguration", "BatteryVoltage" },
    TEMPERATURE_MEASURED_VALUE = { "TemperatureMeasurement", "MeasuredValue" },
    HUMIDITY_MEASURED_VALUE = { "RelativeHumidity", "MeasuredValue" },
    ILLUMINANCE_MEASURED_VALUE = { "IlluminanceMeasurement", "MeasuredValue" },
    PRESSURE_MEASURED_VALUE = { "PressureMeasurement", "MeasuredValue" },
    ZONE_STATUS = { "IASZone", "ZoneStatus" },
    ACTIVE_POWER = { "ElectricalMeasurement", "ActivePower" },
    RMS_VOLTAGE = { "ElectricalMeasurement", "RMSVoltage" },
    RMS_CURRENT = { "ElectricalMeasurement", "RMSCurrent" },
    CURRENT_SUMMATION_DELIVERED = { "SimpleMetering", "CurrentSummationDelivered" },
    OCCUPANCY = { "OccupancySensing", "Occupancy" },
    LOCAL_TEMPERATURE = { "Thermostat", "LocalTemperature" },
    OCCUPIED_HEATING_SETPOINT = { "Thermostat", "OccupiedHeatingSetpoint" },
    OCCUPIED_COOLING_SETPOINT = { "Thermostat", "OccupiedCoolingSetpoint" },
    SYSTEM_MODE = { "Thermostat", "SystemMode" },
    THERMOSTAT_RUNNING_STATE = { "Thermostat", "ThermostatRunningState" },
    THERMOSTAT_LOCAL_TEMPERATURE_CALIBRATION = { "Thermostat", "LocalTemperatureCalibration" },
    THERMOSTAT_PI_HEATING_DEMAND = { "Thermostat", "PIHeatingDemand" },
    FAN_MODE = { "FanControl", "FanMode" },
    CURRENT_POSITION_LIFT_PERCENTAGE = { "WindowCovering", "CurrentPositionLiftPercentage" },
    CURRENT_POSITION_TILT_PERCENTAGE = { "WindowCovering", "CurrentPositionTiltPercentage" },
    COLOR_TEMPERATURE_MIREDS = { "ColorControl", "ColorTemperatureMireds" },
    CURRENT_HUE = { "ColorControl", "CurrentHue" },
    CURRENT_SATURATION = { "ColorControl", "CurrentSaturation" },
  }

  local mapping_option_keys = {
    "name",
    "emit",
    "converter",
    "from_device",
    "to_device",
    "scale",
    "ignore_reported_scaler",
    "use_reported_unity_scaler",
    "component",
    "endpoint",
    "read_only",
    "write_only",
    "suppress_optimistic_state",
    "handler",
    "sender",
    "command_id",
    "command_extractor",
    "tx_command_id",
    "tx_command_direction",
    "minimum_interval",
    "maximum_interval",
    "reportable_change",
    "physical_reportable_change",
    "reporting_defaults",
    "read_on_configure",
    "read_on_refresh",
    "poll_interval",
    "ias_configure_method",
    "data_type",
    "write_type",
    "numeric_range",
    "prefer_typed_value",
    "prefer_plain_attribute_write",
    "attribute_name",
    "complex_type",
    "mfg_code",
    "profile_id",
    "metering_kind",
  }

  -- Factory name, default mapping name, cluster key, attribute key.
  local default_mappings = {
    { "temperature_measurement", "temperature", "TEMPERATURE", "TEMPERATURE_MEASURED_VALUE" },
    { "relative_humidity", "humidity", "RELATIVE_HUMIDITY", "HUMIDITY_MEASURED_VALUE" },
    { "illuminance_measurement", "illuminance", "ILLUMINANCE", "ILLUMINANCE_MEASURED_VALUE" },
    { "pressure_measurement", "pressure", "PRESSURE", "PRESSURE_MEASURED_VALUE" },
    { "on_off", "switch", "ON_OFF", "ON_OFF" },
    { "level_control", "brightness", "LEVEL_CONTROL", "LEVEL_CURRENT_LEVEL" },
    { "power_configuration_battery", "battery", "POWER_CONFIGURATION", "BATTERY_PERCENTAGE_REMAINING" },
    { "power_configuration_battery_voltage", "battery_voltage", "POWER_CONFIGURATION", "BATTERY_VOLTAGE" },
    { "ias_zone", "zone_status", "IAS_ZONE", "ZONE_STATUS" },
    { "electrical_measurement_power", "power", "ELECTRICAL_MEASUREMENT", "ACTIVE_POWER" },
    { "electrical_measurement_voltage", "voltage", "ELECTRICAL_MEASUREMENT", "RMS_VOLTAGE" },
    { "electrical_measurement_current", "current", "ELECTRICAL_MEASUREMENT", "RMS_CURRENT" },
    { "simple_metering", "energy", "SIMPLE_METERING", "CURRENT_SUMMATION_DELIVERED" },
    { "occupancy_sensing", "occupancy", "OCCUPANCY_SENSING", "OCCUPANCY" },
    { "thermostat_local_temperature", "local_temperature", "THERMOSTAT", "LOCAL_TEMPERATURE" },
    { "thermostat_heating_setpoint", "current_heating_setpoint", "THERMOSTAT", "OCCUPIED_HEATING_SETPOINT" },
    { "thermostat_cooling_setpoint", "current_cooling_setpoint", "THERMOSTAT", "OCCUPIED_COOLING_SETPOINT" },
    { "thermostat_system_mode", "system_mode", "THERMOSTAT", "SYSTEM_MODE" },
    { "thermostat_running_state", "thermostat_operating_state", "THERMOSTAT", "THERMOSTAT_RUNNING_STATE" },
    { "thermostat_local_temperature_calibration", "local_temperature_calibration", "THERMOSTAT", "THERMOSTAT_LOCAL_TEMPERATURE_CALIBRATION" },
    { "thermostat_pi_heating_demand", "pi_heating_demand", "THERMOSTAT", "THERMOSTAT_PI_HEATING_DEMAND" },
    { "fan_control_mode", "fan_mode", "FAN_CONTROL", "FAN_MODE" },
    { "window_covering_position", "cover_position", "WINDOW_COVERING", "CURRENT_POSITION_LIFT_PERCENTAGE" },
    { "window_covering_tilt", "cover_tilt", "WINDOW_COVERING", "CURRENT_POSITION_TILT_PERCENTAGE" },
    { "color_control_temperature", "color_temperature", "COLOR_CONTROL", "COLOR_TEMPERATURE_MIREDS" },
    { "color_control_hue", "color_hue", "COLOR_CONTROL", "CURRENT_HUE" },
    { "color_control_saturation", "color_saturation", "COLOR_CONTROL", "CURRENT_SATURATION" },
  }

  local cluster_constants = {}
  local attribute_constants = {}
  local registered_attributes = {}
  local registered_attribute_keys = {}
  local registered_mappings = {}

  local function export_constants(target, prefix, definitions)
    for name, value in pairs(definitions) do
      target[prefix .. name] = value
    end
  end

  local function resolve_cluster_id(cluster_key)
    if cluster_key == nil then
      return nil
    end

    if cluster_constants[cluster_key] ~= nil then
      return cluster_constants[cluster_key]
    end

    return zcl.get_generated_cluster_id(cluster_key)
  end

  local function resolve_attribute_id(attribute_key, cluster_name)
    if attribute_key == nil then
      return nil
    end

    if attribute_constants[attribute_key] ~= nil then
      return attribute_constants[attribute_key]
    end

    if cluster_name ~= nil then
      local attribute = zcl.get_generated_attribute_by_name(cluster_name, attribute_key)
      return attribute and attribute.ID or nil
    end

    return nil
  end

  local function add_registered_attribute(cluster_id, attribute_id)
    if cluster_id == nil or attribute_id == nil then
      return false
    end

    local key = string.format("%04X:%04X", cluster_id, attribute_id)
    if registered_attribute_keys[key] then
      return false
    end

    registered_attribute_keys[key] = true
    registered_attributes[#registered_attributes + 1] = {
      cluster_id = cluster_id,
      attribute_id = attribute_id,
    }

    return true
  end

  local function copy_mapping_options(options)
    local mapping = {
      protocol = "zcl",
    }

    for _, key in ipairs(mapping_option_keys) do
      mapping[key] = options[key]
    end

    if mapping.write_type == nil then
      mapping.write_type = options.data_type
    end

    return mapping
  end

  local function init_cluster_constants()
    for export_name, cluster_name in pairs(cluster_specs) do
      local cluster_id = zcl.get_generated_cluster_id(cluster_name)
      if cluster_id == nil then
        log.warn(string.format("missing generated ZCL cluster '%s'", cluster_name))
      else
        cluster_constants[export_name] = cluster_id
      end
    end
  end

  local function init_attribute_constants()
    for export_name, spec in pairs(attribute_specs) do
      local cluster_name, attribute_name = spec[1], spec[2]
      local attribute = zcl.get_generated_attribute_by_name(cluster_name, attribute_name)
      if attribute == nil then
        log.warn(string.format("missing generated ZCL attribute '%s.%s'", cluster_name, attribute_name))
      else
        attribute_constants[export_name] = attribute.ID
      end
    end
  end

  ---@param cluster_id number
  ---@param attribute_id number
  ---@param options table|nil
  ---@return table
  function zcl.cluster_attribute(cluster_id, attribute_id, options)
    local mapping = copy_mapping_options(options or {})
    mapping.cluster_id = cluster_id
    mapping.attribute_id = attribute_id
    return mapping
  end

  ---@param cluster_id number
  ---@param attribute_id number
  ---@return boolean 새로 등록되었으면 true
  function zcl.register_attribute(cluster_id, attribute_id)
    return add_registered_attribute(cluster_id, attribute_id)
  end

  ---@param zcl_clusters table|nil
  function zcl.register_attributes_from_mappings(zcl_clusters)
    if type(zcl_clusters) ~= "table" then
      return zcl_clusters
    end

    for _, mapping in ipairs(zcl_clusters) do
      if type(mapping) == "table" then
        add_registered_attribute(mapping.cluster_id, mapping.attribute_id)
      end
    end

    return zcl_clusters
  end

  ---@param definition table
  ---@return table 정규화된 정의
  function zcl.register_mapping(definition)
    local cluster_name = definition.cluster_name or cluster_specs[definition.cluster] or definition.cluster
    local cluster_id = definition.cluster_id or resolve_cluster_id(definition.cluster) or resolve_cluster_id(cluster_name)
    local attribute_id = definition.attribute_id or
      resolve_attribute_id(definition.attribute, cluster_name) or
      resolve_attribute_id(definition.attribute_name, cluster_name)

    if definition.factory_name == nil or cluster_id == nil or attribute_id == nil then
      log.warn(string.format(
        "skip invalid zcl mapping definition factory=%s cluster=%s attribute=%s",
        tostring(definition.factory_name),
        tostring(cluster_name),
        tostring(definition.attribute_name or definition.attribute)
      ))
      return nil
    end

    local normalized = {
      factory_name = definition.factory_name,
      default_name = definition.default_name,
      cluster_id = cluster_id,
      attribute_id = attribute_id,
      cluster_name = cluster_name,
      attribute_name = definition.attribute_name or
        (attribute_specs[definition.attribute] and attribute_specs[definition.attribute][2]) or
        definition.attribute,
    }

    registered_mappings[#registered_mappings + 1] = normalized
    add_registered_attribute(cluster_id, attribute_id)

    zcl[normalized.factory_name] = function(options)
      local mapping = zcl.cluster_attribute(cluster_id, attribute_id, options)
      if mapping.name == nil then
        mapping.name = normalized.default_name
      end
      return mapping
    end

    return normalized
  end

  init_cluster_constants()
  init_attribute_constants()

  zcl.CLUSTERS = cluster_constants
  zcl.ATTRIBUTES = attribute_constants
  zcl.MAPPING_DEFINITIONS = registered_mappings
  zcl.REGISTERED_ATTRIBUTES = registered_attributes

  export_constants(zcl, "CLUSTER_", cluster_constants)
  export_constants(zcl, "ATTR_", attribute_constants)

  for _, definition in ipairs(default_mappings) do
    zcl.register_mapping({
      factory_name = definition[1], default_name = definition[2],
      cluster = definition[3], attribute = definition[4],
    })
  end

  ---@param handler_factory function (cluster_id, attribute_id) → handler function
  ---@return table zigbee_handlers.attr에 직접 할당 가능한 테이블
  function zcl.build_attribute_handlers(handler_factory)
    local attr_handlers = {}

    for _, entry in ipairs(zcl.REGISTERED_ATTRIBUTES) do
      local cluster_id = entry.cluster_id
      local attribute_id = entry.attribute_id

      attr_handlers[cluster_id] = attr_handlers[cluster_id] or {}
      attr_handlers[cluster_id][attribute_id] = handler_factory(cluster_id, attribute_id)
    end

    return attr_handlers
  end

end

return load_cluster_mapping
