local M,ay,S,u,e,ax,N,Z=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.capabilities",require"st.zigbee.data_types",require"st.zigbee.cluster_base",require"st.zigbee.zcl.clusters",require"st.zigbee.zcl.global_commands.read_attribute".ReadAttribute
local L,ah=S.definition_registry()local g,d=64656,4619
local function y(name)
return assert(ay[name],"Missing Heiman current metadata: "..name)()
end
local function q(a)
if type(a)=="table"and a.value~=nil then return a.value end
return a
end
local function at(a)
a=q(a)return a~=false and a~=0
end
local function aF(a)
return at(a)and"active"or"inactive"
end
local function aY(aW)
return function(a)return(q(a)&aW)~=0 end
end
local function P(ae)
return function(a)return ae[q(a)]end
end
local function aG(ae)
return function(a)
local ac={}for aR,aS in ipairs(ae)do
if(q(a)&(1<<(aR-1)))~=0 then ac[#ac+1]=aS end
end
return #ac>0 and table.concat(ac," | ")or"normal"
end
end
local function aq(tx,z)
if z then tx.body.zcl_header.frame_ctrl:set_disable_default_response()else tx.body.zcl_header.frame_ctrl:unset_disable_default_response()end
return tx
end
local function m(b,n,aL,k,G,z)
local tx=G and ax.read_manufacturer_specific_attribute(b,n,aL[1],G)or ax.read_attribute(b,e.ClusterId(n),e.AttributeId(aL[1]))tx.body.zcl_body=Z(aL)b:send(aq(tx:to_endpoint(k or b:get_endpoint(n)),z~=false))
end
local function D(a,U,T)
return type(a)=="number"and a==a and a>=U and a<=T
end
local function V(f)
f.minimum_interval,f.maximum_interval,f.reportable_change=nil,nil,nil
f.read_on_configure,f.read_on_refresh=false,false
return f
end
local function Y(b,n,attribute,F,U,T,aH,k)
M.configure_reporting(b,{cluster=n,attribute=attribute,data_type=F,minimum_interval=U,maximum_interval=T,reportable_change=aH},k,{auto_endpoint=true})
end
local function p(b,n)
local w={}for _,k in pairs(b.zigbee_endpoints or{})do
if b:supports_server_cluster(n,k.id)then w[#w+1]=k.id end
end
table.sort(w)return w
end
local function C(h,stem,i,aE)
local l,O,J={},{},{}
local function al(n,attribute,name,I,r,F,c)
c=c or{}c.name,c.emit,c.from_device=name,I,r
c.data_type=F
c.read_on_configure,c.read_on_refresh=false,false
if c.read_only==nil then c.read_only=true end
if n==g then c.mfg_code,c.endpoint=d,1 end
local f=M.cluster_attribute(n,attribute,c)l[#l+1]=f
return f
end
local function s(id,item,suffix,r,F)
return al(g,id,i ..item,y(stem..suffix),r,F)
end
local function o(ao,name,f,aw,a)
O[#O+1]={capability_id=ao,command_name=name,mapping_name=f,argument_name=aw,value=a}
end
local function v(id,item,suffix,r,F,aJ,z,as)
local I=suffix and y(stem..suffix)or nil
local f=al(g,id,i ..item,I,r,F,{read_only=false})
f.sender=function(b,_,a)
local an=aJ(a)if an==nil then return false end
local tx=ax.write_manufacturer_specific_attribute(b,g,id,d,F,an)b:send(aq(tx:to_endpoint(1),z))if as then
local aB=I(b,a)if aB then b:emit_event(aB)end
end
return true
end
return f
end
local aD=al(1,33,i .."battery",y(stem.."BatteryPercent"),function(a)
a=q(a)if a<255 then return a/2 end
end,e.Uint8)
aD.reporting_defaults={minimum_interval=3600,maximum_interval=65000,reportable_change=10}
local aj=al(1026,0,i .."temperature",ay.temperature(),function(a)
return q(a)/100
end,e.Int16)
aj.reporting_defaults={minimum_interval=10,maximum_interval=3600,reportable_change=h and 200 or 100}if h then
local az=al(1029,0,i .."humidity",y(stem.."Humidity"),function(a)
return q(a)/100
end,e.Uint16)
az.reporting_defaults={minimum_interval=10,maximum_interval=3600,reportable_change=500,
supported=function(b)return #p(b,1029)>0 end}
else
local co=al(1036,0,i .."co",y(stem.."CoPpm"),function(a,_,am)
local au=am and am.typed_value
if type(au)=="table"and au.ID==57 then a=string.unpack("<f",au:_serialize())end
if type(a)~="number"or a~=a or a==math.huge or a==-math.huge then return end
return math.floor(a/0.000001+0.5)
end,e.SinglePrecisionFloat)
co.reporting_defaults={minimum_interval=1,maximum_interval=14400,reportable_change=0.00001,
supported=function(b)return #p(b,1036)>0 end}
end
local aQ=h and M.smoke{name=i .."smoke"}or M.carbon_monoxide{name=i .."carbon_monoxide"}l[#l+1]=V(aQ)
l[#l+1]=V(M.battery_low{name=i .."battery_low",emit=function(_,a)
return a and u.batteryLevel.battery.critical()or u.batteryLevel.battery.normal()
end})
l[#l+1]=V(M.smoke{name=i .."test",from_device=function(a)
return aY(256)(a)and"active"or"inactive"
end,emit=y(stem.."TestState")})
s(19,"alarm_state","AlarmState",P{[0]="normal","prealarm",h and"alarmed"or"warning_alarm","critical_alarm"},e.Enum8)s(2,"fault_state","FaultState",aG{"fault","open_circuit_fault","short_circuit_fault","pollution_fault"},e.Uint16)s(9,"muted","MuteState",aG{"muted","alarm_muted","fault_muted","low_battery_muted","endoflife_muted","warning_muted"},e.Bitmap16)s(4103,"interconnectable","Interconnectable",aF,e.Uint8)s(4103,"link_available","LinkState",P{[0]="inactive","smoke_active","co_active","gas_active","heat_active"},e.Uint8)for _,x in ipairs{{27,"reported_packages","ReportedCount"},{26,"rejoin_count","RejoinCount"},{25,"reboot_count","RebootCount"}}do
s(x[1],x[2],x[3],q,e.Uint16)end
if h then
s(22,"smoke_level","SmokeLevel",function(a)return q(a)/100 end,e.Uint8)
s(24,"smoke_unit","SmokeUnit",P{[0]="dB/m",[1]="%ft OBS"},e.Uint8)s(23,"chamber_contamination","ChamberState",P{[0]="normal","light_contamination","medium_contamination","critical_contamination"},e.Uint8)else
s(6,"endoflife","LifeState",P{[0]="normal","expires_soon","expired"},e.Enum8)s(0,"preheating","PreheatState",P{[0]="normal","preheating"},e.Enum8)end
local ar=v(8,"temporary_mute",nil,function(a)return at(a)and"muted"or"unmuted"end,
e.Uint8,function(a)
if a=="muted"then return 1 elseif a=="unmuted"then return 0 end
end,false,false)
ar.emit=function(_,a)return u.audioMute.mute(a)end
o("audioMute","setMute",ar.name,"state")o("audioMute","mute",ar.name,nil,"muted")o("audioMute","unmute",ar.name,nil,"unmuted")
local E=v(4100,"heartbeat_indicator",nil,at,e.Uint8,function(a)
if type(a)=="boolean"then return a and 1 or 0 end
end,false,false)
E.name,E.component,E.emit="switch","heartbeat",ay.switch()local aO={stop=0,smoke_siren=1,co_siren=2}local aT=v(18,"siren_for_automation_only","SirenMode",P{[0]="stop","smoke_siren","co_siren"},
e.Enum8,function(a)return aO[a]end,true,true)
o("concertmirror08464."..stem.."SirenMode","setSirenMode",aT.name,"sirenMode")
local function av(id,item,suffix,attribute)
local f=v(id,item,suffix,function(a)return q(a)/100 end,
e.Int16,function(a)
if D(a,-15,15)then return math.modf(a*100)end
end,true,true)
o("concertmirror08464."..stem..suffix,"set"..attribute:sub(1,1):upper()..attribute:sub(2),f.name,attribute)
end
av(4109,"temperature_offset","TempOffset","tempOffset")if h then
av(4114,"humidity_offset","HumidityOffset","humidityOffset")
local aN=v(45,"shielding_sensor_detection","ShieldingTime",q,e.Uint16,function(a)
if D(a,0,20)then return math.modf(a)end
end,true,true)
o("concertmirror08464."..stem.."ShieldingTime","setShieldingTime",aN.name,"shieldingTime")end
J[i .."identify"]=function(b,j)
if j==nil then j=3 end
if not D(j,1,30)or j%1~=0 then return false end
b:send(N.Identify.server.commands.Identify(b,j):to_endpoint(1))return true
end
o("concertmirror08464."..stem.."Identify","identify",i .."identify","duration")local ab,B,X={stop=0,burglar=1,fire=2,emergency=3,police_panic=4,fire_panic=5,emergency_panic=6},{low=0,medium=1,high=2,very_high=3},{mode=true,level=true,strobe=true,duration=true,strobeDutyCycle=true,strobeLevel=true}
J[i .."warning"]=function(b,c)
if c==nil then c={}elseif c=="stop"then c={mode="stop"}end
if type(c)~="table"then return false end
for aZ in pairs(c)do if not X[aZ]then return false end end
local aM,aC,H,Q,j,ap=ab[c.mode or"emergency"],B[c.level or"medium"],B[c.strobeLevel or"medium"],c.strobe,c.duration,c.strobeDutyCycle
if Q==nil then Q=true end
if j==nil then j=10 end
if ap==nil then ap=0 end
if aM==nil or aC==nil or H==nil or type(Q)~="boolean"or
not D(j,0,65535)or not D(ap,0,10)then return false end
local aV=(aM<<4)|(Q and 4 or 0)|aC
local tx=N.IASWD.server.commands.StartWarning(b,aV,math.modf(j),math.modf(ap*10),H)b:send(aq(tx:to_endpoint(1),false))return true
end
o("concertmirror08464."..stem.."WarningV2","warning",i .."warning","warning")o("concertmirror08464."..stem.."WarningV2","stop",i .."warning",nil,"stop")
J[i .."trigger_selftest"]=function(b,_,aa)
if aa.component~="selfTest"then return false end
b:send(N.IASZone.server.commands.InitiateTestMode(b,1,1):to_endpoint(1))return true
end
o("momentary","push",i .."trigger_selftest",nil,"test")local K,A=h and{19,22,24,23,4103,4103,45,4109,4114,27,26,25}or{6,19,0,4103,4109,4103,27,26,25},h and{2,8,9,19,4100,4103,22,23,24,25,26,27}or{2,8,9,4100,4103,4109,6,19,0,25,26,27}return{profile=aE,zcl_clusters=l,protocol_writers=J,capability_commands=O,
component_to_endpoint=function()return 1 end,
endpoint_to_component=function()return"main"end,
configure=function(aI,b)
local aK=aI.environment_info.hub_zigbee_eui
M.bind_cluster(b,1,aK,1)M.bind_cluster(b,g,aK,1)Y(b,1,33,e.Uint8,3600,65000,0,1)m(b,1,{33},1)m(b,1280,{2,0,16,17},1)m(b,1026,{0},1)if not h then m(b,1036,{0},1)end
m(b,g,A,1,d)if h then
m(b,g,{4114,4109,45},1,d)m(b,1029,{0},2)end
for _,x in ipairs{{1,33,e.Uint8,3600,65000,10},{1026,0,e.Int16,10,3600,h and 200 or 100},{h and 1029 or 1036,0,h and e.Uint16 or e.SinglePrecisionFloat,h and 10 or 1,h and 3600 or 14400,h and 500 or 0.00001}}do
for _,k in ipairs(p(b,x[1]))do
M.bind_cluster(b,x[1],aK,k)Y(b,x[1],x[2],x[3],x[4],x[5],x[6],k)m(b,x[1],{x[2]},k)end
end
for _,id in ipairs(K)do m(b,g,{id},nil,d)end
end,
parent_refresh=function(b,ag)
if ag.zcl_refresh_before_read_all then ag.zcl_refresh_before_read_all(b,ag)end
m(b,1,{33})m(b,1,{32})m(b,1026,{0})m(b,h and 1029 or 1036,{0})local ai={[2]=true,[9]=true,[8]=true,[4100]=true,[4103]=true}for _,id in ipairs(A)do
m(b,g,{id},nil,d,not ai[id])end
m(b,g,{4103},nil,d,true)m(b,g,{18},nil,d,true)if h then
m(b,g,{45},nil,d,true)m(b,g,{4109},nil,d,true)m(b,g,{4114},nil,d,true)end
end
}
end
local aX,aU=C(true,"hmS1M","hm_s1_m_","safety-heiman-s1-m"),C(false,"hmC1M","hm_c1_m_","safety-heiman-c1-m")ah(aX,{S.create_fingerprint("0x120B","S1-M")})ah(aU,{S.create_fingerprint("0x120B","C1-M")})M.attach_reporting_capabilities(L,{{1,"rpt-srn"},{2,"rpt-cgx"}})return{id="zcl.sensors.heiman_m_safety",registrations=L}
