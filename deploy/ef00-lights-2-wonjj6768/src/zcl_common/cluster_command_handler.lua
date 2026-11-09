local function as(p)
local z,B,G,al,bb,W,bG,bD,bp,aX,bE,aC,ae,bP,bk=require"st.capabilities",require"runtime.capability_metadata",require"runtime.capability_binding",require"runtime.battery_refresh",require"protocol.zcl.runtime.handlers.command_dispatch",require"st.zigbee.generated.zcl_clusters",require"st.zigbee.generated.types.ZclStatus",require"st.zigbee.data_types",require"st.zigbee.messages",require"st.zigbee.zcl",require"st.zigbee.zcl.frame_ctrl",require"st.zigbee.zcl.global_commands.default_response",require"st.zigbee.constants",require"log",require"zcl_common.on_off_ack"local bF,aK,ai=W.IASACE,B.by_emit_name.remote_action,B.by_emit_name.security_remote_action


p.schedule_battery_refresh_after_button=al.schedule_after_button
local V,aL,ba,P,T="__zcl_last_remote_action",5,{[0]="disarm",[1]="arm_day_zones",[2]="arm_night_zones",[3]="arm_all_zones",[4]="exit_delay"},{},{}
local l
local function k(b)
if type(b)~="table"then
return nil
end
local ar=b.address_header and
b.address_header.src_endpoint and
b.address_header.src_endpoint.value or nil
return p.normalize_endpoint(ar)
end
local function E(b)
if type(b)~="table"then
return nil
end
local y=b.address_header and b.address_header.dest_addr or nil
return y and y.value or nil
end
local function bd(b)
if type(b)~="table"then
return nil
end
local u=b.body and b.body.zcl_header or nil
local r=u and u.frame_ctrl or nil
if r==nil or type(r.is_mfg_specific_set)~="function"or not r:is_mfg_specific_set()then
return nil
end
local at=u.mfg_code and u.mfg_code.value or nil
return type(at)=="number"and at or nil
end
local function aF(c)
local bL=type(c)=="table"and type(c.get_model)=="function"and c:get_model()or nil
return bL=="TS0041"or bL=="TS0041A"
end
local function ax(b)
return b and b.body and b.body.zcl_header and b.body.zcl_header.seqno and b.body.zcl_header.seqno.value or nil
end
local function D(b)
return b and b.body and b.body.zcl_header and b.body.zcl_header.cmd and b.body.zcl_header.cmd.value or nil
end
local function O(c,bn,e)
return type(c)=="table"and
type(c.supports_capability_by_id)=="function"and
c:supports_capability_by_id(bn,e or"main")
end
local function t(c,f,aV)
local e=aV or"main"if f~=nil and type(c)=="table"and type(c.get_component_id_for_endpoint)=="function"then
local ad=c:get_component_id_for_endpoint(f)if type(ad)=="string"and ad~=""then
e=ad
end
end
return e
end
local function aG(c,d,scene_index,f)
local R=type(d)=="table"and d.scene_component_map or nil
local e=type(R)=="table"and(R[scene_index]or R[f])or nil
if type(e)~="string"or e==""then
e=t(c,f,scene_index==1 and"main"or("button"..tostring(scene_index)))end
return e
end
local function A(c,e,bs)
local av=z.button and z.button.button and z.button.button[bs]or nil
if av==nil then
return false
end
local o=e or"main"if not O(c,z.button.ID,o)then
o="main"end
if not O(c,z.button.ID,o)then
return false
end
c:emit_component_event({id=o},av{state_change=true})al.schedule_after_button(c)return true
end
local function U(c,e,h,au)
if type(h)~="string"or h==""then
return false
end
local bh,bI=table.concat({tostring(e or"main"),tostring(h),tostring(au or"nil")},"|"),type(c)=="table"and c:get_field(V)or nil
if bI==bh then
return false
end
c:set_field(V,bh,{persist=false})return true
end
local function C(c,d,e,h,au)
if not U(c,e,h,au)then
return false,false
end
local K=aK
if type(d)=="table"and type(d.remote_action_emit_name)=="string"then
K=B.by_emit_name[d.remote_action_emit_name]or K
end
return G.emit_state(c,e,K,h,{state_change=true}),true
end
local function aw(c,d,h,au)
if not U(c,"main",h,au)then
return false
end
local K=ai
if type(d)=="table"and type(d.security_remote_action_emit_name)=="string"then
K=B.by_emit_name[d.security_remote_action_emit_name]or K
end
return G.emit_state(c,"main",K,h)
end
local function aO(aQ)
if type(aQ)=="table"and aQ.value~=nil then
return aQ.value
end
return aQ
end
local function i(b,...)
local L=b and b.body and b.body.zcl_body or nil
if type(L)~="table"then
return nil
end
for _,bO in ipairs{...}do
local ag=L[bO]local by=aO(ag)if by~=nil then
return by
end
end
return nil
end
local function ao(c,d,e,b,g,a)
local bi=type(d)=="table"and d.standard_action_metadata_emit_names or nil
if type(bi)~="table"then
return false
end
local aY=false
local function Z(bJ,aQ)
local bm=bi[bJ]local K=type(bm)=="string"and B.by_emit_name[bm]or nil
if K~=nil and type(aQ)=="number"then
aY=G.emit_state(c,e,K,aQ,{state_change=true})or aY
end
end
local y=E(b)if type(y)=="number"and y>=1 and y<=65527 then
Z("action_group",y)end
if g~=p.CLUSTER_LEVEL_CONTROL then
return aY
end
if a==0 or a==4 then
Z("action_level",i(b,"level"))local J=i(b,"transition_time","transtime")if type(J)=="number"then
Z("action_transition_time",J/10)end
elseif a==1 or a==5 then
Z("action_rate",i(b,"rate"))elseif a==2 or a==6 then
local bN=i(b,"step_size","stepsize")Z("action_step_size",bN)local J=i(b,"transition_time","transtime")if type(J)=="number"then
Z("action_transition_time",J/10)end
end
return aY
end
local function M(c,d,b,h,e)
if type(d)~="table"or d.advanced_remote~=true or type(h)~="string"then
return false
end
local o=e or"main"local m=type(d.standard_action_button_events)=="table"and
d.standard_action_button_events[h]or nil
local aq,aj=C(c,d,o,h,ax(b))if aj and type(m)=="string"then
A(c,o,m)end
if aq then
if type(d.remote_action_handler)=="function"then
d.remote_action_handler(c,o,h,b)end
local g=b and b.address_header and b.address_header.cluster and b.address_header.cluster.value or nil
ao(c,d,o,b,g,D(b))end
l(c,b,D(b)or 0)return true
end
local function N(c,d,b,h)
if type(d)~="table"or d.security_remote~=true or type(h)~="string"then
return false
end
A(c,"main","pushed")aw(c,d,h,ax(b))l(c,b,D(b)or 0)return true
end
local function aW(c,d,b)
if type(d)~="table"or d.security_remote~=true then
return false
end
local bH,bB=i(b,"armmode","arm_mode"),type(d.arm_mode_action_map)=="table"and d.arm_mode_action_map or ba
local h=bB[bH]if type(h)~="string"then
return false
end
return N(c,d,b,h)
end
local function aJ(c,d,b)
if type(d)~="table"or d.advanced_remote~=true or type(d.ias_zone_action_map)~="table"then
return false
end
local bu=i(b,"zonestatus","zone_status")local h=d.ias_zone_action_map[bu]if type(h)~="string"then
return false
end
return M(c,d,b,h,"main")
end
local function aD(c,d,b)
if type(d)~="table"or d.security_remote~=true then
return false
end
return N(c,d,b,"emergency")
end
local function aa(c,d,b)
local f,aT,ap=k(b),E(b),type(d)=="table"and d.group_component_map or nil
local an=type(ap)=="table"and ap[aT]or nil
if type(an)=="string"and an~=""then
return an
end
if type(d)=="table"and d.knob_remote==true then
return"main"end
return t(c,f,"main")
end
local function j(c,d,b)
if type(d)~="table"or d.advanced_remote~=true then
return false
end
local g,a=b and b.address_header and b.address_header.cluster and b.address_header.cluster.value or nil,D(b)
if type(g)~="number"or type(a)~="number"then
return false
end
local h
local X
local resolver_handled=false
if type(d.standard_command_action_resolver)=="function"then
h,X,resolver_handled=d.standard_command_action_resolver(b,g,a,k(b),c)if resolver_handled==true and type(h)~="string"then
return false
end
end
if resolver_handled~=true and g==p.CLUSTER_ON_OFF then
h=({[0]="off",[1]="on",[2]="toggle"})[a]elseif resolver_handled~=true and g==p.CLUSTER_LEVEL_CONTROL then
if a==0 or a==4 then
h="brightness_move_to_level"elseif a==1 or a==5 then
local n=i(b,"move_mode","movemode","mode")if n==0 or n=="up"then
h="brightness_move_up"elseif n==1 or n=="down"then
h="brightness_move_down"end
elseif a==2 or a==6 then
local I=i(b,"step_mode","stepmode","mode")if I==0 or I=="up"then
h="brightness_step_up"elseif I==1 or I=="down"then
h="brightness_step_down"end
elseif a==3 or a==7 then
h="brightness_stop"end
elseif resolver_handled~=true and g==p.CLUSTER_COLOR_CONTROL then
if a==6 then
h="move_to_hue_and_saturation"elseif a==7 then
h="color_move"elseif a==1 then
local n=i(b,"move_mode","movemode","mode")if n==0 or n=="stop"then
h="hue_stop"elseif n==1 or n=="up"then
h="hue_move"elseif n==3 or n=="down"then
h="hue_down"end
elseif a==71 then
h="hue_stop"elseif a==10 then
h="color_temperature_move"elseif a==75 then
local n=i(b,"move_mode","movemode","mode")if n==0 or n=="stop"then
h="color_temperature_stop"elseif n==3 or n=="down"then
h="color_temperature_move_down"elseif n==1 or n=="up"then
h="color_temperature_move_up"end
elseif a==76 then
local I=i(b,"step_mode","stepmode","mode")if I==3 or I=="down"then
h="color_temperature_step_down"elseif I==1 or I=="up"then
h="color_temperature_step_up"end
end
elseif resolver_handled~=true and g==aL then
local Y=i(b,"sceneid","scene_id")if a==0 then
h=Y~=nil and("add_"..tostring(Y))or"add"elseif a==2 then
h=Y~=nil and("remove_"..tostring(Y))or"remove"elseif a==3 then
h="remove_all"elseif a==4 then
h=Y~=nil and("store_"..tostring(Y))or"store"elseif a==5 then
h=Y~=nil and("recall_"..tostring(Y))or"recall"end
end
if type(h)~="string"then
return false
end
local e=type(X)=="string"and X or
aa(c,d,b)local f=k(b)if d.standard_action_endpoint_suffix==true and f~=nil then
h=h.."_"..tostring(f)end
return M(c,d,b,h,e)
end
local function aB(aP,g,a)
if g==nil or a==nil then
return false
end
aP[g]=aP[g]or{}if aP[g][a]then
return false
end
aP[g][a]=true
return true
end
function l(c,b,a)
if type(c)~="table"or type(b)~="table"then
return false
end
local u=b.body and b.body.zcl_header or nil
local r=u and u.frame_ctrl or nil
if r~=nil and type(r.is_disable_default_response_set)=="function"and r:is_disable_default_response_set()then
return false
end
local y=E(b)if y~=nil and y>=65528 then
return false
end
local g,br,f,bo=b.address_header and b.address_header.cluster and b.address_header.cluster.value or nil,b.address_header and b.address_header.src_addr and b.address_header.src_addr.value or nil,b.address_header and b.address_header.src_endpoint and b.address_header.src_endpoint.value or nil,b.address_header and b.address_header.dest_endpoint and b.address_header.dest_endpoint.value or ae.HUB.ENDPOINT



