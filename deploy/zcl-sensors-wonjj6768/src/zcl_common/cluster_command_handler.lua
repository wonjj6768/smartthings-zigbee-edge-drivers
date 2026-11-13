local function L(s)
local I,ak,P,aa,aq,O,aP,aN,aG,ao,aO,W,E,aX,aA=require"st.capabilities",require"runtime.capability_metadata",require"runtime.capability_binding",require"runtime.battery_refresh",require"protocol.zcl.runtime.handlers.command_dispatch",require"st.zigbee.generated.zcl_clusters",require"st.zigbee.generated.types.ZclStatus",require"st.zigbee.data_types",require"st.zigbee.messages",require"st.zigbee.zcl",require"st.zigbee.zcl.frame_ctrl",require"st.zigbee.zcl.global_commands.default_response",require"st.zigbee.constants",require"log",require"zcl_common.on_off_ack"local ac=ak.by_emit_name.remote_action
s.schedule_battery_refresh_after_button=aa.schedule_after_button
local A,ad,v,z="__zcl_last_remote_action",5,{},{}
local p
local function r(b)
if type(b)~="table"then
return nil
end
local K=b.address_header and
b.address_header.src_endpoint and
b.address_header.src_endpoint.value or nil
return s.normalize_endpoint(K)
end
local function N(b)
if type(b)~="table"then
return nil
end
local D=b.address_header and b.address_header.dest_addr or nil
return D and D.value or nil
end
local function as(b)
if type(b)~="table"then
return nil
end
local n=b.body and b.body.zcl_header or nil
local l=n and n.frame_ctrl or nil
if l==nil or type(l.is_mfg_specific_set)~="function"or not l:is_mfg_specific_set()then
return nil
end
local Y=n.mfg_code and n.mfg_code.value or nil
return type(Y)=="number"and Y or nil
end
local function Z(d)
local aT=type(d)=="table"and type(d.get_model)=="function"and d:get_model()or nil
return aT=="TS0041"or aT=="TS0041A"
end
local function aj(b)
return b and b.body and b.body.zcl_header and b.body.zcl_header.seqno and b.body.zcl_header.seqno.value or nil
end
local function B(b)
return b and b.body and b.body.zcl_header and b.body.zcl_header.cmd and b.body.zcl_header.cmd.value or nil
end
local function T(d,g,e,aB)
if type(e)~="string"or e==""then
return false
end
local ay,aQ=table.concat({tostring(g or"main"),tostring(e),tostring(aB or"nil")},"|"),type(d)=="table"and d:get_field(A)or nil
if aQ==ay then
return false
end
d:set_field(A,ay,{persist=false})return true
end
local function M(d,h,g,e,aB)
if not T(d,g,e,aB)then
return false,false
end
local aR=ac
return P.emit_state(d,g,aR,e,{state_change=true}),true
end
local function af(aD)
if type(aD)=="table"and aD.value~=nil then
return aD.value
end
return aD
end
local function m(b,...)
local u=b and b.body and b.body.zcl_body or nil
if type(u)~="table"then
return nil
end
for _,aW in ipairs{...}do
local an=u[aW]local aL=af(an)if aL~=nil then
return aL
end
end
return nil
end
local function J(d,h,b,e,g)
if type(h)~="table"or h.advanced_remote~=true or type(e)~="string"then
return false
end
local aw=g or"main"M(d,h,aw,e,aj(b))p(d,b,B(b)or 0)return true
end
local function f(d,h,b)
if type(h)~="table"or h.advanced_remote~=true then
return false
end
local c,a=b and b.address_header and b.address_header.cluster and b.address_header.cluster.value or nil,B(b)
if type(c)~="number"or type(a)~="number"then
return false
end
local e
if c==s.CLUSTER_ON_OFF then
e=({[0]="off",[1]="on",[2]="toggle"})[a]elseif c==s.CLUSTER_LEVEL_CONTROL then
if a==0 or a==4 then
e="brightness_move_to_level"elseif a==1 or a==5 then
local j=m(b,"move_mode","movemode","mode")if j==0 or j=="up"then
e="brightness_move_up"elseif j==1 or j=="down"then
e="brightness_move_down"end
elseif a==2 or a==6 then
local t=m(b,"step_mode","stepmode","mode")if t==0 or t=="up"then
e="brightness_step_up"elseif t==1 or t=="down"then
e="brightness_step_down"end
elseif a==3 or a==7 then
e="brightness_stop"end
elseif c==s.CLUSTER_COLOR_CONTROL then
if a==6 then
e="move_to_hue_and_saturation"elseif a==7 then
e="color_move"elseif a==1 then
local j=m(b,"move_mode","movemode","mode")if j==0 or j=="stop"then
e="hue_stop"elseif j==1 or j=="up"then
e="hue_move"elseif j==3 or j=="down"then
e="hue_down"end
elseif a==71 then
e="hue_stop"elseif a==10 then
e="color_temperature_move"elseif a==75 then
local j=m(b,"move_mode","movemode","mode")if j==0 or j=="stop"then
e="color_temperature_stop"elseif j==3 or j=="down"then
e="color_temperature_move_down"elseif j==1 or j=="up"then
e="color_temperature_move_up"end
elseif a==76 then
local t=m(b,"step_mode","stepmode","mode")if t==3 or t=="down"then
e="color_temperature_step_down"elseif t==1 or t=="up"then
e="color_temperature_step_up"end
end
elseif c==ad then
local C=m(b,"sceneid","scene_id")if a==0 then
e=C~=nil and("add_"..tostring(C))or"add"elseif a==2 then
e=C~=nil and("remove_"..tostring(C))or"remove"elseif a==3 then
e="remove_all"elseif a==4 then
e=C~=nil and("store_"..tostring(C))or"store"elseif a==5 then
e=C~=nil and("recall_"..tostring(C))or"recall"end
end
if type(e)~="string"then
return false
end
local g="main"return J(d,h,b,e,g)
end
local function V(ag,c,a)
if c==nil or a==nil then
return false
end
ag[c]=ag[c]or{}if ag[c][a]then
return false
end
ag[c][a]=true
return true
end
function p(d,b,a)
if type(d)~="table"or type(b)~="table"then
return false
end
local n=b.body and b.body.zcl_header or nil
local l=n and n.frame_ctrl or nil
if l~=nil and type(l.is_disable_default_response_set)=="function"and l:is_disable_default_response_set()then
return false
end
local D=N(b)if D~=nil and D>=65528 then
return false
end
local c,aH,i,aF=b.address_header and b.address_header.cluster and b.address_header.cluster.value or nil,b.address_header and b.address_header.src_addr and b.address_header.src_addr.value or nil,b.address_header and b.address_header.src_endpoint and b.address_header.src_endpoint.value or nil,b.address_header and b.address_header.dest_endpoint and b.address_header.dest_endpoint.value or E.HUB.ENDPOINT



