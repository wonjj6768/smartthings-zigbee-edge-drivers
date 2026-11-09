local function x(a,aJ,aF)
return type(a)=="number"and a==a and a>=aJ and a<=aF
end
local function ay(a)
local z={[9]=true,[10]=true,[11]=true,[12]=true,[13]=true,[32]=true,[160]=true,[5760]=true,[8232]=true,[8233]=true,[8239]=true,[8287]=true,[12288]=true,[65279]=true}for P=8192,8202 do z[P]=true end
if not utf8.len(a)then return end
local E,last
for y,P in utf8.codes(a)do
if not z[P]then E=E or y;last=y+#utf8.char(P)-1 end
end
return E and a:sub(E,last)or""
end
local function A(a)
if type(a)=="boolean"then return a and 1 or 0 end
if type(a)~="string"then return end
local m=ay(a)if not m then return end
m=m:lower()if m=="start"or m=="on"or m=="true"then return 1 end
if m=="end"or m=="off"or m=="false"then return 0 end
end
local function J(a)
if type(a)=="number"then
if not x(a,-1,65536)then return end
a=math.modf(a)if a<0 or a>65535 then return end
return a
end
if type(a)~="string"then return end
local m=ay(a)if not m or not m:match"^%d+$"then return end
local Z=tonumber(m)if x(Z,0,65535)then return Z end
end
local function B(c)
if type(c)~="string"or #c==0 then return"null"end
local aj,S=c:byte(1),{}for y=2,math.min(#c-1,aj*2),2 do
S[#S+1]=tostring(string.unpack("<I2",c,y))end
return string.format('{"count":%d,"codes_found":[%s]}',aj,table.concat(S,","))
end
local function R(c)
if type(c)~="string"or #c<2 then return end
local a=string.unpack("<I2",c)return a==65535 and"null"or tostring(a)
end
local function D(a)
if not x(a,8,30)then return end
local N=a*2
local F,at=math.floor(N),string.unpack("<I8",string.pack("<d",N))local ad,af=((at>>52)&2047)-1022,(at&0xFFFFFFFFFFFFF)|0x10000000000000

if af*20>=(F*20+9)*(1<<(53-ad))then F=F+1 end
return F*50
end
local Y,X,aa,t,O,p,i,ac={fully_closed=1,fully_open=2,quarter_open=3,half_open=4,three_quarters_open=5},{[0]="fully_closed","fully_closed","fully_open","quarter_open","half_open","three_quarters_open"},require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.capabilities",require"st.zigbee.data_types",require"st.zigbee.cluster_base"local v,ah=O.definition_registry()local u,w,k,d,ai,AC,as,L,K,Q={},{},{},513,514,65452,4412,t.owonAc221PairingStatus(),t.owonAc221PairingResult(),t.owonAc221PairingCode()

local function T(tx)
tx.body.zcl_header.frame_ctrl:set_disable_default_response()return tx:to_endpoint(1)
end
local function U(b,o,g)
b:send(T(ac.read_attribute(b,i.ClusterId(o),i.AttributeId(g))))
end
local function G(b,o,g,H,a)
local tx=ac.write_attribute(b,i.ClusterId(o),i.AttributeId(g),H(a))if not pcall(b.send,b,T(tx))then return false end
return pcall(U,b,o,g)
end
local function h(b,f,c)
local tx=ac.build_manufacturer_specific_command(b,AC,f,as,c)return pcall(b.send,b,T(tx))
end
local function f(aI,ag,e,ab,a)
w[#w+1]={capability_id=aI,command_name=ag,mapping_name=e,argument_name=ab,value=a}
end
local function M(o,g,ag,H,am,aA,l)
local e=aa.cluster_attribute(o,g,{name=ag,data_type=H,endpoint=1,from_device=am,emit=aA,read_only=true,read_on_configure=false,read_on_refresh=false})e.reporting_defaults=l
u[#u+1]=e
return e
end
local function al(a,j,e,H)
for _,s in ipairs(j and j.zb_rx and j.zb_rx.body.zcl_body.attr_records or{})do
if s.attr_id.value==e.attribute_id and s.data==j.typed_value then
if s.status and s.status.value~=0 then return end
if not s.data_type or s.data_type.value~=H then return end
return type(a)=="table"and a.value or a
end
end
end
local function q(aB)
return function(a,_,j,e)
a=al(a,j,e,41)if not x(a,-32767,32767)or a%1~=0 then return end
a=a/100
if not aB or a>=-273.15 then return a end
end
end
local function I(az)
return function(a,_,j,e)
a=al(a,j,e,48)return az[a]
end
end
M(d,0,"owon_ac221_local_temperature",i.Int16,q(true),t.temperature"C",{minimum_interval=60,maximum_interval=600,reportable_change=0})M(d,18,"owon_ac221_heating_rx",i.Int16,q(true),t.heating_setpoint"C",{minimum_interval=0,maximum_interval=3600,reportable_change=10})M(d,17,"owon_ac221_cooling_rx",i.Int16,q(false),t.cooling_setpoint"C",{minimum_interval=0,maximum_interval=3600,reportable_change=10})for _,item in ipairs{{"heating","thermostatHeatingSetpoint","setHeatingSetpoint",18},{"cooling","thermostatCoolingSetpoint","setCoolingSetpoint",17}}do
local ak="owon_ac221_"..item[1]
k[ak]=function(b,a)
local n=D(a)if n==nil then return false end
return G(b,d,item[4],i.Int16,n)
end
f(item[2],item[3],ak,"setpoint")end
local ap,ao={off=0,auto=1,cool=3,heat=4,fanonly=7,dryair=8},{[0]="off",[1]="auto",[3]="cool",[4]="heat",[5]="emergencyheat",[6]="precooling",[7]="fanonly",[8]="dryair",[9]="asleep"}M(d,28,"owon_ac221_mode_rx",i.Enum8,I(ao),t.thermostat_mode(),{minimum_interval=10,maximum_interval=3600})
k.owon_ac221_mode=function(b,a)
local n=ap[a]if n==nil then return false end
return G(b,d,28,i.Enum8,n)
end
f("thermostatMode","setThermostatMode","owon_ac221_mode","mode")for _,ax in ipairs{"off","auto","cool","heat"}do f("thermostatMode",ax,"owon_ac221_mode",nil,ax)end
local aw,av={off=0,low=1,medium=2,high=3,on=4,auto=5,smart=6},{[0]="off","low","medium","high","on","auto","smart"}M(ai,0,"owon_ac221_fan_rx",i.Enum8,I(av),t.value(p.airConditionerFanMode.fanMode),{minimum_interval=0,maximum_interval=3600})
k.owon_ac221_fan=function(b,a)
if type(a)~="string"then return false end
local n=aw[a:lower()]if n==nil then return false end
return G(b,ai,0,i.Enum8,n)
end
f("airConditionerFanMode","setFanMode","owon_ac221_fan","fanMode")local W=M(d,69,"owon_ac221_louver",i.Enum8,I(X),t.owonAc221Louver())W.read_only=false
W.sender=function(b,_,a)
local n=Y[a]if n==nil then return false end
return G(b,d,69,i.Enum8,n)
end
f("concertmirror08464.owonAc221Louver","setLouverPosition","owon_ac221_louver","position")
k.owon_ac221_read_louver=function(b)return pcall(U,b,d,69)end
f("concertmirror08464.owonAc221Louver","readLouverPosition","owon_ac221_read_louver")
k.owon_ac221_one_key_pairing=function(b,a)
local n=A(a)if n==nil then return false end
return h(b,82,string.char(n))
end
f("concertmirror08464.owonAc221OneKeyPairing","setPairing","owon_ac221_one_key_pairing","action")f("concertmirror08464.owonAc221OneKeyPairing","startPairing","owon_ac221_one_key_pairing",nil,"start")f("concertmirror08464.owonAc221OneKeyPairing","endPairing","owon_ac221_one_key_pairing",nil,"end")
k.owon_ac221_pairing_code=function(b,a)
local n=J(a)if n==nil then return false end
return h(b,32,string.pack("<I2",n))
end
k.owon_ac221_read_pairing_code=function(b)return h(b,0,"")end
f("concertmirror08464.owonAc221PairingCode","setPairingCode","owon_ac221_pairing_code","pairingCode")f("concertmirror08464.owonAc221PairingCode","readPairingCode","owon_ac221_read_pairing_code")
local function C(b,an,a)
if a~=nil then b:emit_component_event({id="main"},an(b,a))end
end
local function aq(b,rx)
if rx.address_header.src_endpoint.value~=1 or rx.address_header.cluster.value~=AC then return end
local r,aE=rx.body.zcl_header,rx.body.zcl_body
if(r.frame_ctrl.value&11)~=9 or not r.mfg_code or r.mfg_code.value~=as then return end
local c=aE.body_bytes
if type(c)~="string"then return end
if r.cmd.value==82 and #c>=1 then
C(b,L,c:byte(1)==0 and"SUCCESS"or"FAILURE")elseif r.cmd.value==128 then
C(b,K,B(c))elseif r.cmd.value==0 then
C(b,Q,R(c))end
end
local au={profile="thermostats-owon-ac221",zcl_clusters=u,capability_commands=w,protocol_writers=k,initial_custom_state_query=false,zigbee_message_handler=aq,
runtime_start=function(b)
b:emit_event(p.thermostatMode.supportedThermostatModes({"off","auto","cool","heat","fanonly","dryair"},{visibility={displayed=false}}))b:emit_event(p.airConditionerFanMode.supportedAcFanModes({"low","medium","high","on","auto"},{visibility={displayed=false}}))
end,
configure=function(V,b)
aa.bind_cluster(b,d,V.environment_info.hub_zigbee_eui,1)aa.bind_cluster(b,ai,V.environment_info.hub_zigbee_eui,1)for _,e in ipairs(u)do
local l=e.reporting_defaults
if l then
aa.configure_reporting(b,{cluster=e.cluster_id,attribute=e.attribute_id,data_type=e.data_type,minimum_interval=l.minimum_interval,maximum_interval=l.maximum_interval,reportable_change=l.reportable_change},1,{disable_default_response=true})end
end
end,
parent_refresh=function(b)
for _,g in ipairs{0,18,17,28,69}do U(b,d,g)end
U(b,ai,0)return h(b,0,"")
end
}ah(au,{O.create_fingerprint("OWON","AC221")})aa.attach_reporting_capabilities(v,{{1,"rpt-ajn"}})return{id="zcl.thermostats.owon_ac221",registrations=v}
