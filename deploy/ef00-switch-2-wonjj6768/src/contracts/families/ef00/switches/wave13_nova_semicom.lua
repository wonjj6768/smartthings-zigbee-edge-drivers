local n,w,q=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local h=n.converter
local F,k=q.definition_registry()local D="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function v(name)
return assert(w[name],"missing Wave13 custom emitter: "..name)()
end
local function t(V)
local o=string.find(D,V,1,true)return o~=nil and o-1 or nil
end
local function Q(a,b,c)
return table.concat{string.sub(D,math.floor(a/4)+1,math.floor(a/4)+1),string.sub(D,(a%4)*16+math.floor(b/16)+1,(a%4)*16+math.floor(b/16)+1),string.sub(D,(b%16)*4+math.floor(c/64)+1,(b%16)*4+math.floor(c/64)+1),string.sub(D,c%64+1,c%64+1)}
end
local function E(H)
if type(H)~="string"or #H<4 then return nil end
local a,b,c,d=t(string.sub(H,1,1)),t(string.sub(H,2,2)),t(string.sub(H,3,3)),t(string.sub(H,4,4))if a==nil or b==nil or c==nil or d==nil then return nil end
return math.floor(a*4+b/16),math.floor((b%16)*16+c/4),math.floor((c%4)*64+d)
end
local function P(g)
local l=tonumber(g)or 0
if l<0 then l=0 end
if l>3600 then l=3600 end
return math.floor(l)
end
local function A(S,g)
local O=P(g)local j=O>0 and 1 or 0
if S~=1 then j=j+2 ^(S-1)end
local G=O>0 and O or 1
return Q(j,math.floor(G/256),G%256)
end
local function x()
return h.from_to(
function(g)
local j,Y,ag=E(g)if j==nil then return 0 end
return j==1 and(Y*256+ag)or 0
end,
function(g)return A(1,g)end
)
end
local function N(j)
if j==0 or j==1 then return 1 end
local L,g=0,j

while g>=2 do
g=math.floor(g/2)L=L+1
end
return L+1
end
local function y(C)
return h.from_to(
function(g)
if type(g)~="string"then return nil end
local X
for W=1,#g,4 do
local j,Y,ag=E(string.sub(g,W,W+3))if j~=nil and N(j)==C then
X=j%2==1 and(Y*256+ag)or 0
end
end
return X
end,
function(g)return A(C,g)end
)
end
local function m(e,ad)
e.datapoints[#e.datapoints+1]=ad
end
local function M(ae,f,i,K)
local e,words,lower_words={profile=ae,package_group="switch-panel",magic_packet=true,query_on_configure=false,time_start="1970",datapoints={}},{"One","Two","Three"},{"one","two","three"}for o=1,K do
m(e,n.dp_on_off(o,{name="switch",component=o==1 and"main"or("switch"..tostring(o)),emit=w.switch()}))end
for o=1,K do
m(e,n.dp_numeric(o+6,{name=i.."_countdown_"..lower_words[o],emit=v(f.."Countdown"..words[o])}))end
m(e,n.dp_enum(14,{name=i.."_power_on_behavior",converter=h.lookup_from_to{off=0,on=1,previous=2},emit=v(f.."PowerOnBehavior")}))m(e,n.dp_enum(15,{name=i.."_indicator_mode",converter=h.lookup_from_to{none=0,relay=1,pos=2},emit=v(f.."IndicatorMode")}))m(e,n.dp_binary(16,{name=i.."_backlight_switch",converter=h.lookup_from_to{ON=true,OFF=false},emit=v(f.."BacklightSwitch")}))if K==2 then
m(e,n.dp_string(19,{name=i.."_inching_one",converter=x(),emit=v(f.."InchingOne")}))else
for o=1,2 do
m(e,n.dp_string(19,{name=i.."_inching_"..lower_words[o],converter=y(o),emit=v(f.."Inching"..words[o])}))end
end
m(e,n.dp_numeric(20,{name="energy",read_only=true,converter=h.divide_by_from_only(1000),emit=w.energy()}))m(e,n.dp_numeric(21,{name="current",read_only=true,converter=h.divide_by_from_only(1000),emit=w.current()}))m(e,n.dp_numeric(22,{name="power",read_only=true,converter=h.divide_by_from_only(10),emit=w.power()}))m(e,n.dp_numeric(23,{name="voltage",read_only=true,converter=h.divide_by_from_only(10),emit=w.voltage()}))m(e,n.dp_binary(101,{name=i.."_induction",converter=h.lookup_from_to{ON=true,OFF=false},emit=v(f.."Induction")}))m(e,n.dp_enum(102,{name=i.."_vibration",converter=h.lookup_from_to{off=0,low=1,medium=2,high=3},emit=v(f.."Vibration")}))return e
end
local Z=M("switches-wave13-nova-to-wk-one","novaOne","nova_one",2)k(Z,q.create_fingerprints("TS0601",{"_TZE284_3xnyj4ga"}))local aa=M("switches-wave13-nova-to-wk-two","novaTwo","nova_two",3)k(aa,q.create_fingerprints("TS0601",{"_TZE284_exfilann"}))
local function z(s)
return type(s)=="table"and type(s.preferences)=="table"and s.preferences.reverse==true
end
local function p()
return h.from_to(
function(g,s)
local l=tonumber(g)if l==nil then return nil end
return z(s)and 100-l or l
end,
function(g,s)
local l=tonumber(g)if l==nil then return nil end
return z(s)and 100-l or l
end
)
end
local function r()
return h.from_to(
function(g)
return({[0]="open",[1]="paused",[2]="closed",[3]="partially open"})[tonumber(g)]
end,
function(g)
return({open=0,stop=1,pause=1,close=2})[g]
end
)
end
local I,J=w.shade_level(),w.shade_state()
local function u(s,g,U,T)
local B,ab={},I(s,g,U,T)if ab~=nil then B[#B+1]=ab end
local R=g<=0 and"closed"or(g>=100 and"open"or"partially open")local ac=J(s,R,U,T)if ac~=nil then B[#B+1]=ac end
return #B>0 and B or nil
end
local af={profile="switches-wave13-tuya-semicom-two-two",package_group="switch-panel",magic_packet=true,query_on_configure=false,datapoints={n.dp_on_off(101,{name="switch",component="main",emit=w.switch()}),n.dp_on_off(102,{name="switch",component="switch2",emit=w.switch()}),n.dp_enum(1,{name="cover_state",component="cover1",converter=r(),emit=w.shade_state()}),n.dp_numeric(2,{name="cover_position",component="cover1",converter=p(),emit=u}),n.dp_enum(4,{name="cover_state",component="cover2",converter=r(),emit=w.shade_state()}),n.dp_numeric(5,{name="cover_position",component="cover2",converter=p(),emit=u})}}k(af,q.create_fingerprints("TS0601",{"_TZE200_rgeapp2c"}))return{id="ef00.switches.wave13.nova_semicom",registrations=F}
