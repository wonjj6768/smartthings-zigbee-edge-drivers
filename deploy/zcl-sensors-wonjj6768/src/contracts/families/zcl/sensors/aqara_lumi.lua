local zcl=require"protocol.zcl"
local device_helpers=require"contracts.helpers.family"
local capabilities=require"st.capabilities"
local emit=require"capabilities.events.all"
local data_types=require"st.zigbee.data_types"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local LUMI_BASIC_CLUSTER=0x0000
local LUMI_BASIC_ATTR=0xFF01
local function battery_percent_from_voltage(voltage_mv)
local percent=((voltage_mv-2850)*100)/150
if percent<0 then
return 0
elseif percent>100 then
return 100
end
return math.floor(percent+0.5)
end
local function lumi_table_value(source,key)
if type(source)~="table"then
return nil
end
return source[key]or source[tostring(key)]
end
local function lumi_basic_events(_,value)
local data=value
if type(data)=="table"and data.value~=nil then
data=data.value
end
if type(data)=="table"and data[65281]~=nil then
data=data[65281]
elseif type(data)=="table"and data["65281"]~=nil then
data=data["65281"]
end
if type(data)~="table"then
return nil
end
local events={}
local voltage_mv=lumi_table_value(data,1)
local temperature=lumi_table_value(data,100)
local humidity=lumi_table_value(data,101)
local pressure=lumi_table_value(data,102)
if type(voltage_mv)=="number"then
events[#events+1]=capabilities.battery.battery(battery_percent_from_voltage(voltage_mv))
events[#events+1]=capabilities.voltageMeasurement.voltage({value=voltage_mv/1000,unit="V"})
end
if type(temperature)=="number"then
local celsius=temperature/100
if celsius>-65 and celsius<65 then
events[#events+1]=capabilities.temperatureMeasurement.temperature({value=celsius,unit="C"})
end
end
if type(humidity)=="number"then
local percent=humidity/100
if percent>=0 and percent<=100 then
events[#events+1]=capabilities.relativeHumidityMeasurement.humidity(percent)
end
end
if type(pressure)=="number"then
events[#events+1]=capabilities.atmosphericPressureMeasurement.atmosphericPressure({value=pressure/1000,unit="kPa"})
end
return events[1]~=nil and events or nil
end
local temp_humidity_lumi_basic={
profile="sensors-temp-humidity-battery-voltage",
zcl_clusters={
zcl.cluster_attribute(LUMI_BASIC_CLUSTER,LUMI_BASIC_ATTR,{
name="lumi_basic",
emit=lumi_basic_events,
read_only=true,}),
zcl.temperature(),
zcl.humidity(),
zcl.battery(),},}
local temp_humidity_pressure={
profile="sensors-temp-humidity-pressure-battery-voltage",
zcl_clusters={
zcl.cluster_attribute(LUMI_BASIC_CLUSTER,LUMI_BASIC_ATTR,{
name="lumi_basic",
emit=lumi_basic_events,
read_only=true,}),
zcl.temperature(),
zcl.humidity(),
zcl.pressure(),
zcl.battery(),
zcl.battery_voltage(),},}
local illuminance={
profile="sensors-illuminance-battery-voltage-lumi-pending",
zcl_clusters={
zcl.illuminance(),
zcl.battery(),
zcl.battery_voltage(),},}
local function lumi_number(value)
return type(value)=="table"and value.value or value
end
local function lumi_motion_timer(device,timeout)
local previous=device:get_field("__lumi_motion_timer")
if previous then previous:cancel()end
device:set_field("__lumi_motion_timer",nil)
if timeout>0 then
device:set_field("__lumi_motion_timer",device.thread:call_with_delay(timeout,function()
device:set_field("__lumi_motion_timer",nil)
device:emit_event(capabilities.motionSensor.motion.inactive())
end,"Aqara motion reset"))
end
end
local function lumi_motion_lux(default_interval,legacy)
return function(device,raw)
raw=lumi_number(raw)
local interval=device:get_field("__lumi_detection_interval")or default_interval
local configured=tonumber(device.preferences.occupancyTimeout)
local timeout=legacy and(configured or 90)or((configured and configured>=interval)and configured or interval+2)
lumi_motion_timer(device,timeout)
local lux=legacy and raw or(raw>130536 and 0 or raw-65536)
return{capabilities.motionSensor.motion.active(),capabilities.illuminanceMeasurement.illuminance(math.max(0,lux))}
end
end
local function lumi_motion_diagnostics(temp_emit,interval_emit,p1,restart_emit)
return function(device,value)
local fields=lumi_number(value)
if type(fields)=="string"then
local decoded,offset={},1
while offset+1<=#fields do
local key,kind=fields:byte(offset,offset+1)
local width=kind>=0x20 and kind<=0x2F and((kind%8)+1)or kind==0x10 and 1
if not width or offset+1+width>#fields then break end
decoded[key]=string.unpack("<"..(kind>=0x28 and"i"or"I")..width,fields,offset+2)
offset=offset+2+width
end
fields=decoded
end
if type(fields)~="table"then return end
local events={}
local voltage=lumi_number(fields[1]or fields["1"])
if type(voltage)=="number"then
events[#events+1]=capabilities.battery.battery(battery_percent_from_voltage(voltage))
events[#events+1]=capabilities.voltageMeasurement.voltage({value=voltage/1000,unit="V"})
end
local temperature=lumi_number(fields[3]or fields["3"])
if temp_emit and type(temperature)=="number"then events[#events+1]=temp_emit(device,temperature)end
local restarts=lumi_number(fields[5]or fields["5"])
if restart_emit and type(restarts)=="number"then events[#events+1]=restart_emit(device,restarts-1)end
local interval=lumi_number(fields[105]or fields["105"])
if p1 and type(interval)=="number"then
device:set_field("__lumi_detection_interval",interval)
events[#events+1]=interval_emit(device,interval)
end
if p1 then
local sensitivity=({[1]="low",[2]="medium",[3]="high"})[lumi_number(fields[106]or fields["106"])]
if sensitivity then events[#events+1]=emit.aqP1Sensitivity()(device,sensitivity)end
local indicator=lumi_number(fields[107]or fields["107"])
if indicator~=nil then events[#events+1]=emit.aqP1Indicator()(device,indicator==1 and"on"or"off")end
end
return #events>0 and events or nil
end
end
local function t1_ht_heartbeat(device,value)
local fields=lumi_number(value)
if type(fields)=="string"then
local decoded,offset={},1
while offset+1<=#fields do
local key,kind=fields:byte(offset,offset+1)
local width=kind>=0x20 and kind<=0x2F and((kind%8)+1)or kind==0x10 and 1
if not width or offset+1+width>#fields then break end
decoded[key]=string.unpack("<"..(kind>=0x28 and"i"or"I")..width,fields,offset+2)
offset=offset+2+width
end
fields=decoded
end
if type(fields)~="table"then return end
local events=lumi_basic_events(device,{
[1]=lumi_number(lumi_table_value(fields,1)),
[100]=lumi_number(lumi_table_value(fields,100)),
[101]=lumi_number(lumi_table_value(fields,101)),
})or{}
local temperature=lumi_number(lumi_table_value(fields,3))
if type(temperature)=="number"then
events[#events+1]=emit.t1HtDeviceTemperature("C")(device,temperature)
end
local outages=lumi_number(lumi_table_value(fields,5))
if type(outages)=="number"then
events[#events+1]=emit.t1HtPowerOutageCount()(device,outages-1)
end
return #events>0 and events or nil
end
local aqara_t1_ht={
profile="sensors-aqara-t1-ht",
magic_packet=false,
parent_refresh=function(device)
for _,attribute in ipairs({{0x0402,0},{0x0405,0},{0x0403,0},{1,0x21},{1,0x20}})do
zcl.read_attribute(device,attribute[1],attribute[2],1)
end
end,
zcl_clusters={
zcl.cluster_attribute(0,0xFF01,{
name="t1_ht_basic_heartbeat",endpoint=1,read_only=true,
read_on_configure=false,emit=t1_ht_heartbeat,}),
zcl.cluster_attribute(0xFCC0,0x00F7,{
name="t1_ht_heartbeat",endpoint=1,read_only=true,
read_on_configure=false,emit=t1_ht_heartbeat,}),
zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100}),
zcl.humidity({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100}),
zcl.pressure({endpoint=1,scale=1,minimum_interval=10,maximum_interval=3600,reportable_change=5,
emit=function(_,value)
return capabilities.atmosphericPressureMeasurement.atmosphericPressure({value=value,unit="hPa"})
end}),
zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
from_device=function(value,_,context)return context.raw_value<255 and value or nil end}),
zcl.battery_voltage({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
from_device=function(value,_,context)return context.raw_value<255 and value or nil end,
emit=function(_,value)
return{capabilities.voltageMeasurement.voltage({value=value,unit="V"}),
capabilities.battery.battery(battery_percent_from_voltage(value*1000))}
end}),
},}
local function lumi_occupancy(device,value)
if lumi_number(value)~=1 then return end
lumi_motion_timer(device,tonumber(device.preferences.occupancyTimeout)or 90)
return capabilities.motionSensor.motion.active()
end
local function lumi_struct_mapping(restart_emit)
return zcl.cluster_attribute(0,0xFF02,{
name="lumi_struct_battery",read_only=true,read_on_configure=false,
emit=function(device,value)
local elements,events=value.elements,{}
local voltage=elements and elements[2]and lumi_number(elements[2].data)
if type(voltage)=="number"then
events[#events+1]=capabilities.battery.battery(battery_percent_from_voltage(voltage))
events[#events+1]=capabilities.voltageMeasurement.voltage({value=voltage/1000,unit="V"})
end
local restarts=elements and elements[5]and lumi_number(elements[5].data)
if restart_emit and type(restarts)=="number"then events[#events+1]=restart_emit(device,restarts-1)end
return #events>0 and events or nil
end,
})
end
local motion={
profile="safety-lumi-motion",
zcl_clusters={
zcl.cluster_attribute(0x0406,0,{
name="lumi_occupancy",read_only=true,read_on_configure=false,
emit=lumi_occupancy,}),
zcl.cluster_attribute(LUMI_BASIC_CLUSTER,LUMI_BASIC_ATTR,{
name="lumi_basic",read_only=true,read_on_configure=false,
emit=lumi_motion_diagnostics(nil,nil,nil,emit.miMotionRestarts()),}),
lumi_struct_mapping(emit.miMotionRestarts()),},}
local function lumi_motion_definition(profile,temp_emit,interval_emit,interval_name,default_interval,p1,restart_emit)
local legacy=interval_emit==nil
local definition={profile=profile,zcl_clusters={
zcl.cluster_attribute(legacy and 0x0400 or 0xFCC0,legacy and 0 or 0x0112,{
name="lumi_motion_light",read_only=true,read_on_configure=false,
emit=lumi_motion_lux(default_interval,legacy),}),
zcl.cluster_attribute(legacy and 0x0000 or 0xFCC0,legacy and 0xFF01 or 0x00F7,{
name="lumi_motion_diagnostics",read_only=true,read_on_configure=false,
emit=lumi_motion_diagnostics(temp_emit,interval_emit,p1,restart_emit),}),}}
if legacy then
definition.zcl_clusters[#definition.zcl_clusters+1]=lumi_struct_mapping(restart_emit)
definition.zcl_clusters[#definition.zcl_clusters+1]=zcl.cluster_attribute(0x0406,0,{
name="lumi_occupancy",read_only=true,read_on_configure=false,
emit=lumi_occupancy,})
else
local battery=zcl.battery({read_on_configure=false,read_only=true})
battery.minimum_interval,battery.maximum_interval,battery.reportable_change=nil,nil,nil
definition.zcl_clusters[#definition.zcl_clusters+1]=battery
definition.zcl_clusters[#definition.zcl_clusters+1]=zcl.cluster_attribute(0xFCC0,0x0102,{
name=interval_name,mfg_code=0x115F,read_only=true,read_on_configure=true,
emit=interval_emit,from_device=lumi_number,
handler=function(device,value)device:set_field("__lumi_detection_interval",value)end,
})
definition.zcl_clusters[#definition.zcl_clusters+1]=zcl.cluster_attribute(0x0001,0x0020,{
name="lumi_battery_voltage",read_only=true,read_on_configure=true,
emit=function(_,value)
local raw=lumi_number(value)
if raw==255 then return end
return{capabilities.battery.battery(battery_percent_from_voltage(raw*100)),
capabilities.voltageMeasurement.voltage({value=raw/10,unit="V"})}
end,
})
end
return definition
end
local motion_aq2=lumi_motion_definition("safety-aqara-motion-m11",emit.aqM11DeviceTemp("C"),nil,nil,nil,nil,emit.aqM11Restarts())
local motion_t1=lumi_motion_definition("safety-aqara-motion-t1",emit.aqT1DeviceTemp("C"),emit.aqT1Interval("s"),"aq_t_one_interval",60,nil,emit.aqT1Restarts())
local motion_e1=lumi_motion_definition("safety-aqara-motion-e1",emit.aqE1DeviceTemp("C"),emit.aqE1Interval("s"),"aq_e_one_interval",60,nil,emit.aqE1Restarts())
local motion_p1=lumi_motion_definition("safety-aqara-motion-p1",emit.aqP1DeviceTemp("C"),emit.aqP1Interval("s"),"aq_p_one_interval",30,true)
motion_p1.zcl_clusters[#motion_p1.zcl_clusters+1]=zcl.cluster_attribute(0xFCC0,0x010C,{
name="aq_p_one_sensitivity",data_type=data_types.Uint8,write_type=data_types.Uint8,
mfg_code=0x115F,read_on_configure=true,emit=emit.aqP1Sensitivity(),
from_device=function(value)return({[1]="low",[2]="medium",[3]="high"})[lumi_number(value)]end,
to_device=function(value)return({low=1,medium=2,high=3})[value]end,
})
motion_p1.zcl_clusters[#motion_p1.zcl_clusters+1]=zcl.cluster_attribute(0xFCC0,0x0152,{
name="aq_p_one_indicator",data_type=data_types.Uint8,write_type=data_types.Uint8,
mfg_code=0x115F,read_on_configure=true,emit=emit.aqP1Indicator(),
from_device=function(value)return lumi_number(value)==1 and"on"or"off"end,
to_device=function(value)return({on=1,off=0})[value]end,
})
local function lumi_on_off_contact()
return zcl.switch("contact",{
emit=emit.contact(),
read_only=true,})
end
local old_lumi_contact={
profile="safety-contact-battery-voltage",
zcl_clusters={
lumi_on_off_contact(),
zcl.cluster_attribute(LUMI_BASIC_CLUSTER,LUMI_BASIC_ATTR,{
name="lumi_basic",
emit=lumi_basic_events,
read_only=true,}),},}
local lumi_ac01_contact={
profile="safety-contact-tamper-battery-voltage",
zcl_clusters={
lumi_on_off_contact(),
zcl.tamper(),
zcl.cluster_attribute(LUMI_BASIC_CLUSTER,LUMI_BASIC_ATTR,{
name="lumi_basic",
emit=lumi_basic_events,
read_only=true,}),
zcl.battery(),
zcl.battery_voltage(),},}
local lumi_acn001_contact={
profile="safety-contact-battery-low-battery-voltage",
zcl_clusters={
zcl.contact(),
zcl.battery_low(),
zcl.battery(),
zcl.battery_voltage(),},}
local lumi_agl02_contact={
profile="safety-contact-battery-voltage",
zcl_clusters={
zcl.contact(),
zcl.battery(),
zcl.battery_voltage(),},}
local water_battery_low_battery_voltage={
profile="safety-water-leak-battery-low-battery-voltage",
zcl_clusters={
zcl.water(),
zcl.battery_low(),
zcl.cluster_attribute(LUMI_BASIC_CLUSTER,LUMI_BASIC_ATTR,{
name="lumi_basic",
emit=lumi_basic_events,
read_only=true,}),
zcl.battery(),
zcl.battery_voltage(),},}
local water_tamper_battery_low_battery_voltage={
profile="safety-water-leak-tamper-battery-low-battery-voltage",
zcl_clusters={
zcl.water(),
zcl.tamper(),
zcl.battery_low(),
zcl.cluster_attribute(LUMI_BASIC_CLUSTER,LUMI_BASIC_ATTR,{
name="lumi_basic",
emit=lumi_basic_events,
read_only=true,}),
zcl.battery(),
zcl.battery_voltage(),},}
local dimmer_light={
profile="lights-dimmer",
zcl_clusters={
zcl.switch(),
zcl.level(),},}
local switch_1={
profile="switches-switch-1",
zcl_clusters={
zcl.switch(),},}
register_device_definition(temp_humidity_lumi_basic,{
device_helpers.create_fingerprint("LUMI","lumi.sens"),
device_helpers.create_fingerprint("LUMI","lumi.sensor_ht"),})
register_device_definition(temp_humidity_pressure,{
device_helpers.create_fingerprint("LUMI","lumi.weather"),})
register_device_definition(aqara_t1_ht,{
device_helpers.create_fingerprint("LUMI","lumi.sensor_ht.agl02"),})
register_device_definition(illuminance,{
device_helpers.create_fingerprint("LUMI","lumi.sen_ill.agl01"),
device_helpers.create_fingerprint("LUMI","lumi.sen_ill.mgl01"),})
register_device_definition(motion,{
device_helpers.create_fingerprint("LUMI","lumi.sensor_motion"),})
register_device_definition(motion_p1,{
device_helpers.create_fingerprint("LUMI","lumi.motion.ac02"),})
register_device_definition(motion_e1,{
device_helpers.create_fingerprint("LUMI","lumi.motion.acn001"),})
register_device_definition(motion_t1,{
device_helpers.create_fingerprint("LUMI","lumi.motion.agl02"),})
register_device_definition(motion_aq2,{
device_helpers.create_fingerprint("LUMI","lumi.sensor_motion.aq2"),})
register_device_definition(lumi_ac01_contact,{
device_helpers.create_fingerprint("LUMI","lumi.magnet.ac01"),})
register_device_definition(lumi_acn001_contact,{
device_helpers.create_fingerprint("LUMI","lumi.magnet.acn001"),})
register_device_definition(lumi_agl02_contact,{
device_helpers.create_fingerprint("LUMI","lumi.magnet.agl02"),})
register_device_definition(old_lumi_contact,{
device_helpers.create_fingerprint("LUMI","lumi.sensor_magnet"),
device_helpers.create_fingerprint("LUMI","lumi.sensor_magnet.aq2"),})
register_device_definition(water_battery_low_battery_voltage,{
device_helpers.create_fingerprint("LUMI","lumi.flood.acn001"),
device_helpers.create_fingerprint("LUMI","lumi.sensor_wleak.aq1"),})
register_device_definition(water_tamper_battery_low_battery_voltage,{
device_helpers.create_fingerprint("LUMI","lumi.flood.agl02"),})
return{
id="zcl.sensors.aqara_lumi",
registrations=device_definitions,}
