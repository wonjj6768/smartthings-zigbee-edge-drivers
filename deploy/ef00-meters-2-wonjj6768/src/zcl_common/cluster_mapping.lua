local function C(p)
local K,D,n,E,F,g,f,i,k,j=require"log",{ON_OFF="OnOff",LEVEL_CONTROL="Level",POWER_CONFIGURATION="PowerConfiguration",TEMPERATURE="TemperatureMeasurement",RELATIVE_HUMIDITY="RelativeHumidity",ILLUMINANCE="IlluminanceMeasurement",PRESSURE="PressureMeasurement",IAS_ZONE="IASZone",ELECTRICAL_MEASUREMENT="ElectricalMeasurement",SIMPLE_METERING="SimpleMetering",OCCUPANCY_SENSING="OccupancySensing",THERMOSTAT="Thermostat",FAN_CONTROL="FanControl",WINDOW_COVERING="WindowCovering",COLOR_CONTROL="ColorControl"},{ON_OFF={"OnOff","OnOff"},LEVEL_CURRENT_LEVEL={"Level","CurrentLevel"},BATTERY_PERCENTAGE_REMAINING={"PowerConfiguration","BatteryPercentageRemaining"},BATTERY_VOLTAGE={"PowerConfiguration","BatteryVoltage"},TEMPERATURE_MEASURED_VALUE={"TemperatureMeasurement","MeasuredValue"},HUMIDITY_MEASURED_VALUE={"RelativeHumidity","MeasuredValue"},ILLUMINANCE_MEASURED_VALUE={"IlluminanceMeasurement","MeasuredValue"},PRESSURE_MEASURED_VALUE={"PressureMeasurement","MeasuredValue"},ZONE_STATUS={"IASZone","ZoneStatus"},ACTIVE_POWER={"ElectricalMeasurement","ActivePower"},RMS_VOLTAGE={"ElectricalMeasurement","RMSVoltage"},RMS_CURRENT={"ElectricalMeasurement","RMSCurrent"},CURRENT_SUMMATION_DELIVERED={"SimpleMetering","CurrentSummationDelivered"},OCCUPANCY={"OccupancySensing","Occupancy"},LOCAL_TEMPERATURE={"Thermostat","LocalTemperature"},OCCUPIED_HEATING_SETPOINT={"Thermostat","OccupiedHeatingSetpoint"},OCCUPIED_COOLING_SETPOINT={"Thermostat","OccupiedCoolingSetpoint"},SYSTEM_MODE={"Thermostat","SystemMode"},THERMOSTAT_RUNNING_STATE={"Thermostat","ThermostatRunningState"},THERMOSTAT_LOCAL_TEMPERATURE_CALIBRATION={"Thermostat","LocalTemperatureCalibration"},THERMOSTAT_PI_HEATING_DEMAND={"Thermostat","PIHeatingDemand"},FAN_MODE={"FanControl","FanMode"},CURRENT_POSITION_LIFT_PERCENTAGE={"WindowCovering","CurrentPositionLiftPercentage"},CURRENT_POSITION_TILT_PERCENTAGE={"WindowCovering","CurrentPositionTiltPercentage"},COLOR_TEMPERATURE_MIREDS={"ColorControl","ColorTemperatureMireds"},CURRENT_HUE={"ColorControl","CurrentHue"},CURRENT_SATURATION={"ColorControl","CurrentSaturation"}},{"name","emit","converter","from_device","to_device","scale","ignore_reported_scaler","use_reported_unity_scaler","component","endpoint","read_only","write_only","suppress_optimistic_state","handler","sender","command_id","command_extractor","tx_command_id","tx_command_direction","minimum_interval","maximum_interval","reportable_change","physical_reportable_change","reporting_defaults","read_on_configure","read_on_refresh","poll_interval","ias_configure_method","data_type","write_type","numeric_range","prefer_typed_value","prefer_plain_attribute_write","attribute_name","complex_type","mfg_code","profile_id","metering_kind"},{{"temperature_measurement","temperature","TEMPERATURE","TEMPERATURE_MEASURED_VALUE"},{"relative_humidity","humidity","RELATIVE_HUMIDITY","HUMIDITY_MEASURED_VALUE"},{"illuminance_measurement","illuminance","ILLUMINANCE","ILLUMINANCE_MEASURED_VALUE"},{"pressure_measurement","pressure","PRESSURE","PRESSURE_MEASURED_VALUE"},{"on_off","switch","ON_OFF","ON_OFF"},{"level_control","brightness","LEVEL_CONTROL","LEVEL_CURRENT_LEVEL"},{"power_configuration_battery","battery","POWER_CONFIGURATION","BATTERY_PERCENTAGE_REMAINING"},{"power_configuration_battery_voltage","battery_voltage","POWER_CONFIGURATION","BATTERY_VOLTAGE"},{"ias_zone","zone_status","IAS_ZONE","ZONE_STATUS"},{"electrical_measurement_power","power","ELECTRICAL_MEASUREMENT","ACTIVE_POWER"},{"electrical_measurement_voltage","voltage","ELECTRICAL_MEASUREMENT","RMS_VOLTAGE"},{"electrical_measurement_current","current","ELECTRICAL_MEASUREMENT","RMS_CURRENT"},{"simple_metering","energy","SIMPLE_METERING","CURRENT_SUMMATION_DELIVERED"},{"occupancy_sensing","occupancy","OCCUPANCY_SENSING","OCCUPANCY"},{"thermostat_local_temperature","local_temperature","THERMOSTAT","LOCAL_TEMPERATURE"},{"thermostat_heating_setpoint","current_heating_setpoint","THERMOSTAT","OCCUPIED_HEATING_SETPOINT"},{"thermostat_cooling_setpoint","current_cooling_setpoint","THERMOSTAT","OCCUPIED_COOLING_SETPOINT"},{"thermostat_system_mode","system_mode","THERMOSTAT","SYSTEM_MODE"},{"thermostat_running_state","thermostat_operating_state","THERMOSTAT","THERMOSTAT_RUNNING_STATE"},{"thermostat_local_temperature_calibration","local_temperature_calibration","THERMOSTAT","THERMOSTAT_LOCAL_TEMPERATURE_CALIBRATION"},{"thermostat_pi_heating_demand","pi_heating_demand","THERMOSTAT","THERMOSTAT_PI_HEATING_DEMAND"},{"fan_control_mode","fan_mode","FAN_CONTROL","FAN_MODE"},{"window_covering_position","cover_position","WINDOW_COVERING","CURRENT_POSITION_LIFT_PERCENTAGE"},{"window_covering_tilt","cover_tilt","WINDOW_COVERING","CURRENT_POSITION_TILT_PERCENTAGE"},{"color_control_temperature","color_temperature","COLOR_CONTROL","COLOR_TEMPERATURE_MIREDS"},{"color_control_hue","color_hue","COLOR_CONTROL","CURRENT_HUE"},{"color_control_saturation","color_saturation","COLOR_CONTROL","CURRENT_SATURATION"}},{},{},{},{},{}
local function w(N,L,H)
for name,O in pairs(H)do
N[L..name]=O
end
end
local function t(r)
if r==nil then
return nil
end
if g[r]~=nil then
return g[r]end
return p.get_generated_cluster_id(r)
end
local function o(m,d)
if m==nil then
return nil
end
if f[m]~=nil then
return f[m]end
if d~=nil then
local s=p.get_generated_attribute_by_name(d,m)return s and s.ID or nil
end
return nil
end
local function h(b,c)
if b==nil or c==nil then
return false
end
local I=string.format("%04X:%04X",b,c)if k[I]then
return false
end
k[I]=true
i[#i+1]={cluster_id=b,attribute_id=c}return true
end
local function B(v)
local e={protocol="zcl"}for _,I in ipairs(E)do
e[I]=v[I]end
if e.write_type==nil then
e.write_type=v.data_type
end
return e
end
local function z()
for y,d in pairs(D)do
local b=p.get_generated_cluster_id(d)if b==nil then
K.warn(string.format("missing generated ZCL cluster '%s'",d))else
g[y]=b
end
end
end
local function x()
for y,M in pairs(n)do
local d,A=M[1],M[2]local s=p.get_generated_attribute_by_name(d,A)if s==nil then
K.warn(string.format("missing generated ZCL attribute '%s.%s'",d,A))else
f[y]=s.ID
end
end
end
function p.cluster_attribute(b,c,v)
local e=B(v or{})e.cluster_id=b
e.attribute_id=c
return e
end
function p.register_attribute(b,c)
return h(b,c)
end
function p.register_attributes_from_mappings(q)
if type(q)~="table"then
return q
end
for _,e in ipairs(q)do
if type(e)=="table"then
h(e.cluster_id,e.attribute_id)end
end
return q
end
function p.register_mapping(a)
local d=a.cluster_name or D[a.cluster]or a.cluster
local b=a.cluster_id or t(a.cluster)or t(d)local c=a.attribute_id or
o(a.attribute,d)or
o(a.attribute_name,d)if a.factory_name==nil or b==nil or c==nil then
K.warn(string.format("skip invalid zcl mapping definition factory=%s cluster=%s attribute=%s",tostring(a.factory_name),tostring(d),tostring(a.attribute_name or a.attribute)))return nil
end
local u={factory_name=a.factory_name,default_name=a.default_name,cluster_id=b,attribute_id=c,cluster_name=d,attribute_name=a.attribute_name or
(n[a.attribute]and n[a.attribute][2])or
a.attribute}j[#j+1]=u
h(b,c)
p[u.factory_name]=function(v)
local e=p.cluster_attribute(b,c,v)if e.name==nil then
e.name=u.default_name
end
return e
end
return u
end
z()x()p.CLUSTERS=g
p.ATTRIBUTES=f
p.MAPPING_DEFINITIONS=j
p.REGISTERED_ATTRIBUTES=i
w(p,"CLUSTER_",g)w(p,"ATTR_",f)for _,a in ipairs(F)do
p.register_mapping{factory_name=a[1],default_name=a[2],cluster=a[3],attribute=a[4]}end
function p.build_attribute_handlers(G)
local l={}for _,J in ipairs(p.REGISTERED_ATTRIBUTES)do
local b,c=J.cluster_id,J.attribute_id

l[b]=l[b]or{}l[b][c]=G(b,c)end
return l
end
end
return C