if g==nil or br==nil or f==nil then
return false
end
local Q=bE(16)if r~=nil and type(r.get_direction)=="function"and r:get_direction()==0 then
Q:set_direction()end
if r~=nil and type(r.is_mfg_specific_set)=="function"and r:is_mfg_specific_set()then
Q:set_mfg_specific()end
local bj={cmd=bD.ZCLCommandId(aC.DEFAULT_RESPONSE_ID),frame_ctrl=Q,seqno=u and u.seqno or nil}if u and u.mfg_code~=nil then
bj.mfg_code=u.mfg_code
end
local bM=aC.DefaultResponse(a,bG.SUCCESS)c:send(bp.ZigbeeMessageTx{address_header=bp.AddressHeader(ae.HUB.ADDR,bo,br,f,ae.HA_PROFILE_ID,g),body=aX.ZclMessageBody{zcl_header=aX.ZclHeader(bj),zcl_body=bM}})return true
end
p.send_default_response=l
local function az(q)
if type(q)=="table"and(q.raw_value~=nil or
q.typed_value~=nil or
q.attribute_id~=nil)then
return q
end
local w=type(q)=="table"and q.value or q
return{raw_value=w,typed_value=q}
end
local function af(c,s,g,a,b)
local f,at,ah,aM=k(b),bd(b),{},false
for _,F in ipairs(s)do
if F.cluster_id==g and F.attribute_id==nil then
for _,ag in ipairs(p.collect_matching_entries(F,c,{zb_rx=b,endpoint=f,src_endpoint=f,command_id=a,mfg_code=at}))do
local ac=p.mapping_meta(ag)if ac.command_id==a and ac.command_extractor~=nil then
ac.command_extractor(b,c,ag)aM=true
end
end
end
end
local bK=p.build_mapping_index(s)if bK==nil then
return aM
end
local aS=bK.by_cluster_attribute[g]if aS==nil then
return aM
end
local bA={}for _,ag in pairs(aS)do
for _,F in ipairs(p.collect_matching_entries(ag,c,{zb_rx=b,endpoint=f,src_endpoint=f,command_id=a,mfg_code=at}))do
if not bA[F]then
bA[F]=true
local ac=p.mapping_meta(F)if ac~=nil and ac.command_id==a and ac.command_extractor~=nil then
local q=az(ac.command_extractor(b,c,F))local S=q.attribute_id or F.attribute_id
if S~=nil and ah[S]==nil then
ah[S]=q
end
end
end
end
end
for ak,q in pairs(ah)do
if p.apply_attribute(c,s,g,ak,q.raw_value,{zb_rx=b,endpoint=f,src_endpoint=f,command_id=a,mfg_code=at,typed_value=q.typed_value})then
aM=true
end
end
return aM
end
function p.register_cluster_command_handler(g,a,aA)
if g==nil or a==nil or type(aA)~="function"then
bP.warn(string.format("skip invalid zcl cluster command handler registration cluster=%s command=%s handler=%s",tostring(g),tostring(a),type(aA)))return nil
end
P[g]=P[g]or{}P[g][a]=aA
return aA
end
function p.register_cluster_commands_from_mappings(s)
if type(s)~="table"then
return s
end
for _,F in ipairs(s)do
if type(F)=="table"then
local ac=p.mapping_meta(F)if ac~=nil and ac.cluster_id~=nil and ac.command_id~=nil and ac.command_extractor~=nil then
aB(T,ac.cluster_id,ac.command_id)end
end
end
return s
end
function p.build_zigbee_cluster_handlers(am)
local v={}for g,bt in pairs(T)do
v[g]=v[g]or{}for a,_ in pairs(bt)do
v[g][a]=function(_,c,b)
local d=am(c)if d==nil or d.zcl_clusters==nil then
return
end
return af(c,d.zcl_clusters,g,a,b)
end
end
end
for g,bc in pairs(P)do
v[g]=v[g]or{}for a,aA in pairs(bc)do
v[g][a]=function(_,c,b)
local d=am(c)if d==nil or d.zcl_clusters==nil then
return
end
local aN
if T[g]~=nil and T[g][a]then
aN=function()
return af(c,d.zcl_clusters,g,a,b)
end
end
return bb.dispatch(function()
return aA(c,d,b)
end,aN)
end
end
end
return v
end
function p.build_zigbee_global_handlers(am)
return require"zcl_common.reporting".global_handlers(p,{[p.CLUSTER_ON_OFF]={
[11]=function(_,c,b)
local bj=b.body.zcl_header
local bl=bj.frame_ctrl
if bl:is_cluster_specific_set()or bl:is_mfg_specific_set()or bl:get_direction()~=1 then return end
local ar=k(b)local ah,bf=bk.get(c,ar),b.body.zcl_body
if ah==nil or ah.command~=bf.cmd.value
or ah.profile~=b.address_header.profile.value then return end
local d=am(c)local be=d and d.zcl_clusters
local bw,bx={zb_rx=b,endpoint=ar,src_endpoint=ar,zcl_clusters=be,command_result=true},false
for _,F in ipairs(p.find_mappings(be,p.CLUSTER_ON_OFF,p.ATTR_ON_OFF,c,bw))do
if F==ah.mapping then bx=true;break end
end
bk.clear(c,ar)if not bx or bf.status.value~=bG.SUCCESS then return end
p.apply_attribute(c,be,p.CLUSTER_ON_OFF,p.ATTR_ON_OFF,bf.cmd.value==1,bw)
end
},[0]={
[2]=function(_,c,b)
local d=am(c)if type(d)~="table"or d.accept_basic_write_attributes~=true then
return
end
local bz=b and b.body and b.body.zcl_body and b.body.zcl_body.attr_records or nil
if type(bz)~="table"then
return
end
local f=k(b)for _,bq in ipairs(bz)do
local ak,bC=bq.attr_id and bq.attr_id.value or nil,bq.data

local w=type(bC)=="table"and bC.value or bC
if type(ak)=="number"then
p.apply_attribute(c,d.zcl_clusters,0,ak,w,{zb_rx=b,endpoint=f,src_endpoint=f,typed_value=bC})end
end
end
}})
end
p.register_cluster_command_handler(p.CLUSTER_IAS_ZONE,1,function(c,d,b)
local s=d and d.zcl_clusters or nil
if not p.has_cluster(s,p.CLUSTER_IAS_ZONE)then
return false
end
local f=k(b)if f==nil then
return false
end
local aR=W.IASZone.server.commands.ZoneEnrollResponse(c,W.IASZone.types.EnrollResponseCode(0),0)c:send(aR:to_endpoint(f))return true
end)
local function ay(c,d,b)
local L=b and b.body and b.body.zcl_body or nil
local w
local f,au,a=k(b),ax(b),D(b)or 253
if type(L)=="table"then
if L.value~=nil then
w=L.value.value or L.value
elseif type(L.body_bytes)=="string"and #L.body_bytes>=1 then
w=string.byte(L.body_bytes,1)end
end
if type(d)=="table"and d.scene_switch==true then
local aI=type(d.scene_action_map)=="table"and(d.scene_action_map[f]or d.scene_action_map[w])or f or w
if aI~=nil then
local aH=type(d.scene_action_name_map)=="table"and d.scene_action_name_map or nil
local h=type(aH)=="table"and aH[aI]or nil
if type(h)~="string"or h==""then
h="scene_"..tostring(aI)end
local e=aG(c,d,aI,f)A(c,e,"pushed")C(c,d,e,h,au)end
l(c,b,a)return true
end
if type(d)=="table"and d.advanced_remote==true then
local ab=type(d.tuya_action_map)=="table"and d.tuya_action_map[w]or nil
if type(ab)~="string"and type(d.tuya_action_name)=="string"then
ab=d.tuya_action_name
end
if type(ab)=="string"then
local aE=type(d.tuya_action_components)=="table"and d.tuya_action_components[w]or nil
local e,m=type(aE)=="string"and aE or t(c,f,"main"),type(d.tuya_action_button_events)=="table"and d.tuya_action_button_events[w]or nil
if type(m)=="string"then
A(c,e,m)end
C(c,d,e,ab,au)l(c,b,a)return true
end
local bg=a==252 and{[0]="rotate_right",[1]="rotate_left"}or{[0]="single",[1]="double",[2]="hold"}local base_action=bg[w]if base_action~=nil then
local e=t(c,f,"main")if d.knob_remote==true then
local aq,aj=C(c,d,"main",base_action,au)if aq then
if type(d.remote_action_handler)=="function"then
d.remote_action_handler(c,"main",base_action,b)end
end
if aj and(base_action=="single"or base_action=="double"or base_action=="hold")then
local m=({single="pushed",double="double",hold="held"})[base_action]if m~=nil then
A(c,e,m)end
end
else
local aU,h=type(d.button_count)=="number"and f or f,base_action

