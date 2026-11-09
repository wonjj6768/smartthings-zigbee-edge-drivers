local c,l,f,e,I=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.data_types",require"st.zigbee.cluster_base"local v,s=f.definition_registry()local g={
from=function(value)return value>=0 and value<=100 and 100-value or nil end,
to=function(value)return 100-value end
}
local B={from=function(value)
if value<0 or value>100 then return nil end
return value==0 and"open"or value==100 and"closed"or"partially open"
end}
local H={profile="covers-somfy-glydea2",
component_to_endpoint=function()return 1 end,
parent_refresh=function(a)
c.read_attribute(a,258,8,1)for _,n in ipairs{33,32}do pcall(c.read_attribute,a,1,n,232)end
end,
zcl_clusters={c.cover_position{endpoint=1,component="main",minimum_interval=1,maximum_interval=65000,reportable_change=1,converter=g},c.window_shade_state{endpoint=1,component="main",configure_reporting=false,read_on_configure=false,converter=B},c.cover_state{endpoint=1,component="main"},c.battery{endpoint=232,component="main",minimum_interval=3600,maximum_interval=65000,reportable_change=10,
from_device=function(value,_,k)if k.raw_value~=255 then return value end end
}},
configure=function(x,a)
local p=x.environment_info.hub_zigbee_eui
c.bind_cluster(a,258,p,1)c.bind_cluster(a,1,p,232)
end
}s(H,{f.create_fingerprint("SOMFY","Glydea 2 Ultra WF Curtain")})
local function m(a,_,value,k)
local q=value or 3
if type(q)~="number"or q<1 or q>30 or q%1~=0 then return false end
return c.send_raw_cluster_command(a,3,0,string.char(q,0),k.endpoint or 1)
end
local G={profile="covers-allesin-roller-shade",zcl_clusters={c.cover_position{endpoint=1,component="main",minimum_interval=1,maximum_interval=65000,reportable_change=1,converter=g},c.window_shade_state{endpoint=1,component="main",configure_reporting=false,read_on_configure=false,converter=B},c.cover_state{endpoint=1,component="main"},c.battery{endpoint=1,component="main",scale=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
converter={from=function(value)return value<255 and value or nil end}
},c.cluster_attribute(3,nil,{name="allesin_identify",endpoint=1,component="main",write_only=true,sender=m})},capability_commands={{capability_id="concertmirror08464.allesinIdentify",command_name="identify",argument_name="seconds",mapping_name="allesin_identify"}},
configure=function(x,a)
local p=x.environment_info.hub_zigbee_eui
c.bind_cluster(a,258,p,1)c.bind_cluster(a,1,p,1)
end
}s(G,{f.create_fingerprint("Aubor","TLSR82xx")})
local function h(V,o,n,S,P,F)
local E={}for W,value in pairs(P)do E[value]=W end
local z=c.cluster_attribute(o,n,{name=V,endpoint=1,component="main",emit=S,data_type=e.Enum8,write_type=e.Enum8,read_only=F,read_on_configure=false,converter={
from=function(value)
if type(value)=="table"then value=value.value end
return P[value]
end,
to=function(value)return E[value]end
}})if not F then
z.sender=function(a,_,value,k)
local L=I.write_attribute(a,e.ClusterId(o),e.AttributeId(n),e.Enum8(E[value]))if o==57345 then L.body.zcl_header.frame_ctrl:set_disable_default_response()end
a:send(L:to_endpoint(k.endpoint or 1))return true
end
end
return z
end
local y=h("zm108m_switch_type",57345,53296,l.zm108mSwitchType(),{[0]="flip-switch",[1]="sync-switch",[2]="button-switch",[3]="button2-switch"})
local function j(value,a)
if value<0 or value>100 then return nil end
return a.preferences.invertCover==true and 100-value or value
end
local K={profile="covers-moes-zm108m",zcl_clusters={c.tuya_magic_packet{read_on_configure=false},c.cluster_attribute(258,8,{name="cover_position",endpoint=1,data_type=e.Uint8,emit=l.shade_level(),read_on_configure=false,converter={from=j,to=j}}),c.cluster_attribute(258,8,{name="window_shade_state",endpoint=1,data_type=e.Uint8,emit=l.shade_state(),read_only=true,read_on_configure=false,
converter={from=function(value,a)
local g=j(value,a)if g==nil then return nil end
return g==0 and"closed"or g==100 and"open"or"partially open"
end}
}),c.cover_state{endpoint=1},h("zm108m_moving",258,61440,l.zm108mMoving(),{[0]="UP",[1]="STOP",[2]="DOWN"},true),h("zm108m_motor_reversal",258,61442,l.zm108mMotorReversal(),{[0]="OFF",[1]="ON"}),h("zm108m_calibration",258,61441,l.zm108mCalibration(),{[0]="ON",[1]="OFF"}),c.cluster_attribute(258,61443,{name="zm108m_calibration_time",endpoint=1,read_only=true,read_on_configure=false,data_type=e.Uint16,scale=10,emit=l.zm108mCalibrationTime()}),h("zm108m_indicator_mode",6,32769,l.zm108mIndicatorMode(),{[0]="off",[1]="off/on",[2]="on/off",[3]="on"}),h("zm108m_backlight_mode",6,20480,l.zm108mBacklightMode(),{[0]="OFF",[1]="ON"}),y},
parent_refresh=function(a)
for _,T in ipairs{{258,8},{258,61440},{258,61441},{258,61442},{258,61443},{6,32769},{6,20480},{57345,53296}}do
c.read_attribute(a,T[1],T[2],1)end
return true
end
}s(K,{f.create_fingerprint("_TZ3210_mldzab8w","TS130F")})
local function d(a)
return(a:get_field"axis_gear_version"or 0)>=1093
end
local function w(a)
c.read_attribute(a,0,16384,1)c.read_attribute(a,1,33,1)c.read_attribute(a,d(a)and 258 or 8,d(a)and 8 or 0,1)
end
local C,i=l.shade_level(),l.shade_state()
local function t(a,_,value)
if type(value)~="number"or value<0 or value>100 or value%1~=0 then return false end
if d(a)then
local r=a:get_latest_state("main","windowShadeLevel","shadeLevel")or 0
a:emit_event(i(a,value>r and"opening"or"closing"))return c.send_raw_cluster_command(a,258,5,string.char(100-value),1)end
return c.send_raw_cluster_command(a,8,4,string.char(math.floor(value*254/100+0.5),0,0,0,0),1)
end
local function N(a,z,value)
if value=="open"or value=="close"then
if not d(a)then return t(a,z,value=="open"and 100 or 0)end
a:emit_event(i(a,value=="open"and"opening"or"closing"))return c.send_raw_cluster_command(a,258,value=="open"and 0 or 1,"",1)end
if value~="stop"then return false end
if d(a)then
local D=a:get_latest_state("main","windowShade","windowShade")if D=="opening"or D=="closing"then return c.send_raw_cluster_command(a,258,2,"",1)end
return c.read_attribute(a,258,8,1)end
a.thread:call_with_delay(5,function()c.read_attribute(a,8,0,1)end,"AXIS pause position")
return true
end
local function u(value)
return value==0 and"closed"or value>=99 and"open"or"partially open"
end
local function A(a,value)
local D=u(value)if d(a)then
local r=a:get_latest_state("main","windowShadeLevel","shadeLevel")or 0
if value~=r then D=value>r and"opening"or"closing"end
end
return{C(a,value),i(a,D)}
end
local O={profile="covers-axis-gear",magic_packet=false,initial_custom_state_query=false,
component_to_endpoint=function()return 1 end,
parent_refresh=w,zcl_clusters={c.cluster_attribute(0,16384,{name="axis_gear_version",endpoint=1,data_type=e.CharString,read_only=true,read_on_configure=false,read_on_refresh=false,
handler=function(a,value)
local M=type(value)=="string"and tonumber(value:sub(-4))or nil
local J=(M or 0)>=1093
local R=d(a)~=J
a:set_field("axis_gear_version",M,{persist=true})if R then c.read_attribute(a,J and 258 or 8,J and 8 or 0,1)end
end
}),c.cluster_attribute(8,0,{name="axis_gear_level",endpoint=1,data_type=e.Uint8,read_only=true,read_on_configure=false,read_on_refresh=false,emit=A,
converter={from=function(value)if value<=254 then return math.floor(value*100/254+0.5)end end},
minimum_interval=1,maximum_interval=3600,reportable_change=1}),c.cover_position{endpoint=1,read_on_configure=false,read_on_refresh=false,sender=t,converter=g,
from_device=function(value,a)if d(a)then return g.from(value)end end,
minimum_interval=1,maximum_interval=65000,reportable_change=1},c.window_shade_state{endpoint=1,configure_reporting=false,read_on_configure=false,read_on_refresh=false,
from_device=function(value,a)
local Q=g.from(value)if d(a)and Q~=nil then return u(Q)end
end
},c.cover_state{endpoint=1,sender=N},c.battery{endpoint=1,read_on_configure=false,read_on_refresh=false,
from_device=function(value,_,k)if k.raw_value~=255 then return value end end,
minimum_interval=3600,maximum_interval=65000,reportable_change=10}},
configure=function(x,a)
for _,o in ipairs{8,258,1}do c.bind_cluster(a,o,x.environment_info.hub_zigbee_eui,1)end
w(a)
end
}s(O,{f.create_fingerprint("AXIS","Gear")})c.attach_reporting_capabilities(v,{{1,"rpt-gtd"},{2,"rpt-tqk"},{4,"rpt-gaw"}})return{id="zcl.covers.z2m_absorption",registrations=v}
