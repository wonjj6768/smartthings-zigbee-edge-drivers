local r,e,j,d,y,g=require"protocol.zcl",require"capabilities.events.all",require"st.capabilities",require"st.zigbee.data_types",require"st.zigbee.cluster_base",require"contracts.helpers.family"local o,G=g.definition_registry()local z,w,D,R,A,O,x,F={persist=true},{persist=false},"zgDual:",{[0]="off",[1]="on",[2]="toggle",[255]="previous"},{off=0,on=1,toggle=2,previous=255},{[16]={0,524},[20737]={0,99},[20738]={0,99},[20739]={0,99},[20740]={0,99},[20741]={0,99},[20742]={0,99},[20743]={1,10}},e.zgDualPresenceState(),e.zgDualIlluminanceRaw()
local function s(b,rx)
local h=rx.body.zcl_header
if not h then return end
if rx.address_header.cluster.value==6 and h.frame_ctrl:is_cluster_specific_set()then
local P,S=require"cosock.socket".gettime(),D.."actions:"..rx.address_header.src_endpoint.value
local f=b:get_field(S)or{}for _,t in ipairs(f)do
if t.sequence==h.seqno.value and t.expiry>P then rx.__zgDualDuplicateAction=true;return end
end
for H=#f,1,-1 do if f[H].expiry<=P then table.remove(f,H)end end
if #f>4 then table.remove(f,1)end
f[#f+1]={sequence=h.seqno.value,expiry=P+10}b:set_field(S,f,w)b:set_field("__zcl_last_remote_action",nil,w)return
end
if rx.address_header.cluster.value~=1030 or h.frame_ctrl:is_cluster_specific_set()or(h.cmd.value~=1 and h.cmd.value~=10)or h.frame_ctrl:is_mfg_specific_set()then return end
local a
for _,q in ipairs(rx.body.zcl_body.attr_records or{})do
if q.attr_id.value==0 and q.data and(not q.status or q.status.value==0)then a=q.data.value end
end
rx.__zgDualOccupancy={value=a}
end
local function C(_,_,i)
local v=i.zb_rx.__zgDualOccupancy
if not v or v.used or type(v.value)~="number"then return end
v.used=true
return v.value
end
local function u(b,a)
local T,B=(a&2)~=0,(a&4)~=0
return{j.occupancySensor.occupancy((a&1)~=0 and"occupied"or"unoccupied"),j.motionSensor.motion(T and"active"or"inactive"),j.presenceSensor.presence(B and"present"or"not present"),x(b,T and(B and"motion_and_presence"or"motion")or(B and"presence"or"clear"))}
end
local function l(a,b,_,mapping)
if type(a)=="table"then a=a.value end
if mapping.attribute_id==16387 then a=R[a]elseif type(a)~="number"or a~=a or a<0 or a>(mapping.attribute_id==16 and 65534 or 255)then return end
if a==nil then return end
b:set_field(D..mapping.name,a,z)return a
end
local function p(b,mapping,a,i)
local J
if mapping.attribute_id==16387 then
if type(a)~="string"then return false end
J=A[a]else
local I=O[mapping.attribute_id]if type(a)~="number"or a~=a or a<I[1]or a>I[2]then return false end
J=math.floor(a)end
if J==nil then return false end
local k=i and i.endpoint or b:get_endpoint(mapping.cluster_id)local L=y.write_attribute(b,d.ClusterId(mapping.cluster_id),d.AttributeId(mapping.attribute_id),mapping.data_type(J)):to_endpoint(k)if not pcall(b.send,b,L)then return false end
pcall(r.read_attribute,b,mapping.cluster_id,mapping.attribute_id,k)return true
end
local function M(rx,m,K)
if m~=6 or rx.__zgDualDuplicateAction then return nil,nil,true end
local a=({[0]="off",[1]="on",[2]="toggle",[64]="off"})[K]return a,"main",true
end
local n={r.cluster_attribute(1030,0,{name="zg_dual_occupancy",data_type=d.Bitmap8,read_only=true,read_on_configure=false,from_device=C,emit=u}),r.battery{read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
from_device=function(a,_,i)
if i.raw_value>=255 then return end
return a
end},
r.cluster_attribute(1,32,{name="battery_voltage",data_type=d.Uint8,read_only=true,
read_on_configure=false,from_device=function(a)
if a<255 then return a/10 end
end,emit=e.voltage()}),
r.illuminance{name="zg_dual_illuminance",emit=e.zgDualIlluminance(),minimum_interval=10,maximum_interval=3600,reportable_change=5,
from_device=function(a)
if a==65535 then return end
return a==0 and 0 or 10 ^((a-1)/10000)
end},
r.cluster_attribute(1024,0,{name="zg_dual_illuminance_raw",data_type=d.Uint16,read_only=true,read_on_configure=false,read_on_refresh=false,
from_device=function(a,b)
if b.preferences.illuminanceRaw==true and a~=65535 then return a end
end,emit=F}),
r.on_off{emit=e.switch(),read_on_configure=true,minimum_interval=0,maximum_interval=65000,reportable_change=1},r.cluster_attribute(6,16387,{name="zg_dual_PowerOn",data_type=d.Enum8,read_on_configure=true,sender=p,suppress_optimistic_state=true,from_device=l,emit=e.zgDualPowerOn()})}for _,t in ipairs{{16,"zg_dual_FadingTime",d.Uint16,e.zgDualFadingTime()},{20737,"zg_dual_ZoneOneMotion",d.Uint8,e.zgDualZoneOneMotion()},{20738,"zg_dual_ZoneOneStill",d.Uint8,e.zgDualZoneOneStill()},{20739,"zg_dual_ZoneTwoMotion",d.Uint8,e.zgDualZoneTwoMotion()},{20740,"zg_dual_ZoneTwoStill",d.Uint8,e.zgDualZoneTwoStill()},{20741,"zg_dual_ZoneThreeMotion",d.Uint8,e.zgDualZoneThreeMotion()},{20742,"zg_dual_ZoneThreeStill",d.Uint8,e.zgDualZoneThreeStill()},{20743,"zg_dual_RadarScans",d.Uint8,e.zgDualRadarScans()}}do
n[#n+1]=r.cluster_attribute(1030,t[1],{name=t[2],data_type=t[3],read_on_configure=true,sender=p,suppress_optimistic_state=true,from_device=l,emit=t[4]})end
for _,mapping in ipairs(n)do
local m=mapping.cluster_id
mapping.endpoint=function(b)
return b:get_endpoint(m)
end
end
local U={profile="safety-motion-zigbeetlc-dual",magic_packet=false,query_on_configure=false,query_on_announce=false,
component_to_endpoint=function(b)
return b:get_endpoint(1030)
end,
advanced_remote=true,remote_action_emit_name="zgDualAction",standard_command_action_resolver=M,zigbee_message_handler=s,zcl_clusters=n,
configure=function(N,b)
for _,k in pairs(b.zigbee_endpoints)do
for _,m in ipairs(k.client_clusters or{})do
if m==6 then r.bind_cluster(b,6,N.environment_info.hub_zigbee_eui,k.id)end
end
end
end
}G(U,{g.create_fingerprint("Sonoff","ZG-204ZS-z"),g.create_fingerprint("Sonoff","ZG-204ZM-z")})r.attach_reporting_capabilities(o,{{1,"rpt-zqk"}})return{id="zcl.sensors.zigbeetlc_dual",registrations=o}