if c==nil or aH==nil or i==nil then
return false
end
local x=aO(16)if l~=nil and type(l.get_direction)=="function"and l:get_direction()==0 then
x:set_direction()end
if l~=nil and type(l.is_mfg_specific_set)=="function"and l:is_mfg_specific_set()then
x:set_mfg_specific()end
local az={cmd=aN.ZCLCommandId(W.DEFAULT_RESPONSE_ID),frame_ctrl=x,seqno=n and n.seqno or nil}if n and n.mfg_code~=nil then
az.mfg_code=n.mfg_code
end
local aV=W.DefaultResponse(a,aP.SUCCESS)d:send(aG.ZigbeeMessageTx{address_header=aG.AddressHeader(E.HUB.ADDR,aF,aH,i,E.HA_PROFILE_ID,c),body=ao.ZclMessageBody{zcl_header=ao.ZclHeader(az),zcl_body=aV}})return true
end
s.send_default_response=p
local function S(k)
if type(k)=="table"and(k.raw_value~=nil or
k.typed_value~=nil or
k.attribute_id~=nil)then
return k
end
local H=type(k)=="table"and k.value or k
return{raw_value=H,typed_value=k}
end
local function F(d,q,c,a,b)
local i,Y,G,ap,aS=r(b),as(b),{},false,s.build_mapping_index(q)
if aS==nil then
return ap
end
local ai=aS.by_cluster_attribute[c]if ai==nil then
return ap
end
local aM={}for _,an in pairs(ai)do
for _,w in ipairs(s.collect_matching_entries(an,d,{zb_rx=b,endpoint=i,src_endpoint=i,command_id=a,mfg_code=Y}))do
if not aM[w]then
aM[w]=true
local X=s.mapping_meta(w)if X~=nil and X.command_id==a and X.command_extractor~=nil then
local k=S(X.command_extractor(b,d,w))local y=k.attribute_id or w.attribute_id
if y~=nil and G[y]==nil then
G[y]=k
end
end
end
end
end
for aE,k in pairs(G)do
if s.apply_attribute(d,q,c,aE,k.raw_value,{zb_rx=b,endpoint=i,src_endpoint=i,command_id=a,mfg_code=Y,typed_value=k.typed_value})then
ap=true
end
end
return ap
end
function s.register_cluster_command_handler(c,a,U)
if c==nil or a==nil or type(U)~="function"then
aX.warn(string.format("skip invalid zcl cluster command handler registration cluster=%s command=%s handler=%s",tostring(c),tostring(a),type(U)))return nil
end
v[c]=v[c]or{}v[c][a]=U
return U
end
function s.register_cluster_commands_from_mappings(q)
if type(q)~="table"then
return q
end
for _,w in ipairs(q)do
if type(w)=="table"then
local X=s.mapping_meta(w)if X~=nil and X.cluster_id~=nil and X.command_id~=nil and X.command_extractor~=nil then
V(z,X.cluster_id,X.command_id)end
end
end
return q
end
function s.build_zigbee_cluster_handlers(Q)
local o={}for c,aI in pairs(z)do
o[c]=o[c]or{}for a,_ in pairs(aI)do
o[c][a]=function(_,d,b)
local h=Q(d)if h==nil or h.zcl_clusters==nil then
return
end
return F(d,h.zcl_clusters,c,a,b)
end
end
end
for c,ar in pairs(v)do
o[c]=o[c]or{}for a,U in pairs(ar)do
o[c][a]=function(_,d,b)
local h=Q(d)if h==nil or h.zcl_clusters==nil then
return
end
local ae
if z[c]~=nil and z[c][a]then
ae=function()
return F(d,h.zcl_clusters,c,a,b)
end
end
return aq.dispatch(function()
return U(d,h,b)
end,ae)
end
end
end
return o
end
function s.build_zigbee_global_handlers(Q)
return require"zcl_common.reporting".global_handlers(s,{[s.CLUSTER_ON_OFF]={
[11]=function(_,d,b)
local az=b.body.zcl_header
local aC=az.frame_ctrl
if aC:is_cluster_specific_set()or aC:is_mfg_specific_set()or aC:get_direction()~=1 then return end
local K=r(b)local G,av=aA.get(d,K),b.body.zcl_body
if G==nil or G.command~=av.cmd.value
or G.profile~=b.address_header.profile.value then return end
local h=Q(d)local at=h and h.zcl_clusters
local aJ,aK={zb_rx=b,endpoint=K,src_endpoint=K,zcl_clusters=at,command_result=true},false
for _,w in ipairs(s.find_mappings(at,s.CLUSTER_ON_OFF,s.ATTR_ON_OFF,d,aJ))do
if w==G.mapping then aK=true;break end
end
aA.clear(d,K)if not aK or av.status.value~=aP.SUCCESS then return end
s.apply_attribute(d,at,s.CLUSTER_ON_OFF,s.ATTR_ON_OFF,av.cmd.value==1,aJ)
end
}})
end
s.register_cluster_command_handler(s.CLUSTER_IAS_ZONE,1,function(d,h,b)
local q=h and h.zcl_clusters or nil
if not s.has_cluster(q,s.CLUSTER_IAS_ZONE)then
return false
end
local i=r(b)if i==nil then
return false
end
if type(h.ias_zone_enroll_response)=="function"then
return h.ias_zone_enroll_response(d,b)~=false
end
local ah=O.IASZone.server.commands.ZoneEnrollResponse(d,O.IASZone.types.EnrollResponseCode(0),0)d:send(ah:to_endpoint(i))return true
end)
local function R(d,h,b)
local u=b and b.body and b.body.zcl_body or nil
local H
local i,aB,a=r(b),aj(b),B(b)or 253
if type(u)=="table"then
if u.value~=nil then
H=u.value.value or u.value
elseif type(u.body_bytes)=="string"and #u.body_bytes>=1 then
H=string.byte(u.body_bytes,1)end
end
if type(h)=="table"and h.advanced_remote==true then
local ax=a==252 and{[0]="rotate_right",[1]="rotate_left"}or{[0]="single",[1]="double",[2]="hold"}local base_action=ax[H]if base_action~=nil then
local g,am,e="main",i,base_action

