local d,f,g=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family"local n,c=g.create_fingerprint,require"st.zigbee.data_types"
local e,l=g.definition_registry()
local function b(a,_,m)
if m and m.raw_value==255 then return nil end
return a
end
local function h(j)
j.from_device=j.from_device or b
return d.battery(j)
end
local k={profile="safety-motion-zigbeetlc-zg204zv",advanced_remote=true,remote_action_emit_name="zgZvAction",capability_commands={{capability_id="concertmirror08464.zgZvIdentify",command_name="setIdentifyTime",argument_name="identifyTime",mapping_name="zgzv_identify"}},zcl_clusters={d.cluster_attribute(3,0,{name="zgzv_identify",endpoint=1,write_only=true,suppress_optimistic_state=true,tx_command_id=0,
to_device=function(a)
if type(a)~="number"or a%1~=0 or a<1 or a>30 then return nil end
return string.pack("<I2",a)
end}),
d.occupancy{endpoint=1,emit=f.motion(),minimum_interval=0,maximum_interval=3600,
reportable_change=0,from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&1)~=0
end},
d.illuminance{endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=5},h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10},d.power_configuration_battery_voltage{name="battery_voltage",endpoint=1,emit=f.voltage(),scale=10,read_only=true,read_on_configure=true,from_device=b},d.on_off{endpoint=1,emit=f.switch(),minimum_interval=0,maximum_interval=3600,reportable_change=0},d.cluster_attribute(1030,16,{name="zgzv_hold_time",endpoint=1,data_type=c.Uint16,read_only=false,read_on_configure=true,emit=f.zgZvHoldTime()}),d.cluster_attribute(1030,18,{name="zgzv_motion_sensitivity",endpoint=1,data_type=c.Uint8,read_only=false,read_on_configure=true,emit=f.zgZvMotionSensitivity()}),d.cluster_attribute(6,16387,{name="zgzv_power_on_behavior",endpoint=1,data_type=c.Enum8,read_only=false,read_on_configure=true,emit=f.zgZvPowerOnBehavior(),
from_device=function(a)
if type(a)=="table"then a=a.value end
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[a]
end,
to_device=function(a)return({off=0,on=1,toggle=2,previous=255})[a]end})
}}l(k,{n("Sonoff","ZG-204ZV1-z"),n("Sonoff","ZG-204ZV2-z")})local i={profile="safety-motion-zigbeetlc-zg204zv-th",advanced_remote=true,remote_action_emit_name="zgZvThAction",capability_commands={{capability_id="concertmirror08464.zgZvThIdentify",command_name="setIdentifyTime",argument_name="identifyTime",mapping_name="zgzv_th_identify"}},zcl_clusters={d.cluster_attribute(3,0,{name="zgzv_th_identify",endpoint=1,write_only=true,suppress_optimistic_state=true,tx_command_id=0,
to_device=function(a)
if type(a)~="number"or a%1~=0 or a<1 or a>30 then return nil end
return string.pack("<I2",a)
end}),
d.occupancy{endpoint=1,emit=f.motion(),minimum_interval=0,maximum_interval=3600,
reportable_change=0,from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&1)~=0
end},
d.illuminance{endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=5},h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10},d.power_configuration_battery_voltage{name="battery_voltage",endpoint=1,emit=f.voltage(),scale=10,read_only=true,read_on_configure=true,from_device=b},d.on_off{endpoint=1,emit=f.switch(),minimum_interval=0,maximum_interval=3600,reportable_change=0},d.cluster_attribute(1030,16,{name="zgzv_th_hold_time",endpoint=1,data_type=c.Uint16,read_only=false,read_on_configure=true,emit=f.zgZvThHoldTime()}),d.cluster_attribute(1030,18,{name="zgzv_th_motion_sensitivity",endpoint=1,data_type=c.Uint8,read_only=false,read_on_configure=true,emit=f.zgZvThMotionSensitivity()}),d.cluster_attribute(6,16387,{name="zgzv_th_power_on_behavior",endpoint=1,data_type=c.Enum8,read_only=false,read_on_configure=true,emit=f.zgZvThPowerOnBehavior(),
from_device=function(a)
if type(a)=="table"then a=a.value end
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[a]
end,
to_device=function(a)return({off=0,on=1,toggle=2,previous=255})[a]end}),
d.temperature{endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=10},d.humidity{endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100}}}l(i,{n("Sonoff","ZG-204ZV-z"),n("Sonoff","ZG-204ZV2-TH-z")})d.attach_reporting_capabilities(e,{{1,"rpt-zsq"},{2,"rpt-zeg"}})return{id="zcl.sensors.zigbeetlc_zgzv_additions",registrations=e}
