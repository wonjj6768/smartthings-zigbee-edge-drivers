local d,s,b,h,g,aH,x,ag,aB=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.zcl",require"st.zigbee.data_types",require"st.zigbee.cluster_base",require"st.zigbee.device_management",require"st.zigbee.zcl.clusters".OnOff,require"st.zigbee.constants"
local w,a=b.definition_registry()
local function r(aI,bc)
local ac={}for _,bd in ipairs(bc)do
ac[#ac+1]=b.create_fingerprint(aI,bd)end
return ac
end
local function j(an,B)
return{profile=an,zcl_clusters=B}
end
local function i(T,ar,ax)
return function(A,f)
for _,m in ipairs(T)do
f:send(x.build_bind_request(f,d.CLUSTER_ON_OFF,A.environment_info.hub_zigbee_eui,m))if ar then
d.configure_reporting(f,{cluster=ag.ID,attribute=ag.attributes.OnOff.ID,data_type=ag.attributes.OnOff.base_type,minimum_interval=0,maximum_interval=3600},m,{auto_endpoint=not ax,defer_on_override=true})end
end
end
end
local function P(an,T,ab)
ab=ab or{}local B={}for aE,m in ipairs(T)do
B[#B+1]=d.switch{endpoint=m,component=aE==1 and"main"or("switch"..tostring(aE))}end
h.append_clusters(B,h.metering_clusters{endpoint=T[1],include_switch=false,include_current=true,energy_scale=100})if ab.tuya_magic then
h.append_clusters(B,d.tuya_magic_packet())end
if ab.power_outage_memory then
h.append_clusters(B,d.tuya_power_outage_memory())end
local D=j(an,B)if ab.bind_on_off then
D.configure=i(T,ab.configure_on_off_reporting,true)end
return D
end
local function E(aD)
return h.metering_clusters{include_switch=true,include_current=aD}
end
local z,q=j("plugs-switch",{d.switch()}),j("plugs-switch",{d.switch(),d.tuya_magic_packet()})q.configure=i({1},true)local X=j("plugs-lidl-hg06337",{d.switch{endpoint=11,component="main"},d.tuya_magic_packet(),d.indicator_mode{endpoint=11}})X.configure=i({11},true,true)local af=j("plugs-switch-child-lock",{d.switch(),d.tuya_magic_packet(),d.child_lock()})af.configure=i({1},true)local ae=j("plugs-switch-tuya-options",{d.switch(),d.tuya_magic_packet(),d.tuya_power_outage_memory(),d.indicator_mode(),d.child_lock(),d.countdown_timer()})ae.configure=i({1},true)local O=j("plugs-zemismart-zmo606-20a",{d.switch(),d.tuya_magic_packet(),d.indicator_mode(),d.child_lock(),d.countdown_timer()})O.configure=i({1},true)
local function au(c)
if type(c)=="table"and type(c.is_alarm1_set)=="function"and type(c.is_alarm2_set)=="function"then
return{water=c:is_alarm1_set(),tank=c:is_alarm2_set()and"full"or"normal"}end
if type(c)=="table"and c.value~=nil then
c=c.value
end
if type(c)~="number"then
return nil
end
return{water=c%2==1,tank=math.floor(c/2)%2==1 and"full"or"normal"}
end
local function aq(aT)
local aX=aT and aT.body and aT.body.zcl_body or nil
local I=aX and(aX.zone_status or aX.zonestatus)or nil
if I==nil then
return nil
end
return{raw_value=type(I)=="table"and I.value or I,typed_value=I}
end
local e={}for m=1,5 do
e[#e+1]=d.switch{endpoint=m,component=m==1 and"main"or("switch"..tostring(m))}end
for m=1,3 do
e[#e+1]=d.cluster_attribute(d.CLUSTER_ON_OFF,61443,{name="bacchus_pump_duration",endpoint=m,component=m==1 and"main"or("switch"..tostring(m)),emit=s.bacchusPumpDuration(),data_type=g.Uint16,write_type=g.Uint16,numeric_range={minimum=0,maximum=600,step=1},read_on_configure=true})end
e[#e+1]=d.cluster_attribute(d.CLUSTER_ON_OFF,61445,{name="bacchus_beeper_on_leak",endpoint=1,component="main",emit=s.bacchusBeeperOnLeak(),
from_device=function(c)return c and"on"or"off"end,
to_device=function(c)return c=="on"end,
data_type=g.Boolean,write_type=g.Boolean,read_on_configure=true})local ak,Y=s.water(),s.bacchusTankFull()e[#e+1]=d.ias_zone{name="bacchus_tank_full",endpoint=6,component="tank",
emit=function(f,c)
return ak(f,c.water)
end,
handler=function(f,c)
local aC=Y(f,c.tank)if aC~=nil then
f:emit_component_event({id="tank"},aC)end
end,
from_device=au,prefer_typed_value=true,ias_configure_method=aB.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=aq}local J=j("plugs-bacchus-water-station",e)
J.configure=function(A,f)
i({1,2,3,4,5},true,true)(A,f)f:send(x.build_bind_request(f,d.CLUSTER_IAS_ZONE,A.environment_info.hub_zigbee_eui,6))
end
local ai=j("plugs-switch-2",{d.switch{endpoint=1,component="main"},d.switch{endpoint=7,component="switch2"},d.tuya_magic_packet()})ai.configure=i{1,7}local aJ,t,l=j("plugs-switch-power-energy-voltage",E(false)),j("plugs-switch-power-energy-voltage-current",E(true)),j("plugs-switch-power-energy-voltage-current",{d.switch(),d.power(),d.energy{scale=100},d.voltage(),d.current(),d.tuya_magic_packet()})
l.configure=function(A,f)
for _,K in ipairs{d.CLUSTER_ON_OFF,2820,1794}do
f:send(x.build_bind_request(f,K,A.environment_info.hub_zigbee_eui,1))end
end
local u=j("plugs-switch-power-voltage-current",{d.switch(),d.power(),d.voltage(),d.current()})
u.configure=function(A,f)
for _,K in ipairs{d.CLUSTER_ON_OFF,2820}do
f:send(x.build_bind_request(f,K,A.environment_info.hub_zigbee_eui,1))end
end
local at,ad,aA=j("switch-power-energy",{d.switch(),d.power(),d.energy()}),j("switches-switch-1-power-energy-voltage-current",h.metering_clusters{endpoint=2,switch_component="main",include_current=true}),P("plugs-wp30-power-strip",{1,2,3},{tuya_magic=true,power_outage_memory=true,bind_on_off=true,configure_on_off_reporting=true})
local function aw(aN)
return function(c)
if type(c)=="table"then c=c.value end
return aN[c]
end
end
local function az(aN)
return function(c)
return aN[c]
end
end
local function k(bf,m,ah,K,aG,bb,aO,aV)
return d.cluster_attribute(K,aG,{name=bf,endpoint=m,component=ah,emit=bb,from_device=aw(aO),to_device=az(aV),data_type=g.Enum8,write_type=g.Enum8,read_on_configure=true})
end
local function S(an,as)
local D=j(an,{d.switch(),d.power(),d.energy{scale=100},d.voltage(),d.current(),d.tuya_magic_packet(),k("ts011f_plug1_power_outage_memory",1,"main",d.CLUSTER_ON_OFF,32770,s.ts011fPlug1PowerOutageMemory(),{[0]="off",[1]="on",[2]="restore"},{off=0,on=1,restore=2}),k("ts011f_plug1_indicator_mode",1,"main",d.CLUSTER_ON_OFF,32769,s.ts011fPlug1IndicatorMode(),{[0]="off",[1]="off_on",[2]="on_off",[3]="on"},{off=0,off_on=1,on_off=2,on=3}),d.cluster_attribute(d.CLUSTER_ON_OFF,32768,{name="ts011f_plug1_child_lock",endpoint=1,component="main",emit=s.ts011fPlug1ChildLock(),data_type=g.Boolean,write_type=g.Boolean,
from_device=function(c)return c and"on"or"off"end,
to_device=function(c)return c=="on"end,read_on_configure=true
}),d.countdown_timer{name="ts011f_plug1_countdown",endpoint=1,component="main",emit=s.ts011fPlug1Countdown()}})if as then
h.append_clusters(D.zcl_clusters,k("ts011f_plug1_switch_type_button",1,"main",57345,53296,s.ts011fPlug1SwitchTypeButton(),{[0]="release",[1]="press"},{release=0,press=1}))end
D.configure=l.configure
return D
end
local aM,aj,M=S("plugs-switch-power-energy-voltage-current-ts011f-plug1",true),S("plugs-switch-power-energy-voltage-current-ts011f-plug1-no-button",false),k("nous_a6z_button_type",1,"main",57345,53296,s.nousA6zButtonType(),{[0]="release",[1]="press"},{release=0,press=1})
M.sender=function(f,am,c,R)
local aP=am.to_device(c)if aP==nil then return false end
local aR=aH.write_attribute(f,g.ClusterId(57345),g.AttributeId(53296),g.Enum8(aP))aR.body.zcl_header.frame_ctrl:set_disable_default_response()f:send(aR:to_endpoint(R.endpoint or 1))return true
end
local ap=j("plugs-nous-a6z",{d.switch{endpoint=1,configure_reporting=false},d.power{endpoint=1,read_only=true,poll_interval=false,minimum_interval=5,maximum_interval=3600,reportable_change=10},d.energy{endpoint=1,read_only=true,poll_interval=false,scale=100,ignore_reported_scaler=true,minimum_interval=5,maximum_interval=3600,reportable_change=257},d.voltage{endpoint=1,read_only=true,poll_interval=false,minimum_interval=5,maximum_interval=3600,reportable_change=5},d.current{endpoint=1,read_only=true,poll_interval=false,ignore_reported_scaler=true,minimum_interval=5,maximum_interval=3600,reportable_change=50},d.tuya_magic_packet(),k("nous_a6z_power_memory",1,"main",d.CLUSTER_ON_OFF,32770,s.nousA6zPowerMemory(),{[0]="off",[1]="on",[2]="restore"},{off=0,on=1,restore=2}),k("nous_a6z_indicator",1,"main",d.CLUSTER_ON_OFF,32769,s.nousA6zIndicator(),{[0]="off",[1]="off_on",[2]="on_off",[3]="on"},{off=0,off_on=1,on_off=2,on=3}),d.cluster_attribute(d.CLUSTER_ON_OFF,32768,{name="nous_a6z_child_lock",endpoint=1,emit=s.nousA6zChildLock(),data_type=g.Boolean,write_type=g.Boolean,read_on_configure=true,
from_device=function(c)return c and"on"or"off"end,
to_device=function(c)return c=="on"end
}),d.countdown_timer{name="nous_a6z_countdown",endpoint=1,emit=s.nousA6zCountdown(),
from_device=function(c,_,R)
local rx=R.zb_rx
for _,n in ipairs(rx and rx.body.zcl_body.attr_records or{})do
if n.attr_id.value==16386 and(not n.status or n.status.value==0)and n.data_type and n.data_type.value==33 and n.data then return nil end
end
return c
end,
to_device=function(c)
if type(c)~="number"or c%1~=0 or c<0 or c>43200 then return nil end
return string.pack("<BI2I2",0,c,c)
end},
d.cluster_attribute(d.CLUSTER_ON_OFF,16386,{name="nous_a6z_off_wait_time",endpoint=1,read_only=true,data_type=g.Uint16,read_on_configure=true,emit=s.nousA6zCountdown()}),M,d.cluster_attribute(3,0,{name="nous_a6z_identify",endpoint=1,write_only=true,tx_command_id=0,
to_device=function(c)
if type(c)~="number"or c%1~=0 or c<1 or c>30 then return nil end
return string.pack("<I2",c)
end
})})for _,am in ipairs(ap.zcl_clusters)do am.suppress_optimistic_state=true end
ap.configure=l.configure
ap.capability_commands={{capability_id="concertmirror08464.nousA6zCountdown",command_name="setCountdown",mapping_name="nous_a6z_countdown",argument_name="countdown"},{capability_id="concertmirror08464.nousA6zIdentify",command_name="identify",mapping_name="nous_a6z_identify",value=3},{capability_id="concertmirror08464.nousA6zIdentify",command_name="setIdentifyTime",mapping_name="nous_a6z_identify",argument_name="identifyTime"}}
local function ao(f,_,c,R)
if c~="identify"then
return false
end
return d.send_raw_cluster_command(f,3,0,string.char(3,0),R.endpoint or 1)
end
local y=P("plugs-nous-a11z",{1,2,3})h.append_clusters(y.zcl_clusters,d.tuya_magic_packet())for aE,m in ipairs{1,2,3}do
local ah=aE==1 and"main"or("switch"..tostring(aE))h.append_clusters(y.zcl_clusters,k("nous_a11z_power_on_behavior",m,ah,57345,53264,s.nousA11zPowerBehavior(),{[0]="off",[1]="on",[2]="previous"},{off=0,on=1,previous=2}),d.countdown_timer{name="nous_a11z_countdown",endpoint=m,component=ah,emit=s.nousA11zCountdown()})end
h.append_clusters(y.zcl_clusters,k("nous_a11z_indicator_mode",1,"main",d.CLUSTER_ON_OFF,32769,s.nousA11zIndicatorMode(),{[0]="off",[1]="off_on",[2]="on_off",[3]="on"},{off=0,off_on=1,on_off=2,on=3}),d.cluster_attribute(d.CLUSTER_ON_OFF,32768,{name="nous_a11z_child_lock",endpoint=1,component="main",emit=s.nousA11zChildLock(),
from_device=function(c)return c and"on"or"off"end,
to_device=function(c)return c=="on"end,
data_type=g.Boolean,write_type=g.Boolean,read_on_configure=true}),k("nous_a11z_switch_type",1,"main",57345,53296,s.nousA11zSwitchType(),{[0]="release",[1]="press"},{release=0,press=1}),d.cluster_attribute(3,nil,{name="nous_a11z_identify",endpoint=1,component="main",write_only=true,enum_values={"identify"},sender=ao}))a(q,b.create_fingerprints("TS011F",{"_TZ3000_oiymh3qu"}))a(q,b.create_fingerprints("TS0101",{"_TZ3000_pnzfdr9y","_TYZB01_ijihzffk"}))a(z,b.create_fingerprints("TS0101",{"_TZ3210_eymunffl","_TZ3210_tfxwxklq","_TZ3210_2dfy6tol"}))a(ai,b.create_fingerprints("TS0108",{"_TYZB01_7yidyqxd"}))a(af,b.create_fingerprints("TS011F",{"_TZ3000_wxtp7c5y","_TYZB01_mtunwanm"}))a(ae,b.create_fingerprints("TS011F",{"_TZ3000_hyfvrar3","_TZ3000_v1pdxuqq","_TZ3000_8a833yls","_TZ3000_bfn1w0mm","_TZ3000_nzkqcvvs","_TZ3000_rtcrrvia","_TZ3000_ysiog9xi","_TZ3000_o1jzcxou","_TZ3210_nhqka112","_TZ3000_uyrhiafs"}))a(q,b.create_fingerprints("TS011F",{"_TZ3000_8fdayfch","_TZ3000_1hwjutgo","_TZ3000_lnggrqqi","_TZ3000_tvuarksa"}))a(X,b.create_fingerprints("TS011F",{"_TZ3000_00mk2xzy","_TZ3000_upjrsxh1","_TZ3000_plyvnuf5","_TZ3000_wamqdr3f"}))a(O,b.create_fingerprints("TS011F",{"_TZ3000_b1q8kwmh"}))a(J,{b.create_fingerprint("Bacchus","Water_Station"),b.create_fingerprint("Bacchus","Water_Station.Modkam")})a(l,b.create_fingerprints("TS011F",{"_TZ3000_ko6v90pg","_TZ3008_1a8m8wd6","_TZ3008_reatplte","_TZ3210_2putqrmw","_TZ3210_2uollq9d","_TZ3210_4ux0ondb","_TZ3210_zifx0xoj","_TZ3000_4ux0ondb","_TZ3000_b28wrpvx","_TZ3000_2uollq9d","_TZ3000_cehuw1lw","_TZ3000_9ni6xxld","_TZ3210_5ct6e7ye","_TZ3000_2putqrmw","_TZ3000_ksw8qtmt","_TZ3000_yujkchbz","_TZ3000_ss98ec5d","_TZ3000_y4ona9me","_TZ3000_266azbg3","_TZ3000_3ias4w4o","_TZ3210_ddigca5n","_TZ3210_rwmitwj4","_TZ3000_gjnozsaz","_TZ3210_jlf1nepw","_TZ3000_cjrngdr3","_TZ3210_cjrngdr3","_TZ3000_amdymr7l","_TZ3000_zloso4jk"}))a(aM,b.create_fingerprints("TS011F",{"_TZ3008_tary5dvv","_TZ3210_iooniers","_TZ3008_iooniers","_TZ3008_xvfd3nkp","_TZ3008_qziabvzj","_TZ3210_w0qqde0g"}))a(aj,b.create_fingerprints("TS011F",{"_TZ3000_w0qqde0g"}))a(l,{{manufacturer="AOYAN  ",model="TS011F"}})a(aJ,{b.create_fingerprint("LUMI","lumi.ctrl_86plug"),b.create_fingerprint("LUMI","lumi.ctrl_86plug.aq1"),b.create_fingerprint("LUMI","lumi.plug"),b.create_fingerprint("LUMI","lumi.plug.aq1"),b.create_fingerprint("LUMI","lumi.plug.mitw01")})a(t,{b.create_fingerprint("LUMI","lumi.plug.aeu001"),b.create_fingerprint("LUMI","lumi.plug.macn01"),b.create_fingerprint("LUMI","lumi.plug.maeu01"),b.create_fingerprint("LUMI","lumi.plug.maus01"),b.create_fingerprint("LUMI","lumi.plug.mmeu01"),b.create_fingerprint("LUMI","lumi.plug.sacn02")})a(ad,{b.create_fingerprint("frient A/S","SMRZB-153")})a(at,{b.create_fingerprint("Schneider Electric","SMARTPLUG/1")})a(l,b.create_fingerprints("TS011F",{"_TZ3000_3uimvkn6","_TZ3000_j1v25l17","_TZ3000_ynmowqk2","_TZ3000_0yxeawjt"}))a(u,{b.create_fingerprint("AduroSmart ERIA","ONOFF_METER_RELAY"),b.create_fingerprint("HEIMAN","SmartPlug-N")})a(z,{b.create_fingerprint("Third Reality, Inc","3RSP019BZ")})a(t,{b.create_fingerprint("Third Reality, Inc","3RSP02028BZ"),b.create_fingerprint("Third Reality, Inc","3RSPE01044BZ")})a(t,{b.create_fingerprint("Heiman","SmartPlug"),b.create_fingerprint("HEIMAN","SmartPlug"),b.create_fingerprint("HEIMAN","SmartPlug-EF-3.0")})a(z,r("LEDVANCE",{"Outdoor Plug","PLUG COMPACT EU T","PLUG OUTDOOR EU T","Plug Value"}))a(t,r("LEDVANCE",{"PLUG COMPACT OUTDOOR EU EM T","PLUG COMPACT EU EM T"}))a(z,r("OSRAM",{"Plug 01","Plug Z3"}))a(aA,b.create_fingerprints("TS011F",{"_TZ3000_c7nc9w3c","_TZ3210_c7nc9w3c"}))a(y,b.create_fingerprints("TS011F",{"_TZ3210_6cmeijtd"}))
local function L()
local p,aa=require"contracts.helpers.family",require"contracts.helpers.zcl"local aF,aK=p.definition_registry()local Q={profile="plugs-switch-power-energy-voltage",zcl_clusters=aa.metering_clusters{include_switch=true,include_current=false}}aK(Q,{p.create_fingerprint("SONOFF","S60ZBTPG")})aK(Q,{p.create_fingerprint("Innr","SP 242"),p.create_fingerprint("Innr","SP 244")})return aF
end
for _,aL in ipairs(L())do
w[#w+1]=aL
end
local N=j("plugs-switch-power-energy-voltage-current",{d.switch(),d.power{configure_reporting=false},d.energy{scale=100},d.voltage{configure_reporting=false},d.current{configure_reporting=false},d.tuya_magic_packet()})a(N,{b.create_fingerprint("_TZ3000_okaz9tjs","TS011F")})local C=j("plugs-switch-power-energy-voltage-current",{d.switch(),d.power{configure_reporting=false},d.energy{scale=100},d.voltage(),d.current(),d.tuya_magic_packet()})a(C,b.create_fingerprints("TS011F",{"_TZ3000_ww6drja5","Zbeacon","_TZ3000_cicwjqth"}))local H=s.hg06620Countdown()
local function F(_,_,R)
local Z=R.zb_rx
if Z.__hg06620_countdown~=nil then
return Z.__hg06620_countdown
end
local aQ,W
for _,n in ipairs(Z.body.zcl_body.attr_records)do
local c=n.data and n.data.value
if(n.status==nil or n.status.value==0)and
type(c)=="number"and c>=0 and c<=65535 and c%1==0 then
if n.attr_id.value==16385 then
aQ=c
elseif n.attr_id.value==16386 then
W=c
end
end
end
local aU={value=W~=nil and W or aQ}Z.__hg06620_countdown=aU
return aU
end
local function V(f,Z)
if Z.value==nil or Z.emitted then
return nil
end
Z.emitted=true
return H(f,Z.value)
end
local function U(c)
if type(c)~="number"or c<0 or c>43200 or c%1~=0 then
return nil
end
return{0,c,c}
end
local function al(f,_,c)
if type(c)~="boolean"then
return false
end
local ba=c and ag.server.commands.On or ag.server.commands.Off
f:send(ba(f):to_endpoint(1))local aC=H(f,0)if aC~=nil then
f:emit_event_for_endpoint(1,aC)end
return true
end
local G=j("plugs-lidl-hg06620",{d.switch{endpoint=1,component="main",minimum_interval=0,maximum_interval=3600,reporting_defaults={key="zr00060000auto",minimum_interval=0,maximum_interval=3600},sender=al},d.tuya_magic_packet(),d.cluster_attribute(d.CLUSTER_ON_OFF,16385,{name="hg06620_countdown",endpoint=1,component="main",data_type=g.Uint16,from_device=F,emit=V,tx_command_id=66,to_device=U,suppress_optimistic_state=true,read_on_configure=false,read_on_refresh=true}),d.cluster_attribute(d.CLUSTER_ON_OFF,16386,{name="hg06620_countdown_offwait_rx",endpoint=1,component="main",data_type=g.Uint16,from_device=F,emit=V,read_only=true,read_on_configure=false,read_on_refresh=false})})
G.configure=function(A,f)
i{1}(A,f)d.configure_reporting(f,{cluster=ag.ID,attribute=ag.attributes.OnOff.ID,data_type=ag.attributes.OnOff.base_type,minimum_interval=0,maximum_interval=3600},1,{auto_endpoint=true})
end
G.time_start="off"a(G,b.create_fingerprints("TS0101",{"_TZ3000_br3laukf"}))a(ap,b.create_fingerprints("TS011F",{"_TZ3008_avdpejns"}))
local function v(c,f)
if not f:get_field"__somfy_plug_duplicate"then return c end
end
local o={profile="plugs-somfy-metering",magic_packet=false,initial_custom_state_query=false,
component_to_endpoint=function()return 12 end,
endpoint_to_component=function()return"main"end,
parent_refresh=function(f)d.read_attribute(f,6,0,12)end,
zcl_clusters={d.switch{endpoint=12,component="main",read_on_configure=false,suppress_optimistic_state=true,configure_reporting=false,reporting_defaults={minimum_interval=1,maximum_interval=3600}},d.cluster_attribute(1794,1024,{name="power",endpoint=12,component="main",read_only=true,data_type=g.Int24,emit=s.power(),metering_kind="demand",read_on_configure=false,from_device=v,reporting_defaults={minimum_interval=5,maximum_interval=3600,reportable_change=1}}),d.cluster_attribute(1794,0,{name="energy",endpoint=12,component="main",read_only=true,data_type=g.Uint48,emit=s.energy(),metering_kind="summation",read_on_configure=false,from_device=v,reporting_defaults={minimum_interval=5,maximum_interval=3600,reportable_change=257}}),d.cluster_attribute(1794,1,{name="produced_energy",endpoint=12,component="export",read_only=true,data_type=g.Uint48,emit=s.energy(),metering_kind="summation",read_on_configure=false,from_device=v,reporting_defaults={minimum_interval=5,maximum_interval=3600,reportable_change=257}})}}
o.configure=function(A,f)
for _,aZ in ipairs{0,3,6,1794}do
d.bind_cluster(f,aZ,A.environment_info.hub_zigbee_eui,12)end
for _,am in ipairs(o.zcl_clusters)do
local aS=d.mapping_meta(am)local ay=aS.reporting_defaults
d.configure_reporting(f,{cluster=aS.cluster_id,attribute=aS.attribute_id,data_type=aS.data_type,minimum_interval=ay.minimum_interval,maximum_interval=ay.maximum_interval,reportable_change=ay.reportable_change},12,{defer_on_override=true})end
end
o.zigbee_message_handler=function(f,rx)
local av=rx.body.zcl_header
f:set_field("__somfy_plug_duplicate",false,{persist=false})if rx.address_header.src_endpoint.value~=12 or rx.address_header.cluster.value~=1794
or av.frame_ctrl:is_cluster_specific_set()or av.frame_ctrl:is_mfg_specific_set()or(av.cmd.value~=1 and av.cmd.value~=10)then return end
f:set_field("__somfy_plug_duplicate",h.duplicate_transaction(f,12,av.seqno.value,"__somfy_plug_transactions"),{persist=false})for _,n in ipairs(rx.body.zcl_body.attr_records or{})do
local id=n.attr_id.value
if(id==769 or id==770)and n.data and(not n.status or n.status.value==0)then
d.handle_internal_attribute(f,1794,id,n.data,{endpoint=12,zcl_clusters=o.zcl_clusters})end
end
end
a(o,{b.create_fingerprint("SOMFY","1822647")})d.attach_reporting_capabilities(w,{{1,"rpt-zvs"},{2,"rpt-zvs"},{3,"rpt-zvs"},{4,"rpt-zef",{zr000600001="Switch",zr000600007="SwitchTwo"}},{5,"rpt-tpg"},{6,"rpt-tct"},{7,"rpt-zvs"},{8,"rpt-tqr"},{9,"rpt-tcp"},{10,"rpt-wzp",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour",zr000600005="SwitchFive"}},{11,"rpt-tcb"},{12,"rpt-txn"},{13,"rpt-trp"},{14,"rpt-tcb"},{15,"rpt-lsu"},{16,"rpt-tcb"},{17,"rpt-sho"},{18,"rpt-sbv"},{19,"rpt-tcb"},{20,"rpt-ogk"},{21,"rpt-zvs"},{22,"rpt-tcb"},{23,"rpt-tcb"},{24,"rpt-zvs"},{25,"rpt-tcb"},{26,"rpt-zvs"},{27,"rpt-txa",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{28,"rpt-ttq",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{29,"rpt-lsu"},{30,"rpt-lsu"},{31,"rpt-tpp"},{32,"rpt-tzo"},{33,"rpt-toma"},{34,"rpt-txe"},{35,"rpt-zay"}})return{id="zcl.plugs",registrations=w}
