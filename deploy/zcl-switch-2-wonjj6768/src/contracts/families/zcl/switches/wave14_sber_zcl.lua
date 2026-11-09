local aN,bV,N,ch,bR,bH,e=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.capabilities",require"st.zigbee.device_management",require"st.zigbee.cluster_base",require"st.zigbee.data_types"local bM,o=N.definition_registry()local K,g,H,I,bj,p,R,h,B,k,G,aO,bq,U,aq,bG,ae,at,W,Y,Z,as,E,D,A,P,v,u,O,bw,aC,ai,af,ah,Q,aQ,aP,aG,au,ag,bo,bp,aZ,ba,aR,bf,bg,aF,bb,aU="concertmirror08464.",5423,0,2,3,6,18,258,2821,64719,13,18,0,16387,4316,85,8,23,4098,4099,8193,8194,8195,8196,8197,8198,8199,8200,8201,12289,12290,12305,12306,12307,12308,16385,16386,16387,16640,16641,0,4097,4098,4099,4100,4101,4102,4097,4098,4099
















































local function cE(capability_id)
return assert(bV[capability_id],"missing Wave14 Sber emitter: "..capability_id)()
end
local function m(r,n)
if n.read_only==nil then n.read_only=false end
r[#r+1]=n
return n
end
local function bl(bu)
local bJ={}for cA,f in pairs(bu or{})do bJ[cA]=f end
return bJ
end
local function by(w)
local bJ={}for cA,f in pairs(w or{})do
if cA~="mapping"then bJ[cA]=f end
end
return bJ
end
local function F(r,cj,cm,cD,cb)
for bh=cj,cm do
local n=r[bh]n.sber_dynamic_branch=cD
local bB=n.emit
if type(bB)=="function"then
n.emit=function(a,f,w,aK)
if not cb(a)then return nil end
return bB(a,f,w,aK)
end
end
local bm=n.handler
if type(bm)=="function"then
n.handler=function(a,f,w,aK)
if not cb(a)then return nil end
return bm(a,f,w,aK)
end
end
if n.read_only~=true then
local bU=bl(n)local ce={bU}
n.sender=function(a,_,f,w)
if not cb(a)then
return bU.name=="switch"end
return aN.send_named_command(a,ce,bU.name,f,by(w))
end
end
end
end
local function t(al,S,cc,capability_id,bn,bu)
local aJ=bl(bu)aJ.name=cc
aJ.emit=cE(capability_id)aJ.data_type=bn
aJ.write_type=aJ.write_type or bn
return aN.cluster_attribute(al,S,aJ)
end
local function y(S,cc,capability_id,bn,bu)
local aJ=bl(bu)aJ.mfg_code=g
return t(k,S,cc,capability_id,bn,aJ)
end
local function ax(f)
return(f==true or f==1)and"ON"or"OFF"
end
local function aA(f)
return f==true or f=="ON"or f=="on"
end
local function cp(f)
f=math.max(0,math.min(65535,math.floor(tonumber(f)or 0)))return string.char(f%256,math.floor(f/256)%256)
end
local function z(a,n,f,w)
local aS=f
if type(n.to_device)=="function"then
aS=n.to_device(f,a,w,n)end
if type(aS)=="number"then aS=math.floor(aS+0.5)end
if aS==nil then return false end
local bi
if n.mfg_code~=nil then
bi=bH.write_manufacturer_specific_attribute(a,n.cluster_id,n.attribute_id,n.mfg_code,n.write_type,aS)else
bi=bH.write_attribute(a,e.ClusterId(n.cluster_id),e.AttributeId(n.attribute_id),n.write_type(aS))end
if w.endpoint~=nil and type(bi.to_endpoint)=="function"then
bi=bi:to_endpoint(w.endpoint)end
a:send(bi)return true
end
local function bZ(aL)
return function(a,_,_,w)
return aN.send_raw_cluster_command(a,bj,0,cp(aL),w.endpoint,nil,nil,false)
end
end
local function bL(a,_,f,w)
local bY=({open=0,close=1,stop=2})[f]if bY==nil then return false end
return aN.send_raw_cluster_command(a,h,bY,"",w.endpoint,nil,nil,false)
end
local function bt(a,_,f,w)
local ct=math.max(0,math.min(100,math.floor(tonumber(f)+0.5)))local ca=100-ct
return aN.send_raw_cluster_command(a,h,5,string.char(ca),w.endpoint,nil,nil,false)
end
local function bx()
return function(_,f)
local bk=({[0]="held",[1]="pushed",[2]="double"})[f]if bk==nil then return nil end
local cz=ch.button.button(bk)cz.state_change=true
return cz
end
end
local function br(a,q,l,cr)
for _,al in ipairs(cr)do
a:send(bR.build_bind_request(a,al,q,l))end
end
local function aT(a,l,al,S,bX)
aN.read_attribute(a,al,S,l,bX)
end
local function x(a,l,al,cl,bX)
for _,S in ipairs(cl)do
aT(a,l,al,S,bX)end
end
local ck={{Z,"LedOnEnabled","led_on_enabled",e.Boolean,ax,aA,0,1,nil},{as,"LedOnHue","led_on_hue",e.Uint16,nil,nil,0,359,"°"},{E,"LedOnSaturation","led_on_saturation",e.Uint8,nil,nil,0,254,nil},{D,"LedOnBrightness","led_on_brightness",e.Uint8,nil,nil,1,254,nil},{A,"LedOffEnabled","led_off_enabled",e.Boolean,ax,aA,0,1,nil},{P,"LedOffHue","led_off_hue",e.Uint16,nil,nil,0,359,"°"},{v,"LedOffSaturation","led_off_saturation",e.Uint8,nil,nil,0,254,nil},{u,"LedOffBrightness","led_off_brightness",e.Uint8,nil,nil,1,254,nil}}
local function ak(r,c,capability_prefix,l,j,cs)
for bh,field in ipairs(ck)do
if not cs or bh>=5 then
m(r,y(field[1],c.."_"..field[3],capability_prefix..field[2],field[4],{endpoint=l,component=j,from_device=field[5],to_device=field[6],numeric_range=field[7]and{minimum=field[7],maximum=field[8],step=1,unit=field[9]}or nil}))end
end
end
local function aD(r,c,capability_prefix,l,j)
m(r,y(W,c.."_allow_double_click",capability_prefix.."AllowDoubleClick",e.Boolean,{endpoint=l,component=j,from_device=ax,to_device=aA}))
end
local function aj(r,c,capability_prefix,l,j)
m(r,t(p,U,c.."_power_on_behavior",capability_prefix.."PowerOnBehavior",e.Enum8,{endpoint=l,component=j,
from_device=function(f)
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[f]
end,
to_device=function(f)
return({off=0,on=1,toggle=2,previous=255})[f]
end
}))
end
local function bs(r,c,capability_prefix,l,j)
m(r,t(p,aq,c.."_relay_mode",capability_prefix.."RelayMode",e.Boolean,{endpoint=l,component=j,mfg_code=g,
from_device=function(f)return(f==true or f==1)and"decoupled"or"control_relay"end,
to_device=function(f)return f=="decoupled"end
}))
end
local function aH(r,J,c,capability_prefix,l,j,aL)
local bN=c.."_identify"m(r,aN.cluster_attribute(bj,nil,{name=bN,endpoint=l,component=j,write_only=true,sender=bZ(aL)}))J[#J+1]={capability_id=K ..capability_prefix.."Identify",command_name="identify",value=true,mapping_name=bN}
end
local function bc(r,l,j)
m(r,aN.cluster_attribute(R,bG,{name="button_action",endpoint=l,component=j,read_only=true,data_type=e.SinglePrecisionFloat,emit=bx()}))
end
local bQ={{bo,"ResetsCount","resets_count",e.Uint16,false},{bp,"Uptime","uptime",e.Uint32,true},{aZ,"ButtonClicksOne","button_clicks_one",e.Uint32,true},{ba,"ButtonClicksTwo","button_clicks_two",e.Uint32,true},{aR,"ButtonClicksThree","button_clicks_three",e.Uint32,true},{bf,"RelaySwitchesOne","relay_switches_one",e.Uint32,true},{bg,"RelaySwitchesTwo","relay_switches_two",e.Uint32,true}}
local function V(r,c,capability_prefix,l,j,cB,cF,C)
m(r,y(Y,c.."_child_lock",capability_prefix.."ChildLock",e.Boolean,{endpoint=l,component=j,from_device=ax,to_device=aA}))m(r,t(H,G,c.."_serial_number",capability_prefix.."SerialNumber",e.CharString,{endpoint=l,component=j,read_only=true,
from_device=function(f)return tostring(f)end
}))for bh,field in ipairs(bQ)do
local cC=bh<=2 or(bh>=3 and bh<=2+cB)or
(bh>=6 and bh<=5+cF)if cC then
m(r,t(B,field[1],c.."_"..field[3],capability_prefix..field[2],field[4],{endpoint=l,component=j,read_only=true,mfg_code=field[5]and g or nil}))end
end
if C then
m(r,y(ag,c.."_neutral_presence",capability_prefix.."NeutralPresence",e.Enum8,{endpoint=l,component=j,read_only=true,
from_device=function(f)return f==1 and"YES"or"NO"end
}))m(r,y(au,c.."_power_profile",capability_prefix.."PowerProfile",e.Enum8,{endpoint=l,component=j,
from_device=function(f)
return({[0]="quick",[1]="af_250",[2]="af_500",[3]="af_750",[4]="af_1000",[5]="af_1250",[6]="af_1750",[7]="af_2000",[254]="af_fallback"})[f]
end,
to_device=function(f)
return({quick=0,af_250=1,af_500=2,af_750=3,af_1000=4,af_1250=5,af_1750=6,af_2000=7,af_fallback=254})[f]
end
}))m(r,y(O,c.."_led_indication_type",capability_prefix.."LedIndicationType",e.Enum8,{endpoint=l,component=j,
from_device=function(f)return({[0]="continuous",[1]="flashes"})[f]end,
to_device=function(f)return({continuous=0,flashes=1})[f]end
}))end
end
local function bT(model,C)
return function(ap,a)
x(a,1,p,{bq,U})aT(a,1,p,aq,g)aT(a,1,H,G)x(a,1,k,{Z,as,E,D,A,P,v,u},g)aT(a,1,k,W,g)aT(a,1,k,Y,g)if C then
x(a,1,k,{ag,au,O},g)end
br(a,ap.environment_info.hub_zigbee_eui,1,{p,R})br(a,ap.environment_info.hub_zigbee_eui,1,{B})
end
end
local function be(model,bO,C)
local c,capability_prefix,d,J="sber_"..model,"sber"..model,{},{}

m(d,aN.switch{endpoint=1,component="main",configure_reporting=false,read_on_configure=false})aD(d,c,capability_prefix,1,"main")ak(d,c,capability_prefix,1,"main",false)aH(d,J,c,capability_prefix,1,"main",3)aj(d,c,capability_prefix,1,"main")bs(d,c,capability_prefix,1,"main")bc(d,1,"main")V(d,c,capability_prefix,1,"main",2,1,C)return{profile=bO,package_group="wave14-switch",zcl_clusters=d,capability_commands=J,button_actions={"pushed","held","double"},configure=bT(model,C)}
end
local function ar(a,i,C)
local l=i and 3 or 1
if i then
aT(a,3,H,G)x(a,3,h,{ae,at})x(a,3,h,{aF,bb,aU},g)x(a,3,k,{A,P,v,u},g)aT(a,3,k,Y,g)else
aT(a,1,H,G)for ad=1,2 do
x(a,ad,p,{bq,U})aT(a,ad,p,aq,g)x(a,ad,k,{W,Z,as,E,D,A,P,v,u},g)end
aT(a,1,k,Y,g)end
if C then
x(a,l,k,{ag,au,O},g)end
end
local function bD(a,q,i)
if q==nil then return end
if i then
br(a,q,3,{h})br(a,q,3,{k})br(a,q,3,{B})return
end
for ad=1,2 do
br(a,q,ad,{p,R})end
br(a,q,1,{k})br(a,q,1,{B})
end
local function T(a,q,i,C)
ar(a,i,C)bD(a,q,i)
end
local function aV(model,bO,C)
local c,capability_prefix,aB,ao,aa,s,aE,aX,ab,M,d,J="sber_"..model,"sber"..model,bO,bO .."-cover","__wave14_sber_"..model.."_cover_enabled","__wave14_sber_"..model.."_mode_pending","__wave14_sber_"..model.."_mode_timer","__wave14_sber_"..model.."_hub_eui","__wave14_sber_"..model.."_probe_action","__wave14_sber_"..model.."_profile_reconfigure",{},{}



local function ac(a,i)
local am=a.profile and a.profile.components
if type(am)~="table"or am.main==nil then return false end
for cc in pairs(am)do
if cc~="main"and cc~=(i and"cover"or"switch2")then return false end
end
local aw=a.supports_capability_by_id
if i then
return am.cover~=nil and am.switch2==nil and
aw(a,"refresh","main")and aw(a,"windowShade","cover")and
aw(a,"windowShadeLevel","cover")and
aw(a,K ..capability_prefix.."CoverMode","cover")end
return am.switch2~=nil and am.cover==nil and
aw(a,"switch","main")and aw(a,"switch","switch2")and
aw(a,K ..capability_prefix.."OneRelayMode","main")and
aw(a,K ..capability_prefix.."TwoRelayMode","switch2")
end
local function ay(a,i)
return a:get_field(s)~=true and
a:get_field(aa)==i and
ac(a,i)
end
local function av(a,i,cH,bz)
local cq=i and ao or aB
if cH or not ac(a,i)then
if bz then
a:set_field(M,cq)end
a:try_update_metadata{profile=cq}return true
end
return false
end
local function bd(a)
local bP=a:get_field(aE)if bP~=nil and a.thread~=nil and type(a.thread.cancel_timer)=="function"then
a.thread:cancel_timer(bP)end
a:set_field(aE,nil)
end
local bA=#d+1
for az=1,2 do
local word,j=az==1 and"One"or"Two",az==1 and"main"or"switch2"local aW,aI=c.."_"..string.lower(word),capability_prefix..word
m(d,aN.switch{endpoint=az,component=j,configure_reporting=false,read_on_configure=false})aj(d,aW,aI,az,j)bs(d,aW,aI,az,j)aD(d,aW,aI,az,j)aH(d,J,aW,aI,az,j,30)ak(d,aW,aI,az,j,false)bc(d,az,j)end
F(d,bA,#d,"switch",
function(a)return ay(a,false)end
)local bE=#d+1
m(d,aN.cluster_attribute(h,ae,{name="cover_position",endpoint=3,component="cover",data_type=e.Uint8,
from_device=function(f)return 100-f end,
emit=bV.shade_level(),sender=bt}))m(d,aN.cluster_attribute(h,ae,{name=c.."_cover_state_rx",endpoint=3,component="cover",read_only=true,data_type=e.Uint8,
from_device=function(f)return f==100 and"closed"or"open"end,
emit=bV.shade_state()}))m(d,aN.cluster_attribute(h,nil,{name="cover_state",endpoint=3,component="cover",write_only=true,sender=bL}))m(d,t(h,at,c.."_cover_mode",capability_prefix.."CoverMode",e.Bitmap8,{endpoint=3,component="cover",sender=z,
from_device=function(f)return f%2==1 and"reversed"or"normal"end,
to_device=function(f)return f=="reversed"and 1 or 0 end
}))m(d,t(h,aF,c.."_calibration_time",capability_prefix.."CalibrationTime",e.Uint16,{endpoint=3,component="cover",mfg_code=g,sender=z,
from_device=function(f)return f*0.1 end,
to_device=function(f)return f*10 end,
numeric_range={minimum=0,maximum=3600,step=0.1,unit="s"}}))m(d,t(h,aU,c.."_motor_timeout",capability_prefix.."MotorTimeout",e.Uint16,{endpoint=3,component="cover",mfg_code=g,sender=z,numeric_range={minimum=0,maximum=3600,step=1,unit="s"}}))m(d,t(h,bb,c.."_buttons_mode",capability_prefix.."ButtonsMode",e.Enum8,{endpoint=3,component="cover",mfg_code=g,sender=z,
from_device=function(f)return f==1 and"inverted"or"normal"end,
to_device=function(f)return f=="inverted"and 1 or 0 end
}))aH(d,J,c.."_cover",capability_prefix.."Cover",3,"cover",30)ak(d,c.."_cover",capability_prefix.."Cover",3,"cover",true)F(d,bE,#d,"cover",
function(a)return ay(a,true)end
)local bF=#d+1
V(d,c,capability_prefix,1,"main",3,2,C)F(d,bF,#d,"switch",
function(a)return ay(a,false)end
)local bK=#d+1
V(d,c,capability_prefix,3,"cover",3,2,C)F(d,bK,#d,"cover",
function(a)return ay(a,true)end
)
local function ci(a,f)
local cf,bk,i=a:get_field(aa),a:get_field(ab)or"configure",f==true or f==1
a:set_field(aa,i,{persist=true})a:set_field(ab,nil)bd(a)local aM=av(a,i,false,true)if aM then
a:set_field(s,true)return
end
a:set_field(s,false)if bk=="refresh"and cf==i then
ar(a,i,C)else
T(a,a:get_field(aX),i,C)end
end
m(d,aN.cluster_attribute(H,aO,{name=c.."_window_covering_enabled",endpoint=3,component="cover",read_only=true,data_type=e.Boolean,handler=ci}))
local function aY(a,q,bk)
if q~=nil then a:set_field(aX,q)end
a:set_field(s,true)a:set_field(ab,bk)bd(a)aT(a,3,H,aO)if a.thread~=nil and type(a.thread.call_with_delay)=="function"then
local bP
bP=a.thread:call_with_delay(3,function()
if a:get_field(s)==true and a:get_field(aE)==bP then
local X=a:get_field(aa)if type(X)~="boolean"then
X=false
a:set_field(aa,X,{persist=true})end
a:set_field(aE,nil)a:set_field(ab,nil)local aM=av(a,X,false,true)if aM then
a:set_field(s,true)return
end
a:set_field(s,false)if bk=="refresh"then
ar(a,X,C)else
T(a,q,X,C)end
end
end,"wave14 Sber mode fallback "..model)
a:set_field(aE,bP)end
end
local function bI(ap,a)
local expected_profile=a:get_field(M)if expected_profile~=nil and ac(a,expected_profile==ao)then
a:set_field(M,nil)local bC=a:get_field(aa)if type(bC)=="boolean"then
a:set_field(s,false)local q=ap.environment_info.hub_zigbee_eui
if q~=nil then a:set_field(aX,q)end
T(a,q or a:get_field(aX),bC,C)end
return
end
aY(a,ap.environment_info.hub_zigbee_eui,"configure")
end
local function cd(a,_,ap)
local q=ap~=nil and ap.environment_info~=nil and
ap.environment_info.hub_zigbee_eui or a:get_field(aX)aY(a,q,"refresh")
end
local function cg(a)
local bv=a:get_field(aa)if type(bv)=="boolean"then
if av(a,bv,false,true)then
a:set_field(s,true)end
end
end
return{profile=aB,auxiliary_profiles={ao},sber_switch_profile=aB,sber_cover_profile=ao,sber_mode_field=aa,sber_pending_field=s,valid_parent_profiles={[aB]=true,[ao]=true},
parent_profile_matches=function(a)
return ac(a,false)or ac(a,true)
end,
package_group="wave14-switch",zcl_clusters=d,capability_commands=J,button_actions={"pushed","held","double"},component_to_endpoint_map={main=1,switch2=2,cover=3},endpoint_to_component_map={[1]="main",[2]="switch2",[3]="cover"},runtime_start=cg,configure=bI,parent_refresh=cd}
end
local function bS()
local c,capability_prefix,d,J="sber_202","sber202",{},{}m(d,aN.switch{endpoint=1,component="main",configure_reporting=false,read_on_configure=false})aH(d,J,c,capability_prefix,1,"main",3)aj(d,c,capability_prefix,1,"main")V(d,c,capability_prefix,1,"main",1,1,false)ak(d,c,capability_prefix,1,"main",false)for _,item in ipairs{{"EmergencyOvervoltage","emergency_overvoltage",1},{"EmergencyUndervoltage","emergency_undervoltage",2},{"EmergencyOvercurrent","emergency_overcurrent",4},{"EmergencyOverheat","emergency_overheat",8}}do
m(d,y(bw,c.."_"..item[2],capability_prefix..item[1],e.Bitmap16,{endpoint=1,component="main",read_only=true,
from_device=function(f)return bit32.band(f,item[3])~=0 and"active"or"clear"end
}))end
m(d,aN.cluster_attribute(I,0,{name="device_temperature",endpoint=1,component="main",read_only=true,data_type=e.Int16,emit=bV.temperature"C"}))m(d,aN.cluster_attribute(k,aQ,{name="voltage",endpoint=1,component="main",read_only=true,mfg_code=g,data_type=e.Uint32,
from_device=function(f)return f*0.001 end,emit=bV.voltage()
}))m(d,aN.cluster_attribute(k,aP,{name="current",endpoint=1,component="main",read_only=true,mfg_code=g,data_type=e.Uint32,
from_device=function(f)return f*0.001 end,emit=bV.current()
}))m(d,aN.cluster_attribute(k,aG,{name="power",endpoint=1,component="main",read_only=true,mfg_code=g,data_type=e.Int32,
from_device=function(f)return f*0.001 end,emit=bV.power()
}))m(d,y(aC,c.."_emergency_recovery",capability_prefix.."EmergencyRecovery",e.Bitmap16,{endpoint=1,component="main",
from_device=function(f)return({[0]="disabled",[1]="voltage_is_good"})[f]end,
to_device=function(f)return({disabled=0,voltage_is_good=1})[f]end
}))local co={{ai,"UpperVoltageThreshold","upper_voltage_threshold",e.Uint32,230000,260000,1000,"mV"},{af,"LowerVoltageThreshold","lower_voltage_threshold",e.Uint32,100000,230000,1000,"mV"},{ah,"UpperCurrentThreshold","upper_current_threshold",e.Uint32,100,16000,100,"mA"},{Q,"TemperatureThreshold","temperature_threshold",e.Int16,-200,200,1,"°C"}}for _,field in ipairs(co)do
m(d,y(field[1],c.."_"..field[3],capability_prefix..field[2],field[4],{endpoint=1,component="main",numeric_range={minimum=field[5],maximum=field[6],step=field[7],unit=field[8]}}))end
local function bI(ap,a)
aT(a,1,H,G)aT(a,1,I,0)x(a,1,p,{bq,U})x(a,1,k,{Y,aC,aQ,aP,aG},g)x(a,1,k,{Z,as,E,D,A,P,v,u},g)x(a,1,k,{ai,af,ah,Q},g)br(a,ap.environment_info.hub_zigbee_eui,1,{p,I,k})br(a,ap.environment_info.hub_zigbee_eui,1,{B})
end
return{profile="switches-wave14-sber-sbdv-00202",package_group="wave14-switch",zcl_clusters=d,capability_commands=J,configure=bI}
end
local cu,cv,cw,cx,cy=be("196","switches-wave14-sber-sbdv-00196",false),be("197","switches-wave14-sber-sbdv-00197",true),aV("199","switches-wave14-sber-sbdv-00199",false),aV("200","switches-wave14-sber-sbdv-00200",true),bS()o(cu,{N.create_fingerprint("SDevices","SBDV-00196")})o(cv,{N.create_fingerprint("SDevices","SBDV-00197")})o(cw,{N.create_fingerprint("SDevices","SBDV-00199")})o(cx,{N.create_fingerprint("SDevices","SBDV-00200")})o(cy,{N.create_fingerprint("SDevices","SBDV-00202")})return{id="wave14.sber.zcl_switches",registrations=bM}
