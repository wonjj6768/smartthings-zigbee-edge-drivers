local g,B,f,c,j,D=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.data_types",require"st.capabilities",require"st.zigbee.device_management"local p,s=f.definition_registry()local d,q,b,o,m=4742,1030,64529,15,"__sonoff_safety_power_source_mode"




local function h(Z)
return assert(B[Z],"missing SONOFF Safety emitter: "..tostring(Z))()
end
local function G(a)
if type(a)=="table"and a.value~=nil then
a=a.value
end
if type(a)=="number"then
return a%2==1
end
return a==true
end
local function i(Q)
local M={}for ac,a in pairs(Q)do
M[a]=ac
end
return{
from=function(a)
return Q[a]
end,
to=function(a)
return M[a]
end
}
end
local function l(v)
v.minimum_interval=nil
v.maximum_interval=nil
v.reportable_change=nil
v.read_on_configure=false
return v
end
local function n(_,a)
if a then
return j.batteryLevel.battery.critical()end
return j.batteryLevel.battery.normal()
end
local function r()
return{
from=function(a)
if a==true or a==1 then return"on"end
return"off"
end,
to=function(a)
if a=="on"then return true end
if a=="off"then return false end
end
}
end
local function E(_,a)
if a=="battery"then
return j.powerSource.powerSource.battery()end
if a=="dc"then
return j.powerSource.powerSource.dc()end
end
local function w(e,a,k)
if type(e)=="table"and type(e.set_field)=="function"then
e:set_field(m,a,{persist=false})end
if a=="dc"and type(k)=="table"and type(k.zcl_clusters)=="table"then
g.read_named_attribute(e,k.zcl_clusters,"battery",{endpoint=k.endpoint or 1})end
end
local J=B.battery()
local function x(e,a,...)
local K=type(e)=="table"and type(e.get_field)=="function"and e:get_field(m)or nil
if K=="dc"and a~=100 then
return nil
end
return J(e,a,...)
end
local function A(e,_,a,k)
local L,R=a==true or a=="on"or a=="siren"or a=="both"or a=="strobe",a==false or a=="off"if not L and not R then return false end
local ab={siren={sound="on",light="off"},strobe={sound="off",light="on"},both={sound="on",light="on"}}local S=ab[a]if S~=nil then
local F=k and k.zcl_clusters or nil
if type(F)~="table"then return false end
local t={component_id=k.component_id,endpoint=k.endpoint}local I,H=g.send_named_command(e,F,"sonoff_safety_alarm_sound_enable",S.sound,t),g.send_named_command(e,F,"sonoff_safety_alarm_light_enable",S.light,t)if not I or not H then return false end
end
return g.send_raw_cluster_command(e,b,o,string.char(L and 0 or 1),k and k.endpoint or 1,nil,nil,true)
end
local function z(Y,e)
e:send(D.build_bind_request(e,b,Y.environment_info.hub_zigbee_eui,1))
end
local function u(_,e)
g.read_attribute(e,b,8192,1,d)
end
local V,U={profile="sonoff-safety-occupancy-06p",zcl_clusters={g.occupancy_sensing{name="occupancy",emit=B.occupancy(),from_device=G,read_only=true,read_on_configure=false},g.cluster_attribute(q,32,{name="sonoff_safety_occupancy_timeout",emit=h"sonoffSafetyOccupancyTimeout",data_type=c.Uint16,write_type=c.Uint16,numeric_range={minimum=15,maximum=65535,step=1,unit="s"},read_on_configure=true}),g.cluster_attribute(q,34,{name="sonoff_safety_occupancy_sensitivity",emit=h"sonoffSafetyOccupancySensitivity",converter=i{[1]="low",[2]="medium",[3]="high"},data_type=c.Uint8,write_type=c.Uint8,read_on_configure=true}),g.cluster_attribute(b,8193,{name="sonoff_safety_illumination",emit=h"sonoffSafetyIllumination",converter=i{[0]="dim",[1]="bright"},data_type=c.Uint8,mfg_code=d,read_only=true,read_on_configure=false})}},{profile="sonoff-safety-water-05p",zcl_clusters={l(g.water()),l(g.battery_low{emit=n}),g.battery{minimum_interval=3600,maximum_interval=65000,reportable_change=10}}}local T={profile="sonoff-safety-contact-04p",zcl_clusters={l(g.contact()),l(g.battery_low{emit=n}),g.cluster_attribute(b,8192,{name="sonoff_safety_tamper",emit=B.tamper(),
from_device=function(a)
return a==true or a==1
end,
data_type=c.Uint8,mfg_code=d,read_only=true,read_on_configure=true}),g.battery{minimum_interval=3600,maximum_interval=7200},g.battery_voltage{minimum_interval=3600,maximum_interval=7200,reportable_change=100}}}local O={profile="sonoff-safety-contact-04p",zcl_clusters={l(g.contact()),l(g.battery_low{emit=n}),g.cluster_attribute(b,8192,{name="sonoff_safety_tamper",emit=B.tamper(),
from_device=function(a)
return a==true or a==1
end,
data_type=c.Uint8,read_only=true,read_on_configure=false}),g.battery{minimum_interval=3600,maximum_interval=7200},g.power_configuration_battery_voltage{name="battery_voltage",emit=B.voltage(),scale=10,read_only=true,read_on_configure=true}},configure=u}local W={profile="sonoff-safety-siren-09p",sonoff_safety_snzb_09p=true,alarm_command_modes=true,zcl_clusters={g.cluster_attribute(b,nil,{name="alarm",endpoint=1,write_only=true,sender=A}),g.cluster_attribute(b,8238,{name="sonoff_safety_alarm_status",emit=B.alarm(),converter=i{[0]="off",[1]="siren",[2]="siren"},data_type=c.Uint8,read_only=true,read_on_configure=false,read_on_refresh=false}),g.cluster_attribute(b,36,{name="sonoff_safety_power_source",emit=E,converter=i{[0]="battery",[1]="dc"},handler=w,data_type=c.Enum8,read_only=true,read_on_configure=true}),g.battery{emit=x,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_only=true},g.cluster_attribute(b,8230,{name="sonoff_safety_alarm_sound_enable",emit=h"sonoffSafetyAlarmSoundEnable",converter=r(),data_type=c.Boolean,write_type=c.Boolean,mfg_code=d,read_on_configure=true}),g.cluster_attribute(b,8226,{name="sonoff_safety_alarm_light_enable",emit=h"sonoffSafetyAlarmLightEnable",converter=r(),data_type=c.Boolean,write_type=c.Boolean,mfg_code=d,read_on_configure=true}),g.cluster_attribute(b,8192,{name="sonoff_safety_tamper",emit=B.tamper(),
from_device=function(a)return a==true or a==1 end,
data_type=c.Uint8,mfg_code=d,read_only=true,read_on_configure=true}),g.cluster_attribute(b,8227,{name="sonoff_safety_alarm_sound_type",emit=h"sonoffSafetyAlarmSoundType",converter=i{[0]="siren_classic",[1]="siren_steady",[3]="siren_rising",[5]="siren_warning",[6]="siren_rapid",[8]="siren_emergency",[2]="tone_chirp",[4]="tone_hi_lo",[7]="tone_intermittent",[9]="tone_pulse"},data_type=c.Enum8,write_type=c.Enum8,read_on_configure=true}),g.cluster_attribute(b,8228,{name="sonoff_safety_alarm_volume",emit=h"sonoffSafetyAlarmVolume",converter=i{[0]="low",[1]="medium",[2]="high",[3]="max"},data_type=c.Enum8,write_type=c.Enum8,read_on_configure=true}),g.cluster_attribute(b,8229,{name="sonoff_safety_alarm_duration",emit=h"sonoffSafetyAlarmDuration",data_type=c.Uint16,write_type=c.Uint16,numeric_range={minimum=1,maximum=900,step=1,unit="s"},read_on_configure=true})},configure=z}
g.register_cluster_command_handler(b,o,function(e,aa,P)
if aa.sonoff_safety_snzb_09p~=true then return false end
local X=P and P.body and P.body.zcl_body or nil
local C=type(X)=="table"and X.body_bytes or nil
if type(C)~="string"or #C<2 or string.byte(C,1)~=4 then
return false
end
local y=string.byte(C,2)local N
if y==0 then
N=j.alarm.alarm.off()elseif y==1 or y==2 then
N=j.alarm.alarm.siren()else
return false
end
e:emit_component_event({id="main"},N)return true
end)
s(V,{f.create_fingerprint("SONOFF","SNZB-06P")})s(U,{f.create_fingerprint("SONOFF","SNZB-05P")})s(T,{f.create_fingerprint("eWeLink","SNZB-04P"),f.create_fingerprint("SONOFF","SNZB-04P")})s(O,{f.create_fingerprint("SONOFF","SNZB-04PR2")})s(W,{f.create_fingerprint("SONOFF","SNZB-09P")})g.attach_reporting_capabilities(p,{{2,"rpt-sqg"},{3,"rpt-smj"},{4,"rpt-siu"},{5,"rpt-smjs"}})return{id="zcl.sensors.sonoff_safety",registrations=p}
