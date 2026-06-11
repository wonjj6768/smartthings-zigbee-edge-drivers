-- ZCL 클러스터/attribute 매핑 팩토리
-- tuya_common/datapoint_preset.lua 에 대응하는 ZCL 선언적 API
--
-- 사용법: zcl.temperature_measurement({ emit = emit.temperature("C"), scale = 100 })
-- 반환: { cluster_id = 0x0402, attribute_id = 0x0000, emit = ..., ... }

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

  local attribute_specs = {
    ON_OFF = { cluster_name = "OnOff", attribute_name = "OnOff" },
    LEVEL_CURRENT_LEVEL = { cluster_name = "Level", attribute_name = "CurrentLevel" },
    BATTERY_PERCENTAGE_REMAINING = { cluster_name = "PowerConfiguration", attribute_name = "BatteryPercentageRemaining" },
    BATTERY_VOLTAGE = { cluster_name = "PowerConfiguration", attribute_name = "BatteryVoltage" },
    TEMPERATURE_MEASURED_VALUE = { cluster_name = "TemperatureMeasurement", attribute_name = "MeasuredValue" },
    HUMIDITY_MEASURED_VALUE = { cluster_name = "RelativeHumidity", attribute_name = "MeasuredValue" },
    ILLUMINANCE_MEASURED_VALUE = { cluster_name = "IlluminanceMeasurement", attribute_name = "MeasuredValue" },
    PRESSURE_MEASURED_VALUE = { cluster_name = "PressureMeasurement", attribute_name = "MeasuredValue" },
    ZONE_STATUS = { cluster_name = "IASZone", attribute_name = "ZoneStatus" },
    ACTIVE_POWER = { cluster_name = "ElectricalMeasurement", attribute_name = "ActivePower" },
    RMS_VOLTAGE = { cluster_name = "ElectricalMeasurement", attribute_name = "RMSVoltage" },
    RMS_CURRENT = { cluster_name = "ElectricalMeasurement", attribute_name = "RMSCurrent" },
    CURRENT_SUMMATION_DELIVERED = { cluster_name = "SimpleMetering", attribute_name = "CurrentSummationDelivered" },
    OCCUPANCY = { cluster_name = "OccupancySensing", attribute_name = "Occupancy" },
    LOCAL_TEMPERATURE = { cluster_name = "Thermostat", attribute_name = "LocalTemperature" },
    OCCUPIED_HEATING_SETPOINT = { cluster_name = "Thermostat", attribute_name = "OccupiedHeatingSetpoint" },
    OCCUPIED_COOLING_SETPOINT = { cluster_name = "Thermostat", attribute_name = "OccupiedCoolingSetpoint" },
    SYSTEM_MODE = { cluster_name = "Thermostat", attribute_name = "SystemMode" },
    THERMOSTAT_RUNNING_STATE = { cluster_name = "Thermostat", attribute_name = "ThermostatRunningState" },
    FAN_MODE = { cluster_name = "FanControl", attribute_name = "FanMode" },
    CURRENT_POSITION_LIFT_PERCENTAGE = { cluster_name = "WindowCovering", attribute_name = "CurrentPositionLiftPercentage" },
    CURRENT_POSITION_TILT_PERCENTAGE = { cluster_name = "WindowCovering", attribute_name = "CurrentPositionTiltPercentage" },
    COLOR_TEMPERATURE_MIREDS = { cluster_name = "ColorControl", attribute_name = "ColorTemperatureMireds" },
    CURRENT_HUE = { cluster_name = "ColorControl", attribute_name = "CurrentHue" },
    CURRENT_SATURATION = { cluster_name = "ColorControl", attribute_name = "CurrentSaturation" },
  }

  local mapping_option_keys = {
    "name",
    "emit",
    "converter",
    "from_device",
    "to_device",
    "scale",
    "component",
    "endpoint",
    "read_only",
    "write_only",
    "handler",
    "sender",
    "command_id",
    "command_extractor",
    "tx_command_id",
    "tx_command_direction",
    "minimum_interval",
    "maximum_interval",
    "reportable_change",
    "read_on_configure",
    "poll_interval",
    "ias_configure_method",
    "data_type",
    "write_type",
    "numeric_range",
    "prefer_typed_value",
    "attribute_name",
    "complex_type",
    "mfg_code",
    "metering_kind",
  }

  local default_mappings = {
    { factory_name = "temperature_measurement", default_name = "temperature", cluster = "TEMPERATURE", attribute = "TEMPERATURE_MEASURED_VALUE" },
    { factory_name = "relative_humidity", default_name = "humidity", cluster = "RELATIVE_HUMIDITY", attribute = "HUMIDITY_MEASURED_VALUE" },
    { factory_name = "illuminance_measurement", default_name = "illuminance", cluster = "ILLUMINANCE", attribute = "ILLUMINANCE_MEASURED_VALUE" },
    { factory_name = "pressure_measurement", default_name = "pressure", cluster = "PRESSURE", attribute = "PRESSURE_MEASURED_VALUE" },
    { factory_name = "on_off", default_name = "switch", cluster = "ON_OFF", attribute = "ON_OFF" },
    { factory_name = "level_control", default_name = "brightness", cluster = "LEVEL_CONTROL", attribute = "LEVEL_CURRENT_LEVEL" },
    { factory_name = "power_configuration_battery", default_name = "battery", cluster = "POWER_CONFIGURATION", attribute = "BATTERY_PERCENTAGE_REMAINING" },
    { factory_name = "power_configuration_battery_voltage", default_name = "battery_voltage", cluster = "POWER_CONFIGURATION", attribute = "BATTERY_VOLTAGE" },
    { factory_name = "ias_zone", default_name = "zone_status", cluster = "IAS_ZONE", attribute = "ZONE_STATUS" },
    { factory_name = "electrical_measurement_power", default_name = "power", cluster = "ELECTRICAL_MEASUREMENT", attribute = "ACTIVE_POWER" },
    { factory_name = "electrical_measurement_voltage", default_name = "voltage", cluster = "ELECTRICAL_MEASUREMENT", attribute = "RMS_VOLTAGE" },
    { factory_name = "electrical_measurement_current", default_name = "current", cluster = "ELECTRICAL_MEASUREMENT", attribute = "RMS_CURRENT" },
    { factory_name = "simple_metering", default_name = "energy", cluster = "SIMPLE_METERING", attribute = "CURRENT_SUMMATION_DELIVERED" },
    { factory_name = "occupancy_sensing", default_name = "occupancy", cluster = "OCCUPANCY_SENSING", attribute = "OCCUPANCY" },
    { factory_name = "thermostat_local_temperature", default_name = "local_temperature", cluster = "THERMOSTAT", attribute = "LOCAL_TEMPERATURE" },
    { factory_name = "thermostat_heating_setpoint", default_name = "current_heating_setpoint", cluster = "THERMOSTAT", attribute = "OCCUPIED_HEATING_SETPOINT" },
    { factory_name = "thermostat_cooling_setpoint", default_name = "current_cooling_setpoint", cluster = "THERMOSTAT", attribute = "OCCUPIED_COOLING_SETPOINT" },
    { factory_name = "thermostat_system_mode", default_name = "system_mode", cluster = "THERMOSTAT", attribute = "SYSTEM_MODE" },
    { factory_name = "thermostat_running_state", default_name = "thermostat_operating_state", cluster = "THERMOSTAT", attribute = "THERMOSTAT_RUNNING_STATE" },
    { factory_name = "fan_control_mode", default_name = "fan_mode", cluster = "FAN_CONTROL", attribute = "FAN_MODE" },
    { factory_name = "window_covering_position", default_name = "cover_position", cluster = "WINDOW_COVERING", attribute = "CURRENT_POSITION_LIFT_PERCENTAGE" },
    { factory_name = "window_covering_tilt", default_name = "cover_tilt", cluster = "WINDOW_COVERING", attribute = "CURRENT_POSITION_TILT_PERCENTAGE" },
    { factory_name = "color_control_temperature", default_name = "color_temperature", cluster = "COLOR_CONTROL", attribute = "COLOR_TEMPERATURE_MIREDS" },
    { factory_name = "color_control_hue", default_name = "color_hue", cluster = "COLOR_CONTROL", attribute = "CURRENT_HUE" },
    { factory_name = "color_control_saturation", default_name = "color_saturation", cluster = "COLOR_CONTROL", attribute = "CURRENT_SATURATION" },
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
      local attribute = zcl.get_generated_attribute_by_name(spec.cluster_name, spec.attribute_name)
      if attribute == nil then
        log.warn(string.format("missing generated ZCL attribute '%s.%s'", spec.cluster_name, spec.attribute_name))
      else
        attribute_constants[export_name] = attribute.ID
      end
    end
  end

  --- 범용 ZCL attribute 매핑을 생성합니다.
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

  --- 수동으로 attribute 핸들러 등록만 추가하고 싶을 때 사용합니다.
  ---@param cluster_id number
  ---@param attribute_id number
  ---@return boolean 새로 등록되었으면 true
  function zcl.register_attribute(cluster_id, attribute_id)
    return add_registered_attribute(cluster_id, attribute_id)
  end

  --- zcl_clusters 리스트에 포함된 모든 attribute를 핸들러 등록 목록에 추가합니다.
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

  --- 커스텀 매핑 팩토리를 등록합니다.
  --- 팩토리 등록과 attribute 핸들러 등록을 동시에 처리합니다.
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
        (attribute_specs[definition.attribute] and attribute_specs[definition.attribute].attribute_name) or
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
    zcl.register_mapping(definition)
  end

  --- REGISTERED_ATTRIBUTES로부터 zigbee_handlers.attr 테이블을 자동 생성합니다.
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
