local g,ad,t,H,w,b=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.zcl",require"st.zigbee.device_management",require"st.zigbee.data_types"local u,j=t.definition_registry()local O="concertmirror08464."
local function i(capability_id)
return assert(ad[capability_id],"missing Wave19 light emitter: "..capability_id)()
end
local function f(a,y,x)
local e=tonumber(a)if e==nil then return nil end
return math.max(y,math.min(x,math.floor(e+0.5)))
end
local function n(a)
local e=tonumber(a)if e==nil then return nil end
return e/10
end
local function q(a)
local e=tonumber(a)if e==nil then return nil end
if e>=6553.5 then return 65535 end
return math.max(0,math.min(65534,math.floor(e*10+0.5)))
end
local function z(ab,m,A,I)
if m~=g.CLUSTER_ON_OFF then return nil,nil,true end
local P,ac,T=H.resolve_rd1p_rotary_action(ab,m,A,I)if P=="pressed"then return nil,"switch2",true end
return P,"switch2",T
end
local V={profile="lights-wave19-candeo-rd1pv2-dim",capability_commands={{capability_id="concertmirror08464.candeoRotaryDimOnLevel",command_name="usePreviousOnLevel",mapping_name="candeoRotaryDim_on_level",value=255}},package_group="wave19-light",advanced_remote=true,unprefixed_remote_actions=true,remote_action_emit_name="candeoRotaryDimAction",standard_command_action_resolver=z,zcl_clusters={g.switch{endpoint=1,minimum_interval=0,maximum_interval=65000,reportable_change=1},g.level{endpoint=1,minimum_interval=1,maximum_interval=3600,reportable_change=1},g.power{endpoint=1,minimum_interval=5,maximum_interval=300,reportable_change=10},g.voltage{endpoint=1,minimum_interval=5,maximum_interval=600,reportable_change=500},g.current{endpoint=1,minimum_interval=5,maximum_interval=900,reportable_change=10},g.energy{endpoint=1,minimum_interval=5,maximum_interval=1800,reportable_change=50},g.cluster_attribute(g.CLUSTER_ON_OFF,32768,{name="candeoRotaryDim_extra_commands",endpoint=1,emit=i"candeoRotaryDimExtraCommands",
from_device=function(a)return a and"ON"or"OFF"end,
to_device=function(a)return a=="ON"end,
data_type=b.Boolean,write_type=b.Boolean,configure_reporting=false,read_on_configure=true}),g.cluster_attribute(g.CLUSTER_ON_OFF,16387,{name="candeoRotaryDim_power_behavior",endpoint=1,emit=i"candeoRotaryDimPowerBehavior",
from_device=function(a)
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[a]
end,
to_device=function(a)
return({off=0,on=1,toggle=2,previous=255})[a]
end,
data_type=b.Enum8,write_type=b.Enum8,read_on_configure=true}),g.cluster_attribute(g.CLUSTER_LEVEL_CONTROL,17,{name="candeoRotaryDim_on_level",endpoint=1,emit=i"candeoRotaryDimOnLevel",
from_device=function(a)return f(a,0,255)end,
to_device=function(a)return f(a,1,255)end,
numeric_range={minimum=0,maximum=255,step=1},data_type=b.Uint8,write_type=b.Uint8,read_on_configure=true}),g.cluster_attribute(g.CLUSTER_LEVEL_CONTROL,16384,{name="candeoRotaryDim_startup_level",endpoint=1,emit=i"candeoRotaryDimStartupLevel",
from_device=function(a)return f(a,0,255)end,
to_device=function(a)return f(a,0,255)end,
numeric_range={minimum=0,maximum=255,step=1},data_type=b.Uint8,write_type=b.Uint8,read_on_configure=true}),g.cluster_attribute(g.CLUSTER_LEVEL_CONTROL,16,{name="candeoRotaryDim_on_transition",endpoint=1,emit=i"candeoRotaryDimOnTransition",from_device=n,to_device=q,numeric_range={minimum=0,maximum=6553.5,step=0.1,unit="s"},data_type=b.Uint16,write_type=b.Uint16,read_on_configure=true}),g.cluster_attribute(g.CLUSTER_LEVEL_CONTROL,18,{name="candeoRotaryDim_off_transition",endpoint=1,emit=i"candeoRotaryDimOffTransition",from_device=n,to_device=q,numeric_range={minimum=0,maximum=6553.5,step=0.1,unit="s"},data_type=b.Uint16,write_type=b.Uint16,read_on_configure=true})},
configure=function(J,d)
for _,K in ipairs{{1,g.CLUSTER_ON_OFF},{1,g.CLUSTER_LEVEL_CONTROL},{1,g.CLUSTER_ELECTRICAL_MEASUREMENT},{1,g.CLUSTER_SIMPLE_METERING},{2,g.CLUSTER_ON_OFF},{2,g.CLUSTER_LEVEL_CONTROL}}do
d:send(w.build_bind_request(d,K[2],J.environment_info.hub_zigbee_eui,K[1]))end
end
}j(V,{t.create_fingerprint("Candeo","C-ZB-RD1Pv2-DIM")})local o,p,c,G,F=4648,64716,64717,1600,7000




