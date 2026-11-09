local p,bo,f,H,q,J=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.device_management",require"st.zigbee.data_types",require"st.capabilities"local l,d=f.definition_registry()local ae,aw,aQ,n,as="concertmirror08464.",6,0,64642,4619



local function K(capability_id)
return assert(bo[capability_id],"missing Wave19 bridge emitter: "..capability_id)()
end
local function aA(a,E)
if E~=nil and type(a.emit_event)=="function"then
a:emit_event(E)end
end
local ad,O={[1]="single",[2]="double",[3]="triple",[4]="quadruple",[5]="quintuple"},K"candeoRfHubAction"
local function G(a,bq)
if type(a.get_field)~="function"then return nil end
return a:get_field(bq)
end
local function j(a,bq,b)
if type(a.set_field)=="function"then
a:set_field(bq,b,{persist=false})end
end
local function aL(a,ab)
if ab==nil then return end
if type(a.thread)=="table"and type(a.thread.cancel_timer)=="function"then
a.thread:cancel_timer(ab)elseif type(ab)=="table"and type(ab.cancel)=="function"then
ab:cancel()end
end
local function C(a,c,count)
local bk=ad[count]if bk==nil then return false end
local E=O(a,string.format("button_%d_%s_pressed",c,bk))if E==nil then return false end
E.state_change=true
aA(a,E)return true
end
local function aq(e)
local L=e and e.zb_rx and e.zb_rx.body and e.zb_rx.body.zcl_header or nil
local ba=L and L.seqno or nil
local b=type(ba)=="table"and ba.value or ba
return type(b)=="number"and b or nil
end
local function Y(a,_,e)
local c=tonumber(e and(e.src_endpoint or e.endpoint))if c==nil or c<1 or c>10 or c%1~=0 then return end
local ar=aq(e)if ar~=nil then
local U=string.format("__wave19_candeo_rf_sequences_%d",c)local y=G(a,U)if type(y)~="table"then y={}end
for _,bw in ipairs(y)do
if bw==ar then return end
end
local az={ar}for aX=1,math.min(#y,4)do
az[#az+1]=y[aX]end
j(a,U,az)end
local w,F=string.format("__wave19_candeo_rf_count_%d",c),string.format("__wave19_candeo_rf_timer_%d",c)local count=(tonumber(G(a,w))or 0)+1
j(a,w,count)local ay=G(a,F)aL(a,ay)if type(a.thread)~="table"or type(a.thread.call_with_delay)~="function"then
j(a,w,0)j(a,F,nil)C(a,c,count)return
end
local ab=a.thread:call_with_delay(1,function()
local aR=tonumber(G(a,w))or 0
j(a,w,0)j(a,F,nil)C(a,c,aR)
end,string.format("Candeo RF button %d multi-press",c))
j(a,F,ab)
end
local aC={profile="bridges-wave19-candeo-rf-hub",package_group="wave19-bridge",zcl_clusters={p.cluster_attribute(aw,aQ,{name="candeo_rf_hub_press",read_only=true,handler=Y})}}d(aC,{f.create_fingerprint("Candeo","C-RFZB-HUB")})
local function V(B)
local aV=B and B.body and B.body.zcl_body or nil
return type(aV)=="table"and aV.body_bytes or nil
end
local function bc(b)
local ai=tonumber(b)if ai==nil or ai%1~=0 or ai<0 or ai>255 then return nil end
return ai
end
local function aZ(b)
if type(b)~="string"then return nil end
local X,second=string.match(b,"^%s*(%d+)%s*[:/,]%s*(%d+)%s*$")X,second=bc(X),bc(second)if X==nil or second==nil then return nil end
return X,second
end
local function aO(b)
if type(b)~="string"and type(b)~="number"then return nil end
if type(b)=="string"then
b=string.match(b,"^%s*(%d+)%s*$")end
return bc(b)
end
local function r(a,s,g,e)
return p.send_raw_cluster_command(a,n,s,g,e and e.endpoint or 1,nil,nil,false)
end
local function P(s)
return function(a,_,b,e)
local X,second=aZ(b)if X==nil then return false end
return r(a,s,string.char(X,second),e)
end
end
local function aF(a,_,b,e)
local u=aO(b)if u==nil then return false end
return r(a,244,string.char(u),e)
end
local function aS(a,_,_,e)
return r(a,246,"",e)
end
local function at(bv,bs)
return p.cluster_attribute(n,nil,{name=bv,endpoint=1,write_only=true,sender=bs})
end
local function Z(B)
local g=V(B)if type(g)~="string"or #g~=3 then return nil end
local id,ap,br=string.byte(g,1,3)return{id=id,key_code=ap,result=br}
end
local function S(B)
local g=V(B)if type(g)~="string"or #g~=2 then return nil end
local id,u=string.byte(g,1,2)return{id=id,model_type=u}
end
local function au(T)
local ax={}for _,o in ipairs(T)do
local bj={}for _,ap in ipairs(o.key_codes)do bj[#bj+1]=tostring(ap)end
ax[#ax+1]=string.format("%d:%d:%s",o.id,o.model_type,table.concat(bj,","))end
local b=table.concat(ax,";")if #b>2048 then return nil end
return b
end
local function am(B,a,prefix)
local aI="__wave19_"..prefix.."_ir_list"
local function aj()
j(a,aI,nil)return nil
end
local g=V(B)if type(g)~="string"or #g<3 then return aj()end
local av,R,bf=string.byte(g,1,3)if av<1 or R<1 or R>av or bf>70 or #g~=bf+3 then return aj()end
local T,A,aW={},4,#g

while A<=aW do
if A+2>aW then return aj()end
local id,u,ah=string.byte(g,A,A+2)if A+2+ah>aW then return aj()end
local ag={}for aX=A+3,A+2+ah do
ag[#ag+1]=string.byte(g,aX)end
T[#T+1]={id=id,model_type=u,key_codes=ag}A=A+3+ah
end
local I=G(a,aI)if R==1 then
I={total=av,next_packet=1,records={}}end
if type(I)~="table"or I.total~=av or I.next_packet~=R then
return aj()end
for _,o in ipairs(T)do I.records[#I.records+1]=o end
I.next_packet=R+1
if R<av then
j(a,aI,I)return nil
end
j(a,aI,nil)return au(I.records)
end
local function i(a,bl,b,aP)
if b==nil then return end
local E=bl(a,b)if E~=nil and aP then E.state_change=true end
aA(a,E)
end
local function z(aK,s,be,bm)
return p.cluster_attribute(n,aK,{name=string.format("heiman_ir_response_%02x",s),endpoint=1,read_only=true,command_id=s,command_extractor=be,handler=bm,mfg_code=as})
end
local function ac(af,a)
a:send(H.build_bind_request(a,n,af.environment_info.hub_zigbee_eui,1))
end
local function v(al)
local capability_prefix,D=al.capability_prefix,al.mapping_prefix

local an,ao,aT,bi,aY,aN,k=K(capability_prefix.."Action"),K(capability_prefix.."ActionResult"),K(capability_prefix.."ActionId"),K(capability_prefix.."ActionKeyCode"),K(capability_prefix.."ActionModelType"),K(capability_prefix.."Devices"),{}if al.has_battery then
k[#k+1]=p.battery{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true}end
local aE={{"send_key",P(240)},{"create_id",aF},{"learn_key",P(241)},{"delete_key",P(243)},{"request_list",aS}}for _,spec in ipairs(aE)do
k[#k+1]=at(D.."_"..spec[1],spec[2])end
k[#k+1]=z(61953,242,Z,function(a,b)
i(a,an,"learn",true)i(a,ao,b.result==1 and"success"or"error",true)i(a,bi,b.key_code)if b.result==1 then i(a,aT,b.id)end
end)
k[#k+1]=z(62721,245,S,function(a,b)
i(a,an,"create",true)i(a,ao,b.id==255 and"error"or"success",true)i(a,aY,b.model_type)if b.id~=255 then i(a,aT,b.id)end
end)
k[#k+1]=z(63233,247,function(B,a)
return am(B,a,D)
end,function(a,b)
i(a,aN,b)
end)
local function Q(capability_suffix,aM,aB,mapping_suffix,b)
return{capability_id=ae ..capability_prefix..capability_suffix,command_name=aM,argument_name=aB,mapping_name=D.."_"..mapping_suffix,value=b}
end
return{profile=al.profile,package_group="wave19-bridge",zcl_clusters=k,configure=ac,capability_commands={Q("SendKey","sendKey","key","send_key"),Q("CreateId","createId","modelType","create_id"),Q("LearnKey","learnKey","key","learn_key"),Q("DeleteKey","deleteKey","key","delete_key"),Q("RequestList","requestList",nil,"request_list",true)}}
end
local aG,aH=v{profile="bridges-wave19-heiman-hs-one-ir",capability_prefix="heimanHsOneIr",mapping_prefix="heiman_hs_one_ir",has_battery=true},v{profile="bridges-wave19-heiman-hs-two-ir",capability_prefix="heimanHsTwoIr",mapping_prefix="heiman_hs_two_ir",has_battery=false}d(aG,{f.create_fingerprint("HEIMAN","IRControl-EM")})d(aH,{f.create_fingerprint("HEIMAN","IRControl2-EF-3.0")})local aa=bo.tiRouterTransmitPower()local bg={profile="bridges-ti-router",zcl_clusters={p.cluster_attribute(0,4919,{name="ti_router_transmit_power",endpoint=8,data_type=q.Int8,write_type=q.Int8,prefer_plain_attribute_write=true,
emit=function(a,b,e)
return{aa(a,b),J.signalStrength.lqi{value=e.zb_rx.lqi.value}}
end
}),p.cluster_attribute(0,0,{name="ti_router_heartbeat",endpoint=8,read_only=true,data_type=q.Uint8,minimum_interval=0,maximum_interval=3600,reportable_change=0,
emit=function(_,_,e)return J.signalStrength.lqi{value=e.zb_rx.lqi.value}end
})},
configure=function(af,a)
a:send(H.build_bind_request(a,0,af.environment_info.hub_zigbee_eui,8))
end,
parent_refresh=function(a)
return p.read_mapping(a,p.cluster_attribute(0,4919,{endpoint=8}))
end
}d(bg,{f.create_fingerprint("TexasInstruments","ti.router")})local bb={profile="bridges-slzb07mg26",magic_packet=false,zcl_clusters={p.cluster_attribute(0,0,{name="slzb07_link_quality",endpoint=1,read_only=true,data_type=q.Uint8,minimum_interval=3600,maximum_interval=14400,reportable_change=0,read_on_configure=true,
emit=function(_,_,e)
return J.signalStrength.lqi{value=e.zb_rx.lqi.value}
end
}),p.cluster_attribute(0,nil,{name="slzb07_reset",endpoint=1,write_only=true,
sender=function(a)return p.send_raw_cluster_command(a,0,0,"",1,nil,nil,true)end
})},capability_commands={{capability_id=ae.."slzb07Reset",command_name="reset",value=true,mapping_name="slzb07_reset"}},
configure=function(af,a)
p.bind_cluster(a,0,af.environment_info.hub_zigbee_eui,1)
end
}d(bb,{f.create_fingerprint("SMLIGHT","SLZB-07MG26")})local x="__egony_v6_application_version"
local function t(a)
local c=a:get_endpoint(0)if a:supports_server_cluster(0,c)then return c end
end
local function m(a)
return a:get_field(x)==200 and t(a)~=nil
end
local function N(a)
a:set_field(x,nil)p.discard_unsupported_reporting(a)local c=t(a)if c then return p.read_attribute(a,0,1,c)end
return false
end
local W={profile="bridges-egony-v6",magic_packet=false,initial_custom_state_query=false,runtime_start=N,
configure=function(_,a)return N(a)end,
parent_refresh=function(a)
if not m(a)then return N(a)end
for _,c in pairs(a.zigbee_endpoints or{})do
if a:supports_server_cluster(0,c.id)then p.read_attribute(a,0,0,c.id)end
end
end,
zcl_clusters={p.cluster_attribute(0,1,{name="egony_v6_application_version",data_type=q.Uint8,read_only=true,read_on_configure=false,read_on_refresh=false}),p.cluster_attribute(0,0,{name="egony_v6_heartbeat",data_type=q.Uint8,read_only=true,read_on_configure=false,read_on_refresh=false,reporting_defaults={minimum_interval=3600,maximum_interval=14400,reportable_change=0,supported=m,all_endpoints=true}}),p.cluster_attribute(0,nil,{name="egony_v6_reset",write_only=true,
sender=function(a,_,b)
if b~=true or not m(a)then return false end
local bt=p.send_raw_cluster_command(a,0,0,"",t(a),nil,nil,true)if bt~=false then
a:set_field(x,nil)p.discard_unsupported_reporting(a)end
return bt
end})
},capability_commands={{capability_id=ae.."egonyV6Reset",command_name="reset",mapping_name="egony_v6_reset",value=true}}}
W.zigbee_message_handler=function(a,rx)
local L,aV=rx.body.zcl_header,rx.body.zcl_body
if L==nil or rx.address_header.cluster.value~=0 or rx.address_header.src_endpoint.value~=t(a)or L.frame_ctrl:is_mfg_specific_set()or(L.cmd.value~=1 and L.cmd.value~=10)then return end
local aU,count=nil,0
for _,o in ipairs(aV.attr_records or{})do
if o.attr_id.value==1 then
count=count+1
if(not o.status or o.status.value==0)and o.data_type
and o.data_type.value==32 and o.data then aU=o.data.value end
end
end
if count==0 then return end
local y=m(a)a:set_field(x,count==1 and aU==200 and 200 or nil)p.discard_unsupported_reporting(a)if not y and m(a)then
for _,c in pairs(a.zigbee_endpoints or{})do
if a:supports_server_cluster(0,c.id)then
p.bind_cluster(a,0,a.driver.environment_info.hub_zigbee_eui,c.id)p.configure_reporting(a,{cluster=0,attribute=0,data_type=q.Uint8,minimum_interval=3600,maximum_interval=14400,reportable_change=0},c.id,{auto_endpoint=true})pcall(p.read_attribute,a,0,0,c.id)end
end
W.zcl_refresh_before_read_all(a)end
end
d(W,{f.create_fingerprint("EGONY","V6")})W=l[#l]local aJ={profile="bridges-aeotec-wg001",magic_packet=false,zcl_clusters={}}d(aJ,{f.create_fingerprint("AL001","WG001-Z01")})p.attach_reporting_capabilities(l,{{2,"rpt-itx"},{4,"rpt-tcea"},{5,"rpt-snc"},{6,"rpt-vwa"}})return{id="zcl.bridges.wave19",registrations=l}
