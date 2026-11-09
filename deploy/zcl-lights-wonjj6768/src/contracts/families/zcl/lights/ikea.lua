local ak,a=require"protocol.zcl",require"contracts.helpers.family"local Z,q=a.definition_registry()local ba,bt,aM={profile="lights-dimmer",zcl_clusters={ak.switch(),ak.level()}},{profile="lights-color-temperature",zcl_clusters={ak.switch(),ak.level(),ak.color_temperature()}},{profile="lights-color-temperature-color",zcl_clusters={ak.switch(),ak.level(),ak.color_temperature(),ak.color_hue(),ak.color_saturation(),ak.color()}}q(ba,{a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 opal 1000lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 W opal 1000lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 WW globe 800lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 WW globe 806lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 WW globe 810lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 WW globe 806lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE26WWglobeclear250lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 WW G95 CL 470lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 WW G95 CL 450lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 WW G95 CL 440lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 WW G95 CL 470lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 WW clear 250lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 WW clear 250lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE27WWclear250lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE26WWclear250lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 opal 1000lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 W opal 1000lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 WW 806lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 WW 806lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E14 W op/ch 400lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E12 W op/ch 400lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E17 W op/ch 400lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE14WWclear250lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE12WWclear250lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE17WWclear250lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE12WWcandleclear250lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb GU10 WW 345lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb GU10 WW 380lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb GU10 W 400lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb GU10 WW 400lm")})q(bt,{a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 WS opal 980lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 WS opal 980lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 WS�opal 980lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 WS clear 950lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 WS clear 950lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 WS�clear 950lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbG125E27WSopal470lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbG125E26WSopal450lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbG125E26WSopal470lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbG125E26WSopal440lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE27WSglobeopal1055lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE26WSglobeopal1100lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE26WSglobeopal1160lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE26WSglobeopal1055lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE26WSglobeclear800lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE27WSglobeclear806lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE26WSglobeclear806lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE26WSglobeclear810lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 opal 470lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 W opal 470lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbT120E27WSopal470lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbT120E26WSopal450lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbT120E26WSopal470lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 WS opal 440lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbT120E26WSopal440lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 WS opal 1000lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 WS opal 1000lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 WS clear 806lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 WS clear 806lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 WS globe 1055lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 WS globe 1055lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 WS globe 1100lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 WS globe 1160lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbPAR38WS900lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbB22WSglobeopal1055lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E14 WS candle 470lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E12 WS candle 450lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E14 WS opal 400lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E12 WS opal 400lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E14 WS 470lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E12 WS 450lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E17 WS 440lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E17 WS candle 440lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E14 WS globe 470lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E12 WS globe 450lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E14 WS opal 600lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE14WSglobeopal470lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE12WSglobeopal470lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E17 WS globe 440lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE17WSglobeopal470lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E12 WS opal 600lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E17 WS opal 600lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE14WScandleopal470lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE12WScandleopal450lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbE17WScandleopal440lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb GU10 WS 400lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI_bulb_GU10_WS_345lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbGU10WS345lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb GU10 WS 345lm"),a.create_fingerprint("IKEA of Sweden","TRADFRIbulbGU10WS380lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb GU10 WS 380lm"),a.create_fingerprint("IKEA of Sweden","LEPTITER Recessed spot light"),a.create_fingerprint("IKEA of Sweden","JETSTROM 40100"),a.create_fingerprint("IKEA of Sweden","JETSTROM 40100 NA"),a.create_fingerprint("IKEA of Sweden","JETSTROM 6060"),a.create_fingerprint("IKEA of Sweden","JETSTROM 6060 JP"),a.create_fingerprint("IKEA of Sweden","JETSTROM 6060 NA"),a.create_fingerprint("IKEA of Sweden","JORMLIEN door WS 40x80"),a.create_fingerprint("IKEA of Sweden","FLOALT panel WS 30x30"),a.create_fingerprint("IKEA of Sweden","FLOALT panel WS 60x60"),a.create_fingerprint("IKEA of Sweden","FLOALT panel WS 30x90"),a.create_fingerprint("IKEA of Sweden","SURTE door WS 38x64"),a.create_fingerprint("IKEA of Sweden","GUNNARP panel round"),a.create_fingerprint("IKEA of Sweden","GUNNARP panel 40*40")})q(aM,{a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 CWS globe 800lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 CWS globe 806lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 CWS globe 810lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 CWS globe 806lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 CWS 800lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 CWS 806lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 CWS 806lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 CWS 810lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E14 CWS 470lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E12 CWS 450lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E17 CWS 440lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E14 CWS globe 806lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E12 CWS globe 800lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E17 CWS globe 810lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb GU10 CWS 380lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb GU10 CWS 345lm"),a.create_fingerprint("IKEA of Sweden","JETSTROM 3030 wall"),a.create_fingerprint("IKEA of Sweden","JETSTROM 3030 NA wall"),a.create_fingerprint("IKEA of Sweden","JETSTROM 3030 ceiling")})do
local al,aw,n,k,J,aV,m,d,t,ac=require"capabilities.events.all",require"st.capabilities",require"st.zigbee.zcl.clusters",require"st.zigbee.data_types",require"st.zigbee.cluster_base",require"st.zigbee.zcl.global_commands.read_attribute",require"contracts.helpers.ikea1624_color","ikea1624:",{persist=false},{persist=true}local bV={switch=al.switch(),level=al.level(),hue=al.color_hue(),saturation=al.color_saturation(),kelvin=al.color_temperature(),mired=al.ikea1624ColorMired(),power_on=al.ikea1624PowerOn(),level_off=al.ikea1624LevelOff(),start_level=al.ikea1624StartLevel(),color_off=al.ikea1624ColorOff(),
xy=function(_,value)
return aw["concertmirror08464.ikea1624XyColor"].colorXy(value)
end
}local bC,av,bk={off=0,on=1,toggle=2,previous=255},{[0]="off",[1]="on",[2]="toggle",[255]="previous"},{blink=0,breathe=1,okay=2,channel_change=11,finish_effect=254,stop_effect=255}
local function f(value,bJ,aF,bI)
return m.finite(value)and value>=bJ and value<=aF and(not bI or value%1==0)
end
local function I(b,aH)
return b:send(aH:to_endpoint(1))~=false
end
local function W(b,p,S)
local aH,bQ=J.read_attribute(b,k.ClusterId(p),k.AttributeId(S[1])),{}for _,id in ipairs(S)do bQ[#bQ+1]=k.AttributeId(id)end
aH.body.zcl_body=aV.ReadAttribute(bQ)return I(b,aH)
end
local function aP(b)
return W(b,768,{8,3,4})
end
local function bp(b,bU,bA,bX)
b.thread:call_with_delay(bU,bA,bX)
end
local function F(b,name,value)
if value==nil then return end
local s=bV[name](b,value)if s~=nil then b:emit_event(s)end
end
local function G(b)
local value=b.preferences and b.preferences.ikea1624TransitionTenths
if value==nil then return 0,false end
if not f(value,0,65535,true)then return nil end
return value,true
end
local function aS(b,aZ,j,by,am)
local A=not(b.preferences and b.preferences.ikea1624Unfreeze==false)if A then
local cb,aR=require"cosock.socket".gettime()*1000,b:get_field(d.."frozen_until")
if aR~=nil and cb<=aR and not by then
I(b,n.Level.server.commands.Stop(b,0,0))end
end
local function ay(ok)
if ok and A then
local aO
if aZ and j>0 then
aO=require"cosock.socket".gettime()*1000+j*100
end
b:set_field(d.."frozen_until",aO,t)end
return ok
end
local ok,bM=am(ay)if bM then return true end
return ay(ok)
end
local function az(value)
if type(value)~="string"then return false end
local aE,aN,patch,bE=value:match"^[v=%s]*(%d+)%.(%d+)%.(%d+)(.-)%s*$"if aE==nil then return false end
aE,aN,patch=tonumber(aE),tonumber(aN),tonumber(patch)if aE>9007199254740991 or aN>9007199254740991 or patch>9007199254740991 then return false end
local D,bn=bE:match"^(.-)%+(.+)$"if bE:find("+",1,true)and bn==nil then return false end
D=D or bE
local function aK(bf)
return bf~=""and not bf:find"[^A-Za-z0-9%.%-]"and
bf:sub(1,1)~="."and bf:sub(-1)~="."and not bf:find("..",1,true)
end
if bn~=nil and not aK(bn)then return false end
if D~=""then
if #D>1 and D:sub(1,1)=="-"then D=D:sub(2)end
if not aK(D)then return false end
end
if aE~=1 then return aE>1 end
if aN~=0 then return aN>0 end
return patch>12
end
local function aB(b,am)
local l=b:get_field(d.."on_level_pending")if l~=nil then
l.queue[#l.queue+1]=am
return true
end
return am()
end
local function o(b,value,bO)
local l=b:get_field(d.."on_level_pending")if l==nil then return end
if l.timer~=nil then
b.thread:cancel_timer(l.timer)l.timer=nil
end
b:set_field(d.."on_level_pending",nil,t)if bO or value==0 then
b:set_field(d.."on_level_supported",false,ac)value=255
end
local ok=l.send(value)l.finish(ok)if ok and l.after~=nil then l.after()end
for bW,am in ipairs(l.queue)do
am()local af=b:get_field(d.."on_level_pending")if af~=nil then
for bY=bW+1,#l.queue do af.queue[#af.queue+1]=l.queue[bY]end
break
end
end
end
local function B(b,ao,j,specified,bm)
local O,u=ao.state,ao.brightness
if O==nil then O=u==0 and"off"or"on"end
local as=O
if O=="toggle"then as=b:get_field(d.."switch")==true and"off"or"on"end
if as=="off"then
u=(specified or u==0)and 0 or nil
if u~=nil and b:get_field(d.."switch")==false and
az(b:get_field(d.."sw_build_id"))then u=nil end
local bj=b:get_field(d.."raw_level")if bj~=nil and b:get_field(d.."switch")==true then
b:set_field(d.."stored_brightness",bj,t)b:set_field(d.."turned_off_with_transition",u~=nil,t)end
end
local function V(z)
if z==255 and as=="on"then
z=b:get_field(d.."stored_brightness")if z==nil then z=b:get_field(d.."raw_level")end
if z==nil then z=254 end
end
if z==nil then
if O=="on"and ao.on_time~=nil then
return I(b,n.OnOff.server.commands.OnWithTimedOff(b,0,ao.on_time,ao.off_wait_time))end
local h=O=="toggle"and n.OnOff.server.commands.Toggle or
(O=="off"and n.OnOff.server.commands.Off or n.OnOff.server.commands.On)return I(b,h(b))end
if not f(z,0,255,true)then return false end
if z==0 and(as=="on"or O==false)then z=1 end
if as~="off"then
b:set_field(d.."stored_brightness",z,t)b:set_field(d.."turned_off_with_transition",nil,t)end
local h=O==false and n.Level.server.commands.MoveToLevel or n.Level.server.commands.MoveToLevelWithOnOff
return I(b,h(b,z,j,0,0))
end
return aS(b,false,j,false,function(ay)
if as=="on"and u==nil and
(specified or b:get_field(d.."turned_off_with_transition")==true)then
local Q=b:get_field(d.."on_level")or 0
if Q==0 and b:get_field(d.."on_level_supported")~=false then
local l={send=V,finish=ay,after=bm,queue={}}b:set_field(d.."on_level_pending",l,t)
l.timer=b.thread:call_with_delay(10,function()
if b:get_field(d.."on_level_pending")==l then
l.timer=nil
o(b,nil,true)end
end,"LED1624 OnLevel read timeout")
if l.timer==nil then
o(b,nil,true)return nil,true
end
local ok,bZ=pcall(W,b,8,{17})if not ok or not bZ then o(b,nil,true)end
return nil,true
end
if Q==0 then
b:set_field(d.."on_level_supported",false,ac)Q=255
end
u=Q
end
local ok=V(u)if ok and bm~=nil then
ay(ok)bm()return nil,true
end
return ok
end)
end
local function bs(b,_,value)
if type(value)~="boolean"then return false end
local j,specified=G(b)if j==nil then return false end
return B(b,{state=value and"on"or"off"},j,specified)
end
local function aj(b,w,value,C)
local j,specified=G(b)local bd=C and C.args and C.args.rate
if bd~=nil then
if not f(bd,0,65535,true)then return false end
j,specified=bd,true
end
if j==nil then return false end
local aU
if w.name=="brightness"then
if not f(value,0,100)then return false end
aU=m.round(value*254/100)elseif w.name=="ikea1624_brightness_percent"then
if not f(value,0,100)then return false end
aU=math.min(254,m.round(value*255/100))else
if not f(value,0,255,true)then return false end
aU=math.min(value,254)end
local O
if w.name=="ikea1624_brightness_keep_power"then O=false end
return B(b,{brightness=aU,state=O},j,specified)
end
local function M(b,w,value)
local j=G(b)if j==nil then return false end
local name,x,y,E=w.name
local L=b:get_field(d.."hs_projection")or{}local ae,saturation
local z,ag
if name=="color"then
if type(value)~="table"then return false end
if value.level~=nil then
if not f(value.level,0,100,true)then return false end
z=m.round(value.level*254/100)end
if value.switch~=nil then
if type(value.switch)~="string"then return false end
ag=value.switch:lower()if ag~="on"and ag~="off"then return false end
end
if value.hue==nil and value.saturation==nil and value.hex==nil then
if z==nil and ag==nil then return false end
local _,specified=G(b)return B(b,{state=ag,brightness=z},j,specified)end
end
if name=="color_temperature"or name=="ikea1624_color_mired"then
if name=="color_temperature"then
if not f(value,2000,6536,true)then return false end
E=math.max(153,math.min(500,1000000/value))else
if not f(value,153,500)then return false end
E=value
end
x,y=m.mired_xy(E)elseif name=="ikea1624_color_xy"then
if type(value)~="table"or not f(value.x,0,1)or not f(value.y,0,1)then return false end
for ab in pairs(value)do
if ab~="x"and ab~="y"then return false end
end
x,y=value.x,value.y
elseif name=="ikea1624_color_rgb"then
if type(value)~="table"or not f(value.red,0,1)or not f(value.green,0,1)or not f(value.blue,0,1)then return false end
x,y=m.rgb_xy(value.red,value.green,value.blue,true)elseif name=="color"and value.hex~=nil then
if type(value.hex)~="string"then return false end
local bP=value.hex:gsub("^#","")if #bP~=6 or bP:find"[^0-9a-fA-F]"then return false end
local bS=tonumber(bP,16)x,y=m.rgb_xy(math.floor(bS/65536)/255,math.floor(bS/256)%256/255,bS%256/255,true)else
if name=="color_hue"then
if not f(value,0,100)then return false end
ae,saturation=value,L.saturation
elseif name=="color_saturation"then
if not f(value,0,100)then return false end
ae,saturation=L.hue,value
elseif type(value)=="table"then
ae,saturation=value.hue,value.saturation
if ae==nil and saturation==nil then return false end
else return false end
ae,saturation=ae==nil and 0 or ae,saturation==nil and 100 or saturation
if not f(ae,0,100)or not f(saturation,0,100)then return false end
x,y=m.hsv_xy(ae*3.6,saturation)end
if x==nil then return false end
local function aQ()
local ok=aS(b,true,j,false,function()
return I(b,n.ColorControl.server.commands.MoveToColor(b,m.round(x*65535),m.round(y*65535),j,0,0))
end)
if ok then
if E~=nil then b:set_field(d.."mired_target",true,t)end
bp(b,math.max(2,j/10),function()aP(b)end,"LED1624 color readback")
end
return ok
end
if z~=nil or ag~=nil then
return B(b,{state=ag,brightness=z},0,false,aQ)end
return aQ()
end
local function bN(b,_,value)
local U
if type(value)=="table"then
U,value=value.transition,value.effect
end
if type(value)~="string"then return false end
if bk[value]~=nil then
return I(b,n.Identify.server.commands.TriggerEffect(b,bk[value],0))end
if value=="colorloop"then
local ad=U
if ad==nil then
ad=(b.preferences and b.preferences.ikea1624LoopTenths or 150)/10
end
if not m.finite(ad)or ad<0 then return false end
local bd=ad==0 and 255 or math.min(255,math.max(1,m.round(255/ad)))return I(b,n.ColorControl.server.commands.MoveHue(b,1,bd,0,0))elseif value=="stop_colorloop"then
if not I(b,n.ColorControl.server.commands.MoveHue(b,0,1,0,0))then return false end
bp(b,0.1,function()W(b,768,{0,8})end,"E17 loop stop readback")
return true
end
return false
end
local function bB(b,_,value)
if not f(value,1,30,true)then return false end
return I(b,n.Identify.server.commands.Identify(b,value))
end
local function bT(b)
local j,specified=G(b)if j==nil then return false end
return B(b,{state="toggle"},j,specified)
end
local bD={ikea1624_power_on={6,16387,k.Enum8,bC},ikea1624_level_off={8,15,k.Bitmap8,{disabled=0,enabled=1}},ikea1624_start_level={8,16384,k.Uint8},ikea1624_color_off={768,15,k.Bitmap8,{disabled=0,enabled=1}}}
local function Y(b,w,value)
local X=bD[w.name]local aD
if X[4]~=nil then aD=X[4][value]elseif f(value,0,255,true)then aD=value end
if aD==nil then return false end
if not I(b,J.write_attribute(b,k.ClusterId(X[1]),k.AttributeId(X[2]),X[3](aD)))then return false end
return W(b,X[1],{X[2]})
end
local function T(b,w,value)
local bl,bH,j=w.name:find("step",1,true)~=nil,w.name:find("onoff",1,true)~=nil,G(b)

if j==nil then return false end
if not bl and(value=="stop"or value==0)then
I(b,n.Level.server.commands.Stop(b,0,0))
bp(b,0.5,function()
aB(b,function()W(b,6,{0});return W(b,8,{0})end)
end,"E17 level stop readback")
return true
end
if not f(value,-255,255,true)then return false end
local bR=value>0 and 0 or 1
if bl then
return aS(b,false,j,true,function()
local h=bH and n.Level.server.commands.StepWithOnOff or n.Level.server.commands.Step
return I(b,h(b,bR,math.abs(value),j,0,0))
end)
end
local h=bH and n.Level.server.commands.MoveWithOnOff or n.Level.server.commands.Move
return I(b,h(b,bR,math.abs(value),0,0))
end
local function bF(b,_,value)
if type(value)~="table"then return false end
local ap,off_wait=value.on_time==nil and 0 or value.on_time,value.off_wait_time==nil and 0 or value.off_wait_time

if not m.finite(ap)or not m.finite(off_wait)then return false end
ap,off_wait=m.round(ap*10),m.round(off_wait*10)if not f(ap,0,65534,true)or not f(off_wait,0,65534,true)then return false end
local j,specified=G(b)if j==nil then return false end
return B(b,{state="on",on_time=ap,off_wait_time=off_wait},j,specified)
end
local function aa(b,name,value)
b:set_field(d..name,value,ac)
end
local ai={[6]={[0]=k.Boolean,[16387]=k.Enum8},[8]={[0]=k.Uint8,[15]=k.Bitmap8,[17]=k.Uint8,[16384]=k.Uint8},[768]={[0]=k.Uint8,[1]=k.Uint8,[3]=k.Uint16,[4]=k.Uint16,[7]=k.Uint16,[8]=k.Enum8,[15]=k.Bitmap8}}
local function aI(b,rx)
local K=rx.body.zcl_header
if K==nil or K.frame_ctrl:is_cluster_specific_set()or K.frame_ctrl:is_mfg_specific_set()or not K.frame_ctrl:is_direction_set()or K.cmd.value~=9 or rx.address_header.src_endpoint.value~=1 then return end
local p=rx.address_header.cluster.value
local S=ai[p]if S==nil then return end
local bx,bh=b:get_field(d.."reporting")or{},false
for _,e in ipairs(rx.body.zcl_body.read_reporting_records)do
if e.status.value==0 and e.direction.value==0 then
local id=e.attr_id.value
local R=S[id]if R and R.ID==e.data_type.value then
bx[string.format("%04x:%04x",p,id)]={p,id,e.minimum_reporting_interval.value,e.maximum_reporting_interval.value,e.reportable_change and e.reportable_change.value}bh=true
end
end
end
if bh then b:set_field(d.."reporting",bx,ac)end
end
local function aL(b)
local bq,aG=require"st.zigbee.device_management",{}for _,N in ipairs{{6,0,0,300},{8,0,1,3600,1},{768,0,1,300,1},{768,1,1,300,1},{768,7,1,300,1}}do
local aX=b:get_field(string.format("zcl_reporting:zr%04x%04xauto",N[1],N[2]))if aX then
local ax=aX.reportable_change
if ax==nil then ax=N[5]end
local aF=aX.maximum_interval or N[4]if aF==65535 and ax~=nil then ax=0 end
aG[string.format("%04x:%04x",N[1],N[2])]={N[1],N[2],aX.minimum_interval or N[3],aF,ax}end
end
for ab,e in pairs(b:get_field(d.."reporting")or{})do aG[ab]=e end
local bo={}for ab in pairs(aG)do bo[#bo+1]=ab end
table.sort(bo)for _,ab in ipairs(bo)do
local e=aG[ab]local R=ai[e[1]][e[2]]I(b,bq.attr_config(b,{cluster=e[1],attribute=e[2],data_type=R,minimum_interval=e[3],maximum_interval=e[4],reportable_change=not R.is_discrete and R(e[5])or nil}))end
end
local function aW(b,rx)
local K=rx.body and rx.body.zcl_header
if K==nil or rx.address_header.src_endpoint.value~=1 or
K.frame_ctrl:is_cluster_specific_set()or K.frame_ctrl:is_mfg_specific_set()or
not K.frame_ctrl:is_direction_set()then return end
local bi,p,aY=K.cmd.value,rx.address_header.cluster.value,rx.body.zcl_body
if bi~=1 and bi~=11 then return end
if bi==11 and(aY.cmd.value~=0 or aY.status.value==0)then return end
local function au(i)
local be
if bi==1 then
for _,e in ipairs(aY.attr_records)do
if e.attr_id.value==i then be=e end
end
end
return be
end
if p==0 then
local e=au(16384)if e and e.status.value==0 and type(e.data.value)=="string"then
aa(b,"sw_build_id",e.data.value)end
elseif p==768 and b:get_field(d.."await_bounds")then
local e=au(16394)if e==nil and bi==1 and #aY.attr_records>0 then return end
b:set_field(d.."await_bounds",false,t)if e and e.status.value==0 and f(e.data.value,0,65535,true)then
W(b,768,{16395,16396})end
elseif p==8 and b:get_field(d.."on_level_pending")~=nil then
if bi==11 then return o(b,nil,true)end
local e=au(17)if e==nil then
if #aY.attr_records>0 then return end
return o(b,nil,false)end
if e.status.value~=0 then return o(b,nil,true)end
local value=e.data.value
if f(value,0,255,true)then
aa(b,"on_level",value)return o(b,value,false)end
return o(b,false,false)end
end
local function bK(b,_,aC)
local rx=aC.zb_rx
if b:get_field(d.."last_rx")==rx then return end
b:set_field(d.."last_rx",rx,t)local p,g=aC.cluster_id,{}
for _,e in ipairs(rx.body.zcl_body.attr_records)do
if e.status==nil or e.status.value==0 then
local value=e.data and e.data.value
if type(value)=="number"or type(value)=="boolean"or type(value)=="string"then
g[e.attr_id.value]=value
end
end
end
if p==0 then
if type(g[16384])=="string"then aa(b,"sw_build_id",g[16384])end
elseif p==6 then
local value=g[0]if value==true or value==false or value==0 or value==1 then
value=value==true or value==1
aa(b,"switch",value)F(b,"switch",value)end
if av[g[16387]]then F(b,"power_on",av[g[16387]])end
elseif p==8 then
local aU=g[0]if f(aU,0,255,true)then
aa(b,"raw_level",aU)F(b,"level",math.min(100,m.round(aU*100/254)))end
if f(g[15],0,255,true)then
local A=g[15]%2==1
aa(b,"level_off",A)F(b,"level_off",A and"enabled"or"disabled")end
if f(g[16384],0,255,true)then F(b,"start_level",g[16384])end
if f(g[17],0,255,true)then aa(b,"on_level",g[17])end
elseif p==768 then
if f(g[15],0,255,true)then
local A=g[15]%2==1
aa(b,"color_off",A)F(b,"color_off",A and"enabled"or"disabled")end
local N,ah=b:get_field(d.."color")or{color={}},{color={}}for id,ab in pairs{[3]="x",[4]="y"}do
if f(g[id],0,65535,true)then ah.color[ab]=m.round(g[id]/65535,4)end
end
if f(g[0],0,255,true)then ah.color.hue=m.round(g[0]*360/254)end
if f(g[1],0,255,true)then ah.color.saturation=m.round(g[1]*100/254)end
if f(g[8],0,255,true)then ah.mode=g[8]end
if f(g[7],0,65535,true)then ah.mired=g[7]end
if next(ah.color)==nil then ah.color=nil end
if f(g[16395],0,65535,true)then N.physical_min=g[16395]end
if f(g[16396],0,65535,true)then N.physical_max=g[16396]end
local A=not(b.preferences and b.preferences.ikea1624ColorSync==false)local ar=m.sync(ah,N,A)local an={color={},physical_min=N.physical_min,physical_max=N.physical_max,mode=ar.mode or ah.mode or N.mode,mired=N.mired}for ab,value in pairs(N.color or{})do an.color[ab]=value end
for ab,value in pairs(ah.color or{})do an.color[ab]=value end
for ab,value in pairs(ar.color or{})do an.color[ab]=value end
if ah.mired~=nil then an.mired=ah.mired end
if ar.mired~=nil then an.mired=ar.mired end
aa(b,"color",an)local s=ar.color or ah.color or{}if s.x~=nil and s.y~=nil then
F(b,"xy",{value={x=s.x,y=s.y}})end
local ae,saturation=s.hue,s.saturation
if A and ae==nil and s.x~=nil and s.y~=nil then ae,saturation=m.xy_hs(s.x,s.y)end
if ae~=nil or saturation~=nil then
local L=b:get_field(d.."hs_projection")or{}if m.finite(ae)then L.hue=ae/3.6;F(b,"hue",L.hue)end
if m.finite(saturation)then L.saturation=saturation;F(b,"saturation",saturation)end
aa(b,"hs_projection",L)end
local E,bc=ar.mired or ah.mired,b:get_field(d.."mired_target")or b:get_field(d.."mired_projection")~=nil

if E==nil and A and bc and s.x~=nil and s.y~=nil then
E=m.round(m.xy_mired(s.x,s.y))if N.physical_min~=nil then E=math.max(N.physical_min,E)end
if N.physical_max~=nil then E=math.min(N.physical_max,E)end
end
if m.finite(E)then
aa(b,"mired_projection",E)F(b,"mired",E)if E>0 then
local bw=m.round(1000000/E)if f(bw,1,30000,true)then F(b,"kelvin",bw)end
end
end
if f(g[16394],0,65535,true)then
aa(b,"capabilities",g[16394])end
end
end
local function bv(_,b)
return aB(b,function()
b:set_field(d.."await_bounds",true,t)W(b,768,{16394})return W(b,0,{16384})
end)
end
local function bL(b)
return aB(b,function()
W(b,6,{0,16387})W(b,8,{0,15,16384})aP(b)W(b,768,{15})return W(b,0,{16384})
end)
end
local function bz(b)
aL(b)if b:get_field(d.."color_off")==true then
I(b,J.write_attribute(b,k.ClusterId(768),k.AttributeId(15),k.Bitmap8(1)))end
if b:get_field(d.."level_off")==true then
I(b,J.write_attribute(b,k.ClusterId(8),k.AttributeId(15),k.Bitmap8(1)))end
local Q=b:get_field(d.."on_level")if Q~=nil then
I(b,J.write_attribute(b,k.ClusterId(8),k.AttributeId(17),k.Uint8(math.max(1,math.min(255,Q)))))end
return true
end
local aT={}
local function bb(b,w,value,aC)
return aB(b,function()return aT[w.name](b,w,value,aC)end)
end
local function i(p,id,name,aq)
if aq~=nil then aT[name]=aq end
return ak.cluster_attribute(p,id,{name=name,endpoint=1,handler=bK,sender=aq~=nil and bb or nil,read_only=aq==nil,read_on_configure=false,suppress_optimistic_state=true})
end
local function h(p,name,aq)
aT[name]=aq
return ak.cluster_attribute(p,nil,{name=name,endpoint=1,sender=bb,write_only=true,suppress_optimistic_state=true})
end
local P={profile="lights-ikea-led1624g9",auto_on_before_light_command=false,initial_custom_state_query=false,configure=bv,announce_handler=bz,parent_refresh=bL,
zigbee_message_handler=function(b,rx)
aI(b,rx)aW(b,rx)
end,
color_temperature_range={minimum=2000,maximum=6536},
runtime_start=function(b)
b:emit_event(aw.colorTemperature.colorTemperatureRange{value={minimum=2000,maximum=6536},unit="K"})
end,
protocol_writers={
brightness=function(b,value,C)
return aB(b,function()return aj(b,{name="brightness"},value,C)end)
end
},capability_commands={{capability_id="concertmirror08464.ikea1624XyColor",command_name="setColorXy",argument_name="colorXy",mapping_name="ikea1624_color_xy"},{capability_id="concertmirror08464.ikea1624Identify",command_name="setIdentifyTime",argument_name="identifyTime",mapping_name="ikea1624_identify"},{capability_id="concertmirror08464.ikea1624Toggle",command_name="toggle",value=true,mapping_name="ikea1624_toggle"}},zcl_clusters={i(0,16384,"ikea1624_firmware"),i(6,0,"switch",bs),i(6,16387,"ikea1624_power_on",Y),i(8,0,"ikea1624_rx_level"),i(8,15,"ikea1624_level_off",Y),i(8,16384,"ikea1624_start_level",Y),i(8,17,"ikea1624_on_level"),i(768,15,"ikea1624_color_off",Y),i(768,0,"ikea1624_rx_hue"),i(768,1,"ikea1624_rx_saturation"),i(768,3,"ikea1624_rx_x"),i(768,4,"ikea1624_rx_y"),i(768,7,"ikea1624_rx_mired"),i(768,8,"ikea1624_color_mode"),i(768,16394,"ikea1624_color_capabilities"),i(768,16395,"ikea1624_physical_min"),i(768,16396,"ikea1624_physical_max"),h(768,"color",M),h(768,"color_hue",M),h(768,"color_saturation",M),h(768,"color_temperature",M),h(768,"ikea1624_color_xy",M),h(768,"ikea1624_color_rgb",M),h(768,"ikea1624_color_mired",M),h(8,"ikea1624_brightness_raw",aj),h(8,"ikea1624_brightness_percent",aj),h(8,"ikea1624_brightness_keep_power",aj),h(8,"ikea1624_brightness_move",T),h(8,"ikea1624_brightness_move_onoff",T),h(8,"ikea1624_brightness_step",T),h(8,"ikea1624_brightness_step_onoff",T),h(6,"ikea1624_timed_on",bF),h(6,"ikea1624_toggle",bT),h(3,"ikea1624_effect",bN),h(3,"ikea1624_identify",bB)}}for _,bu in ipairs{{"blink","blink"},{"breathe","breathe"},{"okay","okay"},{"channelChange","channel_change"},{"finishEffect","finish_effect"},{"stopEffect","stop_effect"},{"colorLoop","colorloop"},{"stopColorLoop","stop_colorloop"}}do
P.capability_commands[#P.capability_commands+1]={capability_id="concertmirror08464.ikea1624Effect",command_name=bu[1],mapping_name="ikea1624_effect",value=bu[2]}end
q(P,{a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 CWS opal 600lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E26 CWS opal 600lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E14 CWS opal 600lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E12 CWS opal 600lm"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E27 C/WS opal 600"),a.create_fingerprint("IKEA of Sweden","TRADFRI bulb E17 CWS opal 600lm")})end
ak.attach_reporting_capabilities(Z,{{1,"rpt-tmf"},{2,"rpt-txx"},{3,"rpt-tkj"}})return{id="zcl.lights.ikea",registrations=Z}
