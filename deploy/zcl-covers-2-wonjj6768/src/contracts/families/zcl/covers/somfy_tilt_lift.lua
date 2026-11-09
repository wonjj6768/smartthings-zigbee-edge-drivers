local j,a,e=require"protocol.zcl",require"contracts.helpers.family",require"contracts.helpers.zcl"local s,m=a.definition_registry()
local function i(d)
if type(d)=="number"and d>=0 and d<=100 then return 100-d end
end
local function q(d)
if type(d)~="number"or d<0 or d>100 then return nil end
return d==0 and"open"or d==100 and"closed"or"partially open"
end
local r={from=i,to=i}
local function c(b)return b:get_endpoint(258)end
local function k(b)
for _,u in ipairs{33,32}do pcall(j.read_attribute,b,1,u,b:get_endpoint(1))end
end
local function f()
return j.battery{minimum_interval=3600,maximum_interval=65000,reportable_change=10,
from_device=function(d,_,o)if o.raw_value~=255 then return d end end}
end
local function g(M)
local E={converter=r,minimum_interval=1,maximum_interval=65000,reportable_change=1}return{M and j.cover_tilt(E)or j.cover_position(E),j.window_shade_state{configure_reporting=false,read_on_configure=false,converter={from=q}},j.cover_state()}
end
local G={profile="covers-somfy-tilt-lift",magic_packet=false,initial_custom_state_query=false,component_to_endpoint=c,protocol_writers={somfy_tilt_lift_identify=e.identify},capability_commands={{capability_id="concertmirror08464.somfyTiltLiftIdentify",command_name="identify",mapping_name="somfy_tilt_lift_identify",value=3},{capability_id="concertmirror08464.somfyTiltLiftIdentify",command_name="setIdentifyTime",argument_name="identifyTime",mapping_name="somfy_tilt_lift_identify"}},
parent_refresh=function(b)
for _,u in ipairs{8,9}do j.read_attribute(b,258,u,b:get_endpoint(258))end
k(b)
end,
zcl_clusters={j.cover_position{converter=r,minimum_interval=1,maximum_interval=65000,reportable_change=1},j.cover_tilt{converter=r,minimum_interval=1,maximum_interval=65000,reportable_change=1},j.window_shade_state{configure_reporting=false,read_on_configure=false,converter={from=q}},j.cover_state(),f()}}m(G,{a.create_fingerprint("SOMFY","Tilt & Lift 25 WF Roller")})local J={profile="covers-somfy-lift",magic_packet=false,initial_custom_state_query=false,component_to_endpoint=c,
parent_refresh=function(b)j.read_attribute(b,258,8,b:get_endpoint(258))end,
zcl_clusters=g()}m(J,{a.create_fingerprint("SOMFY","Sonesse 30 DC 24V Roller"),a.create_fingerprint("SOMFY","Sonesse2 40 Zigbee Roller")})local C={profile="covers-somfy-lift-battery",magic_packet=false,initial_custom_state_query=false,component_to_endpoint=c,
parent_refresh=function(b)
k(b)j.read_attribute(b,258,8,c(b))
end,
zcl_clusters=e.append_clusters({f()},g())}m(C,{a.create_fingerprint("SOMFY","Sonesse 28 WF Li-Ion Roller"),a.create_fingerprint("SOMFY","Sonesse 28 WF Roller"),a.create_fingerprint("SOMFY","Sonesse2 28 WF Li-Ion Roller"),a.create_fingerprint("SOMFY","Sonesse2 28 WF Roller"),a.create_fingerprint("SOMFY","Sonesse 28 WF Li-Ion Zebra")})local D={profile="covers-somfy-lift-battery",magic_packet=false,initial_custom_state_query=false,component_to_endpoint=c,
parent_refresh=function(b)
j.read_attribute(b,258,8,c(b))k(b)
end,
zcl_clusters=e.append_clusters(g(),f())}m(D,{a.create_fingerprint("SOMFY","Sonesse Ultra 30 WF Li-Ion Rolle"),a.create_fingerprint("SOMFY","Sonesse2 ULTRA 30 WF Li-ion Roll"),a.create_fingerprint("SOMFY","Roll Up 24 WF Li-ion Roller"),a.create_fingerprint("SOMFY","Sonesse 28 WF Zebra")})local t,n="__somfy_glydea_state","__somfy_glydea_ignore"
local function v(b,h)
local A=b:get_field(t)or{}A[h]=A[h]or{stopped=false}b:set_field(t,A,{persist=false})return A[h]
end
local function y(b,B,d,o)
local l=v(b,o.endpoint)l.target=type(d)=="number"and d or({open=100,close=0,stop="stop"})[d]l.stopped=false
local N,I=pcall(j.get_sender(258),b,B,d,o)if not N or I==false then l.target=nil end
if not N then error(I,0)end
return I
end
local function p(d,b,o,B)
if b:get_field(n)==o.endpoint then return nil end
if B.name=="cover_position"then return i(d)end
return q(d)
end
local F={profile="covers-somfy-glydea",magic_packet=false,initial_custom_state_query=false,component_to_endpoint=c,parent_refresh=J.parent_refresh,zcl_clusters={j.cover_position{converter=r,from_device=p,sender=y,minimum_interval=1,maximum_interval=65000,reportable_change=1},j.window_shade_state{configure_reporting=false,read_on_configure=false,from_device=p},j.cover_state{sender=y}}}
F.zigbee_message_handler=function(b,K)
b:set_field(n,nil,{persist=false})local w=K.body.zcl_header
if w==nil or K.address_header.cluster.value~=258 or w.cmd.value~=10
or w.frame_ctrl:is_cluster_specific_set()or w.frame_ctrl:is_mfg_specific_set()or not w.frame_ctrl:is_direction_set()then return end
local h=K.address_header.src_endpoint.value
if not b:supports_server_cluster(258,h)then return end
local l=v(b,h)local L,z
for _,x in ipairs(K.body.zcl_body.attr_records or{})do
if x.data then
if x.attr_id.value==0 then z=x.data.value~=0 end
if x.attr_id.value==8 then L=x.data.value end
end
end
if z~=nil then
if z and l.stopped then l.target=nil end
l.stopped=not z
end
if L==0 and l.target~=nil then
if l.target=="stop"or l.target~=100 then b:set_field(n,h,{persist=false})end
l.target=nil
end
end
m(F,{a.create_fingerprint("SOMFY","Glydea Ultra Curtain")})local H={profile="covers-somfy-tilt-only",magic_packet=false,initial_custom_state_query=false,component_to_endpoint=c,
parent_refresh=function(b)
j.read_attribute(b,258,9,c(b))k(b)
end,
zcl_clusters=e.append_clusters(g(true),f())}m(H,{a.create_fingerprint("SOMFY","Tilt Only 50 WF TiltOnly")})j.attach_reporting_capabilities(s,{{1,"rpt-tqvi"},{2,"rpt-sca"},{3,"rpt-swo"},{4,"rpt-sqr"},{5,"rpt-sca"},{6,"rpt-tfk"}})return{id="zcl.covers.somfy_tilt_lift",registrations=s}