e=am~=nil and(tostring(am).."_"..base_action)or base_action
M(d,h,g,e,aB)end
p(d,b,a)return true
end
local al=({[0]=I.button.button.pushed{state_change=true},[1]=I.button.button.double{state_change=true},[2]=I.button.button.held{state_change=true}})[H]if al==nil then
return false
end
local g="main"if not Z(d)and i~=nil and type(d.get_component_id_for_endpoint)=="function"then
local au=d:get_component_id_for_endpoint(i)if type(au)=="string"and au~=""then
g=au
end
end
if type(d.supports_capability_by_id)=="function"and not d:supports_capability_by_id(I.button.ID,g)then
g="main"end
d:emit_component_event({id=g},al)aa.schedule_after_button(d)p(d,b,a)return true
end
for _,a in ipairs{253,252}do
s.register_cluster_command_handler(s.CLUSTER_ON_OFF,a,R)end
for _,a in ipairs{0,1,2,3,64}do
s.register_cluster_command_handler(s.CLUSTER_ON_OFF,a,f)end
for _,a in ipairs{0,1,2,3,4,5,6,7}do
s.register_cluster_command_handler(s.CLUSTER_LEVEL_CONTROL,a,f)end
for _,a in ipairs{0,1,2,3,5,6,7,10,67,68,71,75,76}do
s.register_cluster_command_handler(s.CLUSTER_COLOR_CONTROL,a,f)end
for _,a in ipairs{0,2,3,4,5}do
s.register_cluster_command_handler(ad,a,f)end
end
return L