if d.unprefixed_remote_actions~=true then
h=aU~=nil and(tostring(aU).."_"..base_action)or base_action
end
local m=({single="pushed",double="double",hold="held"})[base_action]if m~=nil then
A(c,e,m)end
C(c,d,e,h,au)end
end
l(c,b,a)return true
end
local m=({[0]=z.button.button.pushed{state_change=true},[1]=z.button.button.double{state_change=true},[2]=z.button.button.held{state_change=true}})[w]if m==nil then
return false
end
local e="main"if not aF(c)and f~=nil and type(c.get_component_id_for_endpoint)=="function"then
local ad=c:get_component_id_for_endpoint(f)if type(ad)=="string"and ad~=""then
e=ad
end
end
if type(c.supports_capability_by_id)=="function"and not c:supports_capability_by_id(z.button.ID,e)then
e="main"end
c:emit_component_event({id=e},m)al.schedule_after_button(c)l(c,b,a)return true
end
for _,a in ipairs{253,252}do
p.register_cluster_command_handler(p.CLUSTER_ON_OFF,a,ay)end
for _,a in ipairs{0,1,2,3,64}do
p.register_cluster_command_handler(p.CLUSTER_ON_OFF,a,j)end
for _,a in ipairs{0,1,2,3,4,5,6,7}do
p.register_cluster_command_handler(p.CLUSTER_LEVEL_CONTROL,a,j)end
for _,a in ipairs{0,1,2}do
p.register_cluster_command_handler(p.CLUSTER_WINDOW_COVERING,a,j)end
for _,a in ipairs{0,1,2,3,5,6,7,10,67,68,71,75,76}do
p.register_cluster_command_handler(p.CLUSTER_COLOR_CONTROL,a,j)end
for _,a in ipairs{0,2,3,4,5}do
p.register_cluster_command_handler(aL,a,j)end
p.register_cluster_command_handler(bF.ID,0,aW)for _,a in ipairs{2,4}do
p.register_cluster_command_handler(bF.ID,a,aD)end
p.register_cluster_command_handler(p.CLUSTER_IAS_ZONE,0,aJ)for _,a in ipairs{0,2,3,4,5}do
p.register_cluster_command_handler(60672,a,function(c,d,b)
if type(d)~="table"or d.ir_controller~=true or p.handle_ir_transmit_command==nil then
return false
end
return p.handle_ir_transmit_command(c,d,b)
end)
end
end
return as
