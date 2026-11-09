local h,ah=require"protocol.zcl",require"contracts.helpers.family"local fp,e,v,A,bt=ah.create_fingerprint,require"st.capabilities",require"capabilities.events.all",require"st.zigbee.data_types",require"st.buf".Reader

local S,n=ah.definition_registry()local l,q=0,65281

local function j(M)
local F=((M-2850)*100)/150
if F<0 then
return 0
elseif F>100 then
return 100
end
return math.floor(F+0.5)
end
local function g(aK,aR)
if type(aK)~="table"then
return nil
end
if aK[aR]~=nil then return aK[aR]end
return aK[tostring(aR)]
end
local function ar(i)
if type(i)~="string"then return i end
local o,an={},1
while an+1<=#i do
local aR,bf=i:byte(an,an+1)local aT=A.get_data_type_by_id(bf)if not aT then break end
local bl=bt(i:sub(an+2))local ok,b=pcall(aT.deserialize,bl)if not ok then break end
if bf==57 or bf==58 then
o[aR]=string.unpack(bf==57 and"<f"or"<d",b:_serialize())else
o[aR]=b.value
end
if o[aR]==nil then o[aR]=b end
an=an+2+bl:tell()end
return o
end
local function X(b)
if type(b)=="number"and b>-65 and b<65 then return b end
end
local function m(_,b)
local B=b
if type(B)=="table"and B.value~=nil then
B=B.value
end
if type(B)=="table"and B[65281]~=nil then
B=B[65281]elseif type(B)=="table"and B["65281"]~=nil then
B=B["65281"]end
B=ar(B)if type(B)~="table"then
return nil
end
local c,M,x,aV,aX={},g(B,1),g(B,100),g(B,101),g(B,102)if type(M)=="number"then
c[#c+1]=e.battery.battery(j(M))c[#c+1]=e.voltageMeasurement.voltage{value=M/1000,unit="V"}end
if type(x)=="number"then
local aN=x/100
if aN>-65 and aN<65 then
c[#c+1]=e.temperatureMeasurement.temperature{value=aN,unit="C"}end
end
if type(aV)=="number"then
local F=aV/100
if F>=0 and F<=100 then
c[#c+1]=e.relativeHumidityMeasurement.humidity(F)end
end
if type(aX)=="number"then
c[#c+1]=e.atmosphericPressureMeasurement.atmosphericPressure{value=aX/1000,unit="kPa"}end
return c[1]~=nil and c or nil
end
local ac={profile="sensors-temp-humidity-battery-voltage",reporting_capability_exclusions={["*"]="Z2M WSDCGQ01LM uses Lumi Basic reports/check-in; standard reporting control support is unconfirmed."},zcl_clusters={h.cluster_attribute(l,q,{name="lumi_basic",emit=m,read_only=true}),h.temperature{from_device=X},h.humidity(),h.battery()}}local ag={profile="sensors-temp-humidity-pressure-battery-voltage",reporting_capability_exclusions={["*"]="Z2M WSDCGQ11LM uses Lumi Basic/measurement reports; standard reporting control support is unconfirmed."},zcl_clusters={h.cluster_attribute(l,q,{name="lumi_basic",emit=m,read_only=true}),h.temperature{from_device=X},h.humidity(),h.pressure(),h.cluster_attribute(1027,20,{read_only=true,read_on_configure=true,configure_reporting=false,
from_device=function(b,a)
a:set_field("pressure_scale",b~=-128 and b or nil)
end
}),h.cluster_attribute(1027,16,{read_only=true,configure_reporting=false,
from_device=function(b,a)
local bq=a:get_field"pressure_scale"if bq and b~=-32768 then return b/(10 ^ bq)/1000 end
end,
emit=v.atmospheric_pressure()}),h.battery(),h.battery_voltage()}}local bb={profile="sensors-illuminance-battery-voltage-lumi-pending",zcl_clusters={h.illuminance(),h.battery(),h.battery_voltage()}}
local function d(b)
return type(b)=="table"and b.value or b
end
local function V(a,Q)
local Z=a:get_field"__lumi_motion_timer"if Z then Z:cancel()end
a:set_field("__lumi_motion_timer",nil)if Q>0 then
a:set_field("__lumi_motion_timer",a.thread:call_with_delay(Q,function()
a:set_field("__lumi_motion_timer",nil)a:emit_event(e.motionSensor.motion.inactive())
end,"Aqara motion reset"))
end
end
local function aI(I,L)
return function(a,ao)
ao=d(ao)local t,z=a:get_field"__lumi_detection_interval"or I,tonumber(a.preferences.occupancyTimeout)
local Q=L and(z or 90)or((z and z>=t)and z or t+2)V(a,Q)local bu=L and ao or(ao>130536 and 0 or ao-65536)return{e.motionSensor.motion.active(),e.illuminanceMeasurement.illuminance(math.max(0,bu))}
end
end
local function y(af,D,p1,w)
return function(a,b)
local i=ar(d(b))if type(i)~="table"then return end
local c,R={},d(i[1]or i["1"])if type(R)=="number"then
c[#c+1]=e.battery.battery(j(R))c[#c+1]=e.voltageMeasurement.voltage{value=R/1000,unit="V"}end
local x=d(i[3]or i["3"])if af and type(x)=="number"then c[#c+1]=af(a,x)end
local ab=d(i[5]or i["5"])if w and type(ab)=="number"then c[#c+1]=w(a,ab-1)end
local t=d(i[105]or i["105"])if p1 and type(t)=="number"then
a:set_field("__lumi_detection_interval",t)c[#c+1]=D(a,t)end
if p1 then
local G=({[1]="low",[2]="medium",[3]="high"})[d(i[106]or i["106"])]if G then c[#c+1]=v.aqP1Sensitivity()(a,G)end
local indicator=d(i[107]or i["107"])if indicator~=nil then c[#c+1]=v.aqP1Indicator()(a,indicator==1 and"on"or"off")end
end
return #c>0 and c or nil
end
end
local function ae(a,b)
local i=ar(d(b))if type(i)~="table"then return end
local c,x=m(a,{[1]=d(g(i,1)),[100]=d(g(i,100)),[101]=d(g(i,101))})or{},d(g(i,3))if type(x)=="number"then
c[#c+1]=v.t1HtDeviceTemperature"C"(a,x)end
local be=d(g(i,5))if type(be)=="number"then
c[#c+1]=v.t1HtPowerOutageCount()(a,be-1)end
return #c>0 and c or nil
end
local ba={profile="sensors-aqara-t1-ht",magic_packet=false,
parent_refresh=function(a)
for _,k in ipairs{{1026,0},{1029,0},{1027,0},{1,33},{1,32}}do
h.read_attribute(a,k[1],k[2],1)end
end,
zcl_clusters={h.cluster_attribute(0,65281,{name="t1_ht_basic_heartbeat",endpoint=1,read_only=true,read_on_configure=false,emit=ae}),h.cluster_attribute(64704,247,{name="t1_ht_heartbeat",endpoint=1,read_only=true,read_on_configure=false,emit=ae}),h.temperature{endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100},h.humidity{endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100},h.pressure{endpoint=1,scale=1,minimum_interval=10,maximum_interval=3600,reportable_change=5,
emit=function(_,b)
return e.atmosphericPressureMeasurement.atmosphericPressure{value=b,unit="hPa"}
end},
h.battery{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
from_device=function(b,_,K)return K.raw_value<255 and b or nil end},
h.battery_voltage{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
from_device=function(b,_,K)return K.raw_value<255 and b or nil end,
emit=function(_,b)
return{e.voltageMeasurement.voltage{value=b,unit="V"},e.battery.battery(j(b*1000))}
end}
}}
local function al(a,b)
if d(b)~=1 then return end
V(a,tonumber(a.preferences.occupancyTimeout)or 90)return e.motionSensor.motion.active()
end
local function O(w)
return h.cluster_attribute(0,65282,{name="lumi_struct_battery",read_only=true,read_on_configure=false,
emit=function(a,b)
local P,c=b.elements,{}local R=P and P[2]and d(P[2].data)if type(R)=="number"then
c[#c+1]=e.battery.battery(j(R))c[#c+1]=e.voltageMeasurement.voltage{value=R/1000,unit="V"}end
local ab=P and P[5]and d(P[5].data)if w and type(ab)=="number"then c[#c+1]=w(a,ab-1)end
return #c>0 and c or nil
end
})
end
local bv={profile="safety-lumi-motion",zcl_clusters={h.cluster_attribute(1030,0,{name="lumi_occupancy",read_only=true,read_on_configure=false,emit=al}),h.cluster_attribute(l,q,{name="lumi_basic",read_only=true,read_on_configure=false,emit=y(nil,nil,nil,v.miMotionRestarts())}),O(v.miMotionRestarts())}}
local function u(br,af,D,aS,I,p1,w)
local L=D==nil
local r={profile=br,zcl_clusters={h.cluster_attribute(L and 1024 or 64704,L and 0 or 274,{name="lumi_motion_light",read_only=true,read_on_configure=false,emit=aI(I,L)}),h.cluster_attribute(L and 0 or 64704,L and 65281 or 247,{name="lumi_motion_diagnostics",read_only=true,read_on_configure=false,emit=y(af,D,p1,w)})}}if L then
r.zcl_clusters[#r.zcl_clusters+1]=O(w)r.zcl_clusters[#r.zcl_clusters+1]=h.cluster_attribute(1030,0,{name="lumi_occupancy",read_only=true,read_on_configure=false,emit=al})else
local aB=h.battery{read_on_configure=false,read_only=true}aB.minimum_interval,aB.maximum_interval,aB.reportable_change=nil,nil,nil
r.zcl_clusters[#r.zcl_clusters+1]=aB
r.zcl_clusters[#r.zcl_clusters+1]=h.cluster_attribute(64704,258,{name=aS,mfg_code=4447,read_only=true,read_on_configure=true,emit=D,from_device=d,
handler=function(a,b)a:set_field("__lumi_detection_interval",b)end
})r.zcl_clusters[#r.zcl_clusters+1]=h.cluster_attribute(1,32,{name="lumi_battery_voltage",read_only=true,read_on_configure=true,
emit=function(_,b)
local ao=d(b)if ao==255 then return end
return{e.battery.battery(j(ao*100)),e.voltageMeasurement.voltage{value=ao/10,unit="V"}}
end
})end
return r
end
local bg,bj,bi,p=u("safety-aqara-motion-m11",v.aqM11DeviceTemp"C",nil,nil,nil,nil,v.aqM11Restarts()),u("safety-aqara-motion-t1",v.aqT1DeviceTemp"C",v.aqT1Interval"s","aq_t_one_interval",60,nil,v.aqT1Restarts()),u("safety-aqara-motion-e1",v.aqE1DeviceTemp"C",v.aqE1Interval"s","aq_e_one_interval",60,nil,v.aqE1Restarts()),u("safety-aqara-motion-p1",v.aqP1DeviceTemp"C",v.aqP1Interval"s","aq_p_one_interval",30,true)p.zcl_clusters[#p.zcl_clusters+1]=h.cluster_attribute(64704,268,{name="aq_p_one_sensitivity",data_type=A.Uint8,write_type=A.Uint8,mfg_code=4447,read_on_configure=true,emit=v.aqP1Sensitivity(),
from_device=function(b)return({[1]="low",[2]="medium",[3]="high"})[d(b)]end,
to_device=function(b)return({low=1,medium=2,high=3})[b]end
})p.zcl_clusters[#p.zcl_clusters+1]=h.cluster_attribute(64704,338,{name="aq_p_one_indicator",data_type=A.Uint8,write_type=A.Uint8,mfg_code=4447,read_on_configure=true,emit=v.aqP1Indicator(),
from_device=function(b)return d(b)==1 and"on"or"off"end,
to_device=function(b)return({on=1,off=0})[b]end
})
local function N()
return h.switch("contact",{emit=v.contact(),read_only=true})
end
local aE,f={profile="safety-contact-battery-voltage",zcl_clusters={N(),h.cluster_attribute(l,q,{name="lumi_basic",emit=m,read_only=true})}},{profile="safety-contact-tamper-battery-voltage",zcl_clusters={N(),h.tamper(),h.cluster_attribute(l,q,{name="lumi_basic",emit=m,read_only=true}),h.battery(),h.battery_voltage()}}do
local av,at,U,T,aO,ai,bc,aQ,aH=require"st.zigbee.cluster_base",{persist=true},{persist=false},"aqara_p1:",v.aqP1IntervalV2"s",v.aqContactP1Distance(),v.aqP1NoOccupancySince"s",{[1]="10mm",[2]="20mm",[3]="30mm"},{["10mm"]=1,["20mm"]=2,["30mm"]=3}
local function aj(b)
return type(b)=="number"and b==b and b>-math.huge and b<math.huge
end
local function aA(b)
return aj(b)and b%1==0 and b>=2 and b<=255
end
local function i(b)
local o=ar(d(b))return type(o)=="table"and o or{}
end
local function ad(a,b,K)
local aL=K and K.typed_value
if type(aL)=="table"and(aL.ID==57 or aL.ID==58)then
b=string.unpack(aL.ID==57 and"<f"or"<d",aL:_serialize())end
if type(b)=="table"then b=b.value end
if type(b)=="boolean"then b=b and 1 or 0 end
if not aj(b)then return end
a:set_field("__lumi_detection_interval",b,at)return aO(a,b)
end
local function aa(a,k,s)
local ap=av.read_manufacturer_specific_attribute(a,64704,k,4447):to_endpoint(1)if s then ap.body.zcl_header.frame_ctrl:set_disable_default_response()end
return a:send(ap)~=false
end
local function aZ(a,aC,b)
local k=aC.attribute_id
if k==258 then
if not aA(b)then return false end
elseif aC.to_device then
b=aC.to_device(b)if b==nil then return false end
else
if type(b)~="string"then return false end
b=aH[b:lower()]if b==nil then return false end
end
local ap,s=av.write_manufacturer_specific_attribute(a,64704,k,4447,A.Uint8,b):to_endpoint(1),aC.name~="aq_contact_p_one_distance"if s then ap.body.zcl_header.frame_ctrl:set_disable_default_response()end
if not pcall(a.send,a,ap)then return false end
pcall(aa,a,k,s)return true
end
p.zcl_clusters[4]=h.cluster_attribute(64704,258,{name="aq_p_one_interval",endpoint=1,mfg_code=4447,write_type=A.Uint8,sender=aZ,suppress_optimistic_state=true,read_on_configure=false,emit=ad})for _,W in ipairs{6,7}do
p.zcl_clusters[W].read_on_configure=false
p.zcl_clusters[W].sender=aZ
p.zcl_clusters[W].suppress_optimistic_state=true
end
p.configure=function(_,a)
for _,k in ipairs{258,268,338}do aa(a,k,true)end
end
p.parent_refresh=function(a)
h.read_attribute(a,1,32,1)for _,k in ipairs{258,268,338}do aa(a,k,true)end
end
local aD=y(v.aqP1DeviceTemp"C",nil,false)
p.zcl_clusters[2].emit=function(a,ao)
local o=i(ao)local c,t=aD(a,o)or{},ad(a,g(o,105))if t then c[#c+1]=t end
local G=({[1]="low",[2]="medium",[3]="high"})[d(g(o,106))]if G then c[#c+1]=v.aqP1Sensitivity()(a,G)end
local indicator=d(g(o,107))if indicator~=nil then c[#c+1]=v.aqP1Indicator()(a,indicator==1 and"on"or"off")end
return #c>0 and c or nil
end
local function aG(a)
local aY=a.preferences.aqP1NoOccupancySeconds
if aY==nil or type(aY)=="string"and aY:match"^%s*$"then
a:set_field(T.."since_thresholds",{},at)return{}end
if type(aY)~="string"then return a:get_field(T.."since_thresholds")or{}end
local aM={}for bA in(aY..","):gmatch"(.-),"do
local b=tonumber(bA)if not aj(b)or b<0 then return a:get_field(T.."since_thresholds")or{}end
aM[#aM+1]=b
end
a:set_field(T.."since_thresholds",aM,at)return aM
end
local function aJ(bs)
local Y=bs*1000
if Y<1 or Y>2147483647 then return 0.001 end
return math.floor(Y)/1000
end
p.zcl_clusters[1].emit=function(a,ao)
local Z=a:get_field"__lumi_motion_timer"if Z then
a.thread:cancel_timer(Z)a:set_field("__lumi_motion_timer",nil,U)end
local az=a:get_field(T.."since_timers")or{}for _,bz in ipairs(az)do a.thread:cancel_timer(bz)end
az={}a:set_field(T.."since_timers",az,U)for _,b in ipairs(aG(a))do
az[#az+1]=a.thread:call_with_delay(aJ(b),function()
local bp=bc(a,b)bp.state_change=true
a:emit_event(bp)
end,"Aqara P1 no occupancy since")
end
local t=a:get_field"__lumi_detection_interval"if t==nil then t=30 end
local z=tonumber(a.preferences.occupancyTimeout)local Q=z~=nil and z>=t and z or t+2
if Q~=0 then
a:set_field("__lumi_motion_timer",a.thread:call_with_delay(aJ(Q),function()
a:set_field("__lumi_motion_timer",nil,U)a:emit_event(e.motionSensor.motion.inactive())
end,"Aqara P1 motion reset"),U)
end
local bk=d(ao)local bu=bk>130536 and 0 or bk-65536
return{e.motionSensor.motion.active(),e.illuminanceMeasurement.illuminance(math.max(0,bu))}
end
local function aw(a,as)
if not aj(as)then return end
local am,maximum=a.preferences.aqContactP1BatteryMinMv,a.preferences.aqContactP1BatteryMaxMv
if not aj(am)or not aj(maximum)or am>=maximum then am,maximum=2850,3000 end
local F=math.floor(math.max(0,math.min(100,(as-am)*100/(maximum-am)))+0.5)return{e.battery.battery(F),e.voltageMeasurement.voltage{value=as/1000,unit="V"}}
end
local function J(a,b)
local o=i(b)local c,aU=aw(a,d(g(o,1)))or{},aQ[d(g(o,159))]if aU then c[#c+1]=ai(a,aU)end
local bn=d(g(o,320))if bn==0 then c[#c+1]=e.tamperAlert.tamper.clear()elseif bn==1 then c[#c+1]=e.tamperAlert.tamper.detected()end
return #c>0 and c or nil
end
f.profile="safety-aqara-contact-p1"f.button_actions={"pushed"}f.reporting_capability_exclusions={["*"]="Z2M MCCGQ13LM uses native reports and check-in; configurable reporting support is unconfirmed."}f.zcl_clusters[#f.zcl_clusters+1]=h.contact()f.zcl_clusters[5].scale=nil
f.zcl_clusters[5].from_device=function(_,_,K)return K.raw_value end
f.zcl_clusters[5].emit=function(a,b)
b=d(b)if b==255 then return end
return aw(a,b*100)
end
f.zcl_clusters[#f.zcl_clusters+1]=h.cluster_attribute(64704,247,{name="aq_contact_p_one_heartbeat",endpoint=1,read_only=true,read_on_configure=false,emit=J})for _,k in ipairs{1,159,65281,320}do
f.zcl_clusters[#f.zcl_clusters+1]=h.cluster_attribute(64704,k,{name=string.format("aq_contact_p_one_native_%04x",k),endpoint=1,read_only=true,read_on_configure=false,read_on_refresh=false,
emit=function(a,b)
if k==65281 then return J(a,b)end
return J(a,{[k]=d(b)})
end
})end
f.zcl_clusters[#f.zcl_clusters+1]=h.cluster_attribute(64704,268,{name="aq_contact_p_one_distance",endpoint=1,mfg_code=4447,write_type=A.Uint8,sender=aZ,suppress_optimistic_state=true,read_on_configure=false,
from_device=function(b)return aQ[d(b)]end,emit=ai
})
f.zigbee_message_handler=function(a,rx)
local ak,bd=rx.body and rx.body.zcl_header,rx.address_header
if not ak or bd.src_endpoint.value~=1 or bd.cluster.value~=0 or
ak.cmd.value~=10 or ak.frame_ctrl:is_cluster_specific_set()or
not ak.frame_ctrl:is_direction_set()then return end
local aF=ak.seqno and ak.seqno.value
if aF~=nil then
local bw,E=math.floor(require"cosock.socket".gettime()*1000),a:get_field(T.."action_transactions")or{}for _,bo in ipairs(E)do
if bo.sequence==aF and bo.expires>bw then return end
end
for W=#E,1,-1 do if E[W].expires<=bw then table.remove(E,W)end end
if #E>4 then
local aW=1
for W=2,#E do if E[W].expires<E[aW].expires then aW=W end end
table.remove(E,aW)end
E[#E+1]={sequence=aF,expires=bw+10000}a:set_field(T.."action_transactions",E,U)end
for _,bm in ipairs(rx.body.zcl_body.attr_records or{})do
if bm.attr_id.value==5 and bm.data.value=="lumi.magnet.ac01"then
a:emit_event(e.button.button.pushed{state_change=true})break
end
end
end
end
local au,ay,H,C={profile="safety-contact-battery-low-battery-voltage",zcl_clusters={h.contact(),h.battery_low(),h.battery(),h.battery_voltage()}},{profile="safety-contact-battery-voltage",zcl_clusters={h.contact(),h.battery(),h.battery_voltage()}},{profile="safety-water-leak-battery-low-battery-voltage",zcl_clusters={h.water(),h.battery_low(),h.cluster_attribute(l,q,{name="lumi_basic",emit=m,read_only=true}),h.battery(),h.battery_voltage()}},{profile="safety-water-leak-tamper-battery-low-battery-voltage",zcl_clusters={h.water(),h.tamper(),h.battery_low(),h.cluster_attribute(l,q,{name="lumi_basic",emit=m,read_only=true}),h.battery(),h.battery_voltage()}}n(ac,{fp("LUMI","lumi.sens"),fp("LUMI","lumi.sensor_ht")})n(ag,{fp("LUMI","lumi.weather")})n(ba,{fp("LUMI","lumi.sensor_ht.agl02")})n(bb,{fp("LUMI","lumi.sen_ill.agl01"),fp("LUMI","lumi.sen_ill.mgl01")})n(bv,{fp("LUMI","lumi.sensor_motion")})n(p,{fp("LUMI","lumi.motion.ac02")})n(bi,{fp("LUMI","lumi.motion.acn001")})n(bj,{fp("LUMI","lumi.motion.agl02")})n(bg,{fp("LUMI","lumi.sensor_motion.aq2")})n(f,{fp("LUMI","lumi.magnet.ac01")})n(au,{fp("LUMI","lumi.magnet.acn001")})n(ay,{fp("LUMI","lumi.magnet.agl02")})n(aE,{fp("LUMI","lumi.sensor_magnet"),fp("LUMI","lumi.sensor_magnet.aq2")})n(H,{fp("LUMI","lumi.flood.acn001"),fp("LUMI","lumi.sensor_wleak.aq1")})n(C,{fp("LUMI","lumi.flood.agl02")})h.attach_reporting_capabilities(S,{{1,"sensors-temp-humidity-battery-voltage",{zr00010021auto=false,zr04020000auto=false,zr04050000auto=false}},{2,"sensors-temp-humidity-pressure-battery-voltage",{zr00010020auto=false,zr00010021auto=false,zr04020000auto=false,zr04030000auto=false,zr04050000auto=false}},{3,"rpt-lno"},{4,"rpt-lvz"},{10,"safety-aqara-contact-p1",{zr00010020auto=false,zr00010021auto=false,zr00060000auto=false,zr05000002auto=false}},{11,"rpt-tku"},{12,"rpt-tvc"},{13,"rpt-lhf"},{14,"rpt-lbp"},{15,"rpt-ljh"}})return{id="zcl.sensors.aqara_lumi",registrations=S}
