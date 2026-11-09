local a,H={},{"off","on","s","previous","led","incandescent","halogen","countdown","powerOnBehavior","lightType","%","power_on_behavior","light_type","min_brightness","max_brightness","minBrightness","maxBrightness","toggle","state","momentary","normal","inverted","minimumBrightness","maximumBrightness","indicator_mode","switchType","backlightMode","switch_type","none","relay","pos","indicatorMode","backlight_mode","zdmsOneMinimumBrightness","zdmsOneMaximumBrightness","zdmsOneCountdown","zdmsTwoMinimumBrightness","zdmsTwoMaximumBrightness","zdmsTwoCountdown","whpb9ytsMaxBrightness","whpb9ytsCountdown","p0gzbqctMinBrightness","dcnsggvzMinBrightness","dcnsggvzMaxBrightness","dcnsggvzCountdown","dimmer2gMinBrightnessCh1","dimmer2gMaxBrightnessCh1","dimmer2gCountdownCh1","dimmer2gMinBrightnessCh2","dimmer2gMaxBrightnessCh2","dimmer2gCountdownCh2","dimmer3gMinBrightnessCh1","dimmer3gMaxBrightnessCh1","dimmer3gCountdownCh1","dimmer3gMinBrightnessCh2","dimmer3gMaxBrightnessCh2","dimmer3gCountdownCh2","dimmer3gMinBrightnessCh3","dimmer3gMaxBrightnessCh3","dimmer3gCountdownCh3","dimmer3gBacklightBrightnessV2","fanSwitchR32FanSpeed","fanSpeed","fan_speed","fanSwitchR32Countdown","fanLightLawxFanSpeed","fanDimmerBqlMinimumSpeed","fanCeilingZ5jzCountdownHours","ionDimmerMin","ionDimmerMax","ionDimmerCountdown","tsd1MinimumBrightness","tsd1MaximumBrightness","tsd1Countdown","la2DimmerCountdown","dfxDimmerCountdown","la2DimmerMinBrightness","dfxDimmerMinBrightness","off/on","on/off","zdmsOneSwitchType","zdmsOnePowerOnBehavior","zdmsTwoSwitchType","zdmsTwoPowerOnBehavior","whpb9ytsLightType","whpb9ytsPowerOnBehavior","whpb9ytsBacklightMode","qzaing2gBacklightMode","qzaing2gChildLock","childLock","child_lock","unlocked","locked","p0gzbqctLightType","p0gzbqctIndicatorMode","dcnsggvzLightType","dcnsggvzPowerOnBehavior","dcnsggvzSwitchType","ts0601LightPowerOnBehavior","dimmer2gLightTypeCh1","dimmer2gLightTypeCh2","dimmer2gPowerOnBehavior","dimmer3gLightTypeCh1","dimmer3gLightTypeCh2","dimmer3gLightTypeCh3","dimmer3gPowerOnBehavior","dimmer3gBacklightMode","dimmer3gBacklightColor","yellow","magenta","warm_white","fanSwitchR32PowerOnBehavior","fanLightHmqzPowerOnBehavior","fanDimmerBqlPowerOnBehavior","fanDimmerBqlIndicator","off_on","fanDimmerBqlBacklight","backlight","fanDimmerBqlChildLock","fanCeilingZ5jzPowerOnBehavior","restore","fanCeilingZ5jzLightMode","ionDimmerPowerOn","tsd1LightType","tsd1PowerOnBehavior","tsd1BacklightMode","la2DimmerLightType","la2DimmerPowerOnBehavior","la2DimmerBacklightMode","dfxDimmerLightType","dfxDimmerPowerOnBehavior","lastPowerResponseTime"}
local function b(g)
if type(g)=="number"then return H[g]end
return g
end
local function p(g)local suffix=b(g);if suffix==nil then return nil end;return"concertmirror08464."..suffix end
local t={}
local function q(k)
if type(k)~="number"then return{}end
local x=t[k]if x~=nil then return x end
local n={}t[k]=n
return n
end
local function s(D,k)
if type(D)~="table"then return nil end
local n=q(k)for A,g in ipairs(D)do n[A]=b(g)end
return n
end
local function i(g,E)
if g==nil then return E end
if g==0 then return nil end
return b(g)
end
local function m(attribute_name)
if type(attribute_name)~="string"or attribute_name==""then return nil end
return"set"..attribute_name:sub(1,1):upper()..attribute_name:sub(2)
end
local function J(g)
if type(g)~="table"then return nil end
local n=q(g[6])n.minimum=g[1]n.maximum=g[2]n.step=g[3]n.unit=b(g[4])n.allowed_values=s(g[5],g[7])return n
end
local function w(j,k)
if j==nil and k==nil then return nil end
local n=q(k)n.allowed_values=j
return n
end
local function G(f)
local attribute_name=b(f[4])return{kind="numeric",emit_name=b(f[1]),range_key=b(f[2]),capability_id=p(f[3]),attribute_name=attribute_name,range_attribute_name=b(f[5]),command_name=i(f[6],m(attribute_name)),argument_name=i(f[7],attribute_name),mapping_name=b(f[8]),label=b(f[9]),default_range=J(f[10]),event_minimum=f[11],event_maximum=f[12],event_unit=b(f[13])}
end
local function K(f)
local attribute_name,u,r=b(f[4]),s(f[10],f[12]),s(f[11],f[14])local d=w(r,f[13])return{kind="enum",emit_name=b(f[1]),range_key=b(f[2]),capability_id=p(f[3]),attribute_name=attribute_name,supported_attribute_name=b(f[5]),command_name=i(f[6],m(attribute_name)),argument_name=i(f[7],attribute_name),mapping_name=b(f[8]),label=b(f[9]),supported_values=u,default_range=d}
end
local function M(f)
local attribute_name=b(f[3])return{kind="text",emit_name=b(f[1]),capability_id=p(f[2]),attribute_name=attribute_name,command_name=i(f[4],m(attribute_name)),argument_name=i(f[5],attribute_name),mapping_name=b(f[6]),label=b(f[7]),maximum_length=f[8]}
end
local function z(L,F)
local n={}for _,f in ipairs(L)do n[#n+1]=F(f)end
return n
end
a.numeric=z({{14,14,23,16,"minBrightnessRange",nil,nil,14,"Minimum brightness",{1,1000,1,nil,nil,1},1,1000},{15,15,24,17,"maxBrightnessRange",nil,nil,15,"Maximum brightness",{1,1000,1,nil,nil,2},1,1000},{34,nil,34,23,nil,nil,nil,"zdms161_minimum_brightness","Zdms One Minimum Brightness",{0,100,1,11,nil,3},nil,nil,11},{35,nil,35,24,nil,nil,nil,"zdms161_maximum_brightness","Zdms One Maximum Brightness",{0,100,1,11,nil,4},nil,nil,11},{36,nil,36,8,nil,nil,nil,"zdms161_countdown","Zdms One Countdown",{0,43200,1,3,nil,5},nil,nil,3},{37,nil,37,23,nil,nil,nil,"zdms162_minimum_brightness","Zdms Two Minimum Brightness",{0,100,1,11,nil,6},nil,nil,11},{38,nil,38,24,nil,nil,nil,"zdms162_maximum_brightness","Zdms Two Maximum Brightness",{0,100,1,11,nil,7},nil,nil,11},{39,nil,39,8,nil,nil,nil,"zdms162_countdown","Zdms Two Countdown",{0,43200,1,3,nil,8},nil,nil,3},{40,nil,40,17,nil,nil,nil,15,"Whpb9yts Max Brightness",{0,1000,1,nil,nil,9}},{41,nil,41,8,nil,nil,nil,8,"Whpb9yts Countdown",{0,43200,1,3,nil,10},nil,nil,3},{42,nil,42,16,nil,nil,nil,14,"P0gzbqct Min Brightness",{0,1000,1,nil,nil,11}},{43,nil,43,16,nil,nil,nil,14,"Dcnsggvz Min Brightness",{0,1000,1,nil,nil,12}},{44,nil,44,17,nil,nil,nil,15,"Dcnsggvz Max Brightness",{0,1000,1,nil,nil,13}},{45,nil,45,8,nil,nil,nil,8,"Dcnsggvz Countdown",{0,43200,1,3,nil,14},nil,nil,3},{46,nil,46,16,nil,nil,nil,14,"Dimmer2g Min Brightness Ch1",{0,1000,1,nil,nil,15}},{47,nil,47,17,nil,nil,nil,15,"Dimmer2g Max Brightness Ch1",{0,1000,1,nil,nil,16}},{48,nil,48,8,nil,nil,nil,8,"Dimmer2g Countdown Ch1",{0,43200,1,3,nil,17},nil,nil,3},{49,nil,49,16,nil,nil,nil,14,"Dimmer2g Min Brightness Ch2",{0,1000,1,nil,nil,18}},{50,nil,50,17,nil,nil,nil,15,"Dimmer2g Max Brightness Ch2",{0,1000,1,nil,nil,19}},{51,nil,51,8,nil,nil,nil,8,"Dimmer2g Countdown Ch2",{0,43200,1,3,nil,20},nil,nil,3},{52,nil,52,16,nil,nil,nil,14,"Dimmer3g Min Brightness Ch1",{0,1000,1,nil,nil,21}},{53,nil,53,17,nil,nil,nil,15,"Dimmer3g Max Brightness Ch1",{0,1000,1,nil,nil,22}},{54,nil,54,8,nil,nil,nil,8,"Dimmer3g Countdown Ch1",{0,43200,1,3,nil,23},nil,nil,3},{55,nil,55,16,nil,nil,nil,14,"Dimmer3g Min Brightness Ch2",{0,1000,1,nil,nil,24}},{56,nil,56,17,nil,nil,nil,15,"Dimmer3g Max Brightness Ch2",{0,1000,1,nil,nil,25}},{57,nil,57,8,nil,nil,nil,8,"Dimmer3g Countdown Ch2",{0,43200,1,3,nil,26},nil,nil,3},{58,nil,58,16,nil,nil,nil,14,"Dimmer3g Min Brightness Ch3",{0,1000,1,nil,nil,27}},{59,nil,59,17,nil,nil,nil,15,"Dimmer3g Max Brightness Ch3",{0,1000,1,nil,nil,28}},{60,nil,60,8,nil,nil,nil,8,"Dimmer3g Countdown Ch3",{0,43200,1,3,nil,29},nil,nil,3},{61,nil,61,"backlightBrightness",nil,nil,nil,"backlight_brightness","Dimmer3g Backlight Brightness V2",{0,100,1,11,nil,30},nil,nil,11},{62,nil,62,63,nil,nil,nil,64,"Fan Switch R32Fan Speed",{1,5,1,nil,nil,31}},{65,nil,65,8,nil,nil,nil,8,"Fan Switch R32Countdown",{0,43200,1,3,nil,32},nil,nil,3},{66,nil,66,63,nil,nil,nil,64,"Fan Light Lawx Fan Speed",{1,5,1,nil,nil,33}},{67,nil,67,"minimumSpeed",nil,nil,nil,"minimum_speed","Fan Dimmer Bql Minimum Speed",{0,100,1,11,nil,34},nil,nil,11},{68,nil,68,"countdownHours",nil,nil,nil,"countdown_hours","Fan Ceiling Z5jz Countdown Hours",{0.25,12,0.25,"h",nil,35},nil,nil,"h"},{69,nil,69,23,nil,nil,nil,"ion_min_brightness","Ion Dimmer Min",{0,254,1,nil,nil,36}},{70,nil,70,24,nil,nil,nil,"ion_max_brightness","Ion Dimmer Max",{0,254,1,nil,nil,37}},{71,nil,71,8,nil,nil,nil,"ion_countdown","Ion Dimmer Countdown",{0,43200,1,3,nil,38},nil,nil,3},{72,nil,72,23,nil,nil,nil,"tsd1_min_brightness","Tsd1Minimum Brightness",{0,254,1,nil,nil,39}},{73,nil,73,24,nil,nil,nil,"tsd1_max_brightness","Tsd1Maximum Brightness",{0,254,1,nil,nil,40}},{74,nil,74,8,nil,nil,nil,"tsd1_countdown","Tsd1Countdown",{0,43200,1,3,nil,41},nil,nil,3},{75,nil,75,8,nil,nil,nil,"la2_dimmer_countdown","La2Dimmer Countdown",{0,43200,1,3,nil,42},nil,nil,3},{76,nil,76,8,nil,nil,nil,"dfx_dimmer_countdown","Dfx Dimmer Countdown",{0,43200,1,3,nil,43},nil,nil,3},{77,nil,77,23,nil,nil,nil,"la2_dimmer_min_brightness","La2Dimmer Min Brightness",{0,1000,1,nil,nil,44}},{78,nil,78,23,nil,nil,nil,"dfx_dimmer_min_brightness","Dfx Dimmer Min Brightness",{0,1000,1,nil,nil,45}}},G)a.enum=z({{25,25,32,32,"supportedIndicatorModes",nil,nil,25,"Indicator mode",{1,79,80,2},{1,79,80,2},46,47,46},{12,12,9,9,"supportedPowerOnBehaviors",nil,nil,12,"Power on behavior",{1,2,4},{1,2,4},48,49,48},{28,28,26,26,"supportedSwitchTypes",nil,nil,28,"Switch type",{18,19,20},{18,19,20},50,51,50},{13,13,10,10,"supportedLightTypes",nil,nil,13,"Light type",{5,6,7},{5,6,7},52,53,52},{81,nil,81,26,nil,nil,nil,"zdms161_switch_type","Zdms One Switch Type",{18,19,20},{18,19,20},54,55,54},{82,nil,82,9,nil,nil,nil,"zdms161_power_on_behavior","Zdms One Power On Behavior",{1,2,4},{1,2,4},56,57,56},{83,nil,83,26,nil,nil,nil,"zdms162_switch_type","Zdms Two Switch Type",{18,19,20},{18,19,20},58,59,58},{84,nil,84,9,nil,nil,nil,"zdms162_power_on_behavior","Zdms Two Power On Behavior",{1,2,4},{1,2,4},60,61,60},{85,nil,85,10,nil,nil,nil,13,"Whpb9yts Light Type",{5,6,7},{5,6,7},62,63,62},{86,nil,86,9,nil,nil,nil,12,"Whpb9yts Power On Behavior",{1,2,4},{1,2,4},64,65,64},{87,nil,87,27,nil,nil,nil,33,"Whpb9yts Backlight Mode",{1,21,22},{1,21,22},66,67,66},{88,nil,88,27,nil,nil,nil,33,"Qzaing2g Backlight Mode",{1,2},{1,2},68,69,68},{89,nil,89,90,nil,nil,nil,91,"Qzaing2g Child Lock",{92,93},{92,93},70,71,70},{94,nil,94,10,nil,nil,nil,13,"P0gzbqct Light Type",{5,6,7},{5,6,7},72,73,72},{95,nil,95,32,nil,nil,nil,25,"P0gzbqct Indicator Mode",{29,30,31},{29,30,31},74,75,74},{96,nil,96,10,nil,nil,nil,13,"Dcnsggvz Light Type",{5,6,7},{5,6,7},76,77,76},{97,nil,97,9,nil,nil,nil,12,"Dcnsggvz Power On Behavior",{1,2,4},{1,2,4},78,79,78},{98,nil,98,26,nil,nil,nil,28,"Dcnsggvz Switch Type",{18,19,20},{18,19,20},80,81,80},{99,nil,99,9,nil,nil,nil,12,"Ts0601Light Power On Behavior",{1,2,4},{1,2,4},82,83,82},{100,nil,100,10,nil,nil,nil,13,"Dimmer2g Light Type Ch1",{5,6,7},{5,6,7},84,85,84},{101,nil,101,10,nil,nil,nil,13,"Dimmer2g Light Type Ch2",{5,6,7},{5,6,7},86,87,86},{102,nil,102,9,nil,nil,nil,12,"Dimmer2g Power On Behavior",{1,2,4},{1,2,4},88,89,88},{103,nil,103,10,nil,nil,nil,13,"Dimmer3g Light Type Ch1",{5,6,7},{5,6,7},90,91,90},{104,nil,104,10,nil,nil,nil,13,"Dimmer3g Light Type Ch2",{5,6,7},{5,6,7},92,93,92},{105,nil,105,10,nil,nil,nil,13,"Dimmer3g Light Type Ch3",{5,6,7},{5,6,7},94,95,94},{106,nil,106,9,nil,nil,nil,12,"Dimmer3g Power On Behavior",{1,2,4},{1,2,4},96,97,96},{107,nil,107,27,nil,nil,nil,33,"Dimmer3g Backlight Mode",{1,21,22},{1,21,22},98,99,98},{108,nil,108,"backlightColor",nil,nil,nil,"backlight_color","Dimmer3g Backlight Color",{"red","blue","green","white",109,110,"cyan",111},{"red","blue","green","white",109,110,"cyan",111},100,101,100},{112,nil,112,9,nil,nil,nil,12,"Fan Switch R32Power On Behavior",{1,2},{1,2},102,103,102},{113,nil,113,9,nil,nil,nil,12,"Fan Light Hmqz Power On Behavior",{1,2},{1,2},104,105,104},{114,nil,114,9,nil,nil,nil,12,"Fan Dimmer Bql Power On Behavior",{1,2,4},{1,2,4},106,107,106},{115,nil,115,"indicator",nil,nil,nil,25,"Fan Dimmer Bql Indicator",{1,116,2},{1,116,2},108,109,108},{117,nil,117,118,nil,nil,nil,118,"Fan Dimmer Bql Backlight",{1,2},{1,2},110,111,110},{119,nil,119,90,nil,nil,nil,91,"Fan Dimmer Bql Child Lock",{1,2},{1,2},112,113,112},{120,nil,120,9,nil,nil,nil,12,"Fan Ceiling Z5jz Power On Behavior",{1,2,121},{1,2,121},114,115,114},{122,nil,122,"lightMode",nil,nil,nil,"light_mode","Fan Ceiling Z5jz Light Mode",{29,30,31},{29,30,31},116,117,116},{123,nil,123,9,nil,nil,nil,"ion_power_on","Ion Dimmer Power On",{1,2,4},{1,2,4},118,119,118},{124,nil,124,10,nil,nil,nil,"tsd1_light_type","Tsd1Light Type",{5,6,7},{5,6,7},120,121,120},{125,nil,125,9,nil,nil,nil,"tsd1_power_on_behavior","Tsd1Power On Behavior",{1,2,4},{1,2,4},122,123,122},{126,nil,126,27,nil,nil,nil,"tsd1_backlight_mode","Tsd1Backlight Mode",{1,21,22},{1,21,22},124,125,124},{127,nil,127,10,nil,nil,nil,"la2_dimmer_light_type","La2Dimmer Light Type",{5,6,7},{5,6,7},126,127,126},{128,nil,128,9,nil,nil,nil,"la2_dimmer_power_on_behavior","La2Dimmer Power On Behavior",{1,2,4},{1,2,4},128,129,128},{129,nil,129,27,nil,nil,nil,"la2_dimmer_backlight_mode","La2Dimmer Backlight Mode",{1,21,22},{1,21,22},130,131,130},{130,nil,130,10,nil,nil,nil,"dfx_dimmer_light_type","Dfx Dimmer Light Type",{5,6,7},{5,6,7},132,133,132},{131,nil,131,9,nil,nil,nil,"dfx_dimmer_power_on_behavior","Dfx Dimmer Power On Behavior",{1,2,4},{1,2,4},134,135,134}},K)a.text=z({{"last_power_response_time",132,132,0,0,nil,"Last power response time",64}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
local function o(y)
for _,e in ipairs(y)do
a.by_emit_name[e.emit_name]=e
if type(e.capability_id)=="string"and e.capability_id~=""then a.by_capability_id[e.capability_id]=e end
if type(e.range_key)=="string"and e.range_key~=""then a.by_range_key[e.range_key]=e end
end
end
o(a.numeric)o(a.enum)o(a.text)a.by_emit_name[a.driver_message.emit_name]=a.driver_message
a.by_capability_id[a.driver_message.capability_id]=a.driver_message
local function l(j)
if type(j)~="table"then return nil end
local B={}for A,g in ipairs(j)do B[A]=g end
return B
end
function a.resolve_range(v,e)
if type(e)~="table"then return nil end
local d,C=type(e.default_range)=="table"and e.default_range or nil,type(v)=="table"and v.presence_capability_ranges or nil

local h=type(C)=="table"and C[e.range_key]or nil
if type(h)~="table"then h=d end
if type(h)~="table"then return nil end
return{minimum=type(h.minimum)=="number"and h.minimum or(d and d.minimum or nil),maximum=type(h.maximum)=="number"and h.maximum or(d and d.maximum or nil),step=type(h.step)=="number"and h.step or(d and d.step or nil),unit=type(h.unit)=="string"and h.unit or(d and d.unit or nil),allowed_values=type(h.allowed_values)=="table"and l(h.allowed_values)or l(d and d.allowed_values or nil)}
end
return a
