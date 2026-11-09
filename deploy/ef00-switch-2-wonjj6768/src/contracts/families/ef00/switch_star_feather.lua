local n,g,G,z=require"protocol.tuya",require"contracts.helpers.family",require"capabilities.events.all",require"st.capabilities"local i=n.converter
local q,c=g.definition_registry()local y,l,m,o,p={"One","Two","Three","Four"},i.lookup_from_to{off=0,on=1,previous=2},i.lookup_from_to{off=0,relay=1,invert=2},i.lookup_from_to{["Gear 0"]=0,["Gear 1"]=1,["Gear 2"]=2,["Gear 3"]=3},i.from_only(i.constant"pushed")
local function r(_,F)
if F=="pushed"then
return z.button.button.pushed{state_change=true}end
end
local function s(j)
if j==1 then return"main"end
return"switch"..tostring(j)
end
local function h(family_word,item,gang_word)
local D="sfl_"..family_word:lower().."_"..item
if gang_word~=nil then
D=D .."_"..gang_word:lower()end
return D
end
local function f(family_word,item,gang_word)
local t="sfl"..family_word ..item..(gang_word or"")return G[t]()
end
local function d(family_word,B,E)
local a={profile=E,package_group="switch-panel",button_actions={"pushed"},query_on_configure=false,time_start="1970",datapoints={}}for j=1,B do
local gang_word,k,A,C=y[j],s(j),"switch_"..tostring(j),"scene_"..tostring(j)a.datapoints[#a.datapoints+1]=n.dp_enum(j,{name="scene_action_"..tostring(j),component=k,read_only=true,converter=p,emit=r})a.datapoints[#a.datapoints+1]=n.dp_enum(17+j,{name=h(family_word,"mode",gang_word),component=k,converter=i.lookup_from_to{[A]=0,[C]=1},emit=f(family_word,"Mode",gang_word)})a.datapoints[#a.datapoints+1]=n.dp_on_off(23+j,{name="switch",component=k})a.datapoints[#a.datapoints+1]=n.dp_countdown(29+j,{name=h(family_word,"countdown",gang_word),component=k,emit=f(family_word,"Countdown",gang_word)})a.datapoints[#a.datapoints+1]=n.dp_countdown(104+j,{name=h(family_word,"momentary",gang_word),component=k,emit=f(family_word,"Momentary",gang_word)})end
a.datapoints[#a.datapoints+1]=n.dp_on_off(36,{name="switch",component="backlight"})a.datapoints[#a.datapoints+1]=n.dp_enum(37,{name=h(family_word,"indicator_status"),converter=m,emit=f(family_word,"IndicatorStatus")})a.datapoints[#a.datapoints+1]=n.dp_enum(38,{name=h(family_word,"power_on_behavior"),converter=l,emit=f(family_word,"PowerOnBehavior")})a.datapoints[#a.datapoints+1]=n.dp_on_off(103,{name="switch",component="induction"})a.datapoints[#a.datapoints+1]=n.dp_enum(104,{name=h(family_word,"vibration_mode"),converter=o,emit=f(family_word,"VibrationMode")})return a
end
local u=d("One",1,"switches-moes-sfl02-z1")c(u,g.create_fingerprints("TS0601",{"_TZE200_stvgmdjz","_TZE200_ydkqbmpt","_TZE200_z3u99qxt"}))local v=d("Two",2,"switches-moes-sfl02-z2")c(v,g.create_fingerprints("TS0601",{"_TZE200_uenof8jd","_TZE200_tzyy0rtq","_TZE200_hktk6hze","_TZE284_uenof8jd"}))local w=d("Three",3,"switches-moes-sfl02-z3")c(w,g.create_fingerprints("TS0601",{"_TZE200_rd8cdssd","_TZE200_wv9ukqca","_TZE200_zo0cfekv"}))local x=d("Four",4,"switches-moes-sfl02-z4")c(x,g.create_fingerprints("TS0601",{"_TZE200_dq8bu0pt","_TZE200_hmabvy81","_TZE200_9dhenr94"}))return{id="ef00.switch.star_feather",registrations=q}