local function u16le(a)
local e=f(a,0,65535)if e==nil then return nil end
return string.char(e%256,math.floor(e/256)%256)
end
local function u32le(a)
local e=f(a,0,0xFFFFFFFF)if e==nil then return nil end
return string.char(e%256,math.floor(e/256)%256,math.floor(e/65536)%256,math.floor(e/16777216)%256)
end
local function h(d,m,A,U,s)
return g.send_raw_cluster_command(d,m,A,U,s.endpoint or 1,nil,o,false)
end
local function C(d,_,a,s)
local L=f(a,120,4950)if L==nil then return false end
return h(d,p,8,string.char(0)..u32le(L)..u32le(0),s)
end
local function v(d,_,a,s)
local S=f(a,0,5000)if S==nil then return false end
return h(d,c,0,u32le(S),s)
end
local function E(d,capability_id,Q,R)
local a
if type(d.get_latest_state)=="function"then
a=d:get_latest_state("main",O ..capability_id,Q)end
local e=tonumber(a)if e==nil then return R end
return e
end
local l,k=i"terncyDimMinKelvin",i"terncyDimMaxKelvin"
local function r(W)
return function(d,_,a,s)
local B=f(a,1000,10000)if B==nil then return false end
local y,x=E(d,"terncyDimMinKelvin","minKelvin",G),E(d,"terncyDimMaxKelvin","maxKelvin",F)if W=="minimum"then y=B else x=B end
if y>=x then return false end
local N,M=f(1000000/x,0,65535),f(1000000/y,0,65535)local X=h(d,c,3,u16le(N)..u16le(M),s)if X then
if W=="minimum"then
d:emit_event(k(d,x))else
d:emit_event(l(d,y))end
end
return X
end
end
local Y={profile="lights-wave19-terncy-dim003",package_group="wave19-light",zcl_clusters={g.switch{endpoint=1},g.level{endpoint=1},g.color_temperature{endpoint=1},g.cluster_attribute(p,nil,{name="terncyDim_rated_current",endpoint=1,emit=i"terncyDimRatedCurrent",data_type=b.Uint32,write_only=true,sender=C}),g.cluster_attribute(c,nil,{name="terncyDim_startup_calibration",endpoint=1,emit=i"terncyDimStartupCalibration",data_type=b.Uint32,write_only=true,sender=v}),g.cluster_attribute(c,nil,{name="terncyDim_min_kelvin",endpoint=1,emit=l,data_type=b.Uint16,write_only=true,sender=r"minimum"}),g.cluster_attribute(c,nil,{name="terncyDim_max_kelvin",endpoint=1,emit=k,data_type=b.Uint16,write_only=true,sender=r"maximum"}),g.cluster_attribute(c,5,{name="terncyDim_io_reversed",endpoint=1,emit=i"terncyDimIoReversed",
from_device=function(a)return a and"ON"or"OFF"end,
to_device=function(a)return a=="ON"end,
data_type=b.Boolean,write_type=b.Boolean,mfg_code=o,configure_reporting=false,read_on_configure=false}),g.cluster_attribute(c,7,{name="terncyDim_light_curve",endpoint=1,emit=i"terncyDimLightCurve",
from_device=function(a)
return({[0]="fast_start",[1]="uniform",[2]="slow_start"})[a]
end,
to_device=function(a)
return({fast_start=0,uniform=1,slow_start=2})[a]
end,
data_type=b.Uint8,write_type=b.Uint8,mfg_code=o,configure_reporting=false,read_on_configure=false})},
configure=function(J,d)
for _,m in ipairs{g.CLUSTER_ON_OFF,g.CLUSTER_LEVEL_CONTROL,g.CLUSTER_COLOR_CONTROL}do
d:send(w.build_bind_request(d,m,J.environment_info.hub_zigbee_eui,1))end
end
}j(Y,{t.create_fingerprint("Xiaoyan","DIM003")})g.attach_reporting_capabilities(u,{{1,"rpt-cmq"},{2,"rpt-doh"}})return{id="zcl.lights.wave19.exact",registrations=u}
