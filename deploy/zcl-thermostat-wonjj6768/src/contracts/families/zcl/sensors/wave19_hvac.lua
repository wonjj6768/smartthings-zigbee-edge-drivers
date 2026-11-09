local i,J,n,B,b,E=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.capabilities",require"st.zigbee.data_types",require"st.zigbee.device_management"local q,h=n.definition_registry()local a,d,Z,ab,L,H,T,Q,s,r,t,w,l,k,g,p=12,513,61440,61441,61442,61443,61444,61445,61446,61447,61448,61449,0,1,18,28















local function j(capability_id)
return assert(J[capability_id],"missing Wave19 PirogovX emitter: "..capability_id)()
end
local G=j"pirogovMideaSystemMode"
local function af(c)
if c==true then return true end
local Y=tonumber(c)return Y~=nil and Y~=0
end
local function y(c)
return af(c)and"ON"or"OFF"
end
local function z(c)
return c==true or c=="ON"
end
local function V(c,f)
local X=z(c)if f~=nil and type(f.emit_event)=="function"then
f:emit_event(G(f,X and"cool"or"off"))end
return X
end
local function e(c)
if type(c)~="number"or c<-273.15 then return nil end
return c
end
local function v(c)
if type(c)~="number"or c<16 or c>30 then return nil end
local A=math.floor((c*20)+0.5)/10
return math.floor(A+0.5)/2
end
local function m(S,ad)
return function(c)
return S[tonumber(c)]or ad
end
end
local function u(S)
return function(c)
return S[c]
end
end
local F,x,C,N,U,I,P,W,ac=m({[0]="off",[1]="auto",[2]="cool",[3]="heat",[4]="dry",[5]="fan_only"},"auto"),m({[0]="off",[1]="auto",[3]="cool",[4]="heat",[7]="fan_only",[8]="dry"},nil),u{off=0,auto=1,cool=3,heat=4,fan_only=7,dry=8},m({[0]="auto",[1]="low",[2]="medium",[3]="high",[4]="quiet"},"auto"),u{auto=0,low=1,medium=2,high=3,quiet=4},m({[0]="off",[1]="horizontal",[2]="vertical",[3]="both"},"off"),u{off=0,horizontal=1,vertical=2,both=3},m({[0]="none",[1]="sleep",[2]="turbo"},"none"),u{none=0,sleep=1,turbo=2}
local function O(c)
if c==nil then return nil end
return tostring(c)
end
local function D(R,f)
for _,aa in ipairs{a,d}do
f:send(E.build_bind_request(f,aa,R.environment_info.hub_zigbee_eui,1))end
end
local o={profile="thermostats-wave19-pirogov-zb-midea-ac",package_group="wave19-hvac",configure=D,zcl_clusters={i.cluster_attribute(a,Z,{name="pirogov_midea_power",emit=j"pirogovMideaPower",data_type=b.Boolean,write_type=b.Boolean,from_device=y,to_device=V,endpoint=1}),i.cluster_attribute(d,p,{name="pirogov_midea_system_mode",emit=j"pirogovMideaSystemMode",data_type=b.Enum8,write_type=b.Enum8,from_device=x,to_device=C,endpoint=1}),i.cluster_attribute(a,ab,{name="pirogov_midea_analog_system_mode_report",emit=j"pirogovMideaSystemMode",from_device=F,endpoint=1,read_only=true}),i.cluster_attribute(a,L,{name="pirogov_midea_fan_mode",emit=j"pirogovMideaFanMode",data_type=b.Uint8,write_type=b.Uint8,from_device=N,to_device=U,endpoint=1}),i.cluster_attribute(a,H,{name="pirogov_midea_swing_mode",emit=j"pirogovMideaSwingMode",data_type=b.Uint8,write_type=b.Uint8,from_device=I,to_device=P,endpoint=1}),i.cluster_attribute(a,T,{name="pirogov_midea_preset",emit=j"pirogovMideaPreset",data_type=b.Uint8,write_type=b.Uint8,from_device=W,to_device=ac,endpoint=1}),i.cluster_attribute(a,Q,{name="pirogov_midea_display",emit=j"pirogovMideaDisplay",data_type=b.Boolean,write_type=b.Boolean,from_device=y,to_device=z,endpoint=1}),i.cluster_attribute(d,l,{name="pirogov_midea_standard_local_temperature_report",emit=J.temperature"C",data_type=b.Int16,scale=100,from_device=e,endpoint=1,read_only=true}),i.cluster_attribute(a,s,{name="pirogov_midea_analog_local_temperature_report",emit=J.temperature"C",endpoint=1,read_only=true}),i.cluster_attribute(d,k,{name="pirogov_midea_outdoor_temperature",emit=j"pirogovMideaOutdoorTemperature",data_type=b.Int16,scale=100,from_device=e,endpoint=1,read_only=true}),i.cluster_attribute(a,r,{name="pirogov_midea_analog_outdoor_temperature_report",emit=j"pirogovMideaOutdoorTemperature",endpoint=1,read_only=true}),i.cluster_attribute(d,g,{name="current_heating_setpoint",emit=J.heating_setpoint"C",data_type=b.Int16,write_type=b.Int16,scale=100,from_device=e,to_device=v,endpoint=1}),i.cluster_attribute(a,t,{name="pirogov_midea_analog_target_temperature_report",emit=J.heating_setpoint"C",endpoint=1,read_only=true}),i.cluster_attribute(a,w,{name="pirogov_midea_firmware_version",emit=j"pirogovMideaFirmwareVersion",from_device=O,endpoint=1,read_only=true})}}o.heating_setpoint_range={minimum=16,maximum=30,step=1,unit="C"}
o.runtime_start=function(f)
f:emit_component_event({id="main"},B.thermostatHeatingSetpoint.heatingSetpointRange{value={minimum=o.heating_setpoint_range.minimum,maximum=o.heating_setpoint_range.maximum,step=o.heating_setpoint_range.step},unit=o.heating_setpoint_range.unit})
end
h(o,{n.create_fingerprint("PirogovX","ZB-MIDEA-AC")})local K={profile="thermostats-topband-trv602",magic_packet=false,component_to_endpoint_map={main=1},heating_setpoint_range={minimum=7,maximum=30,step=0.5,unit="C"},capability_commands={{capability_id="concertmirror08464.trv602Identify",command_name="identify",mapping_name="trv602_identify",value=true}},zcl_clusters={i.battery{endpoint=1,scale=2,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true},i.switch{endpoint=1,minimum_interval=0,maximum_interval=65000,reportable_change=1,read_on_configure=true},i.local_temperature{endpoint=1,read_only=true,minimum_interval=0,maximum_interval=3600,reportable_change=10,read_on_configure=true},i.heating_setpoint{endpoint=1,minimum_interval=0,maximum_interval=3600,reportable_change=10,read_on_configure=true},i.system_mode{endpoint=1,minimum_interval=0,maximum_interval=3600,reportable_change=0,read_on_configure=true,
to_device=function(c)return({off=0,heat=4})[c]end},
i.thermostat_operating_state{endpoint=1,read_only=true,minimum_interval=0,maximum_interval=3600,reportable_change=0,read_on_configure=true},i.cluster_attribute(6,16387,{name="trv602_power_behavior",endpoint=1,data_type=b.Enum8,read_on_configure=true,
from_device=function(c)
c=type(c)=="table"and c.value or c
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[c]
end,
to_device=function(c)return({off=0,on=1,toggle=2,previous=255})[c]end,
emit=J.trv602PowerBehavior()}),i.cluster_attribute(3,nil,{name="trv602_identify",endpoint=1,write_only=true,
sender=function(f)
return i.send_raw_cluster_command(f,3,0,string.pack("<I2",f.preferences.identifyTimeout or 3),1)
end})
},
configure=function(R,f)
for _,ae in ipairs{1,6,513}do i.bind_cluster(f,ae,R.environment_info.hub_zigbee_eui,1)end
end,
runtime_start=function(f)
f:emit_component_event({id="main"},B.thermostatMode.supportedThermostatModes{"off","heat"})
end
}h(K,{n.create_fingerprint("Topband","TRV602WZ")})i.attach_reporting_capabilities(q,{{2,"rpt-txc"}})return{id="zcl.sensors.wave19_hvac",registrations=q}
