local a,H={},{"red","blue","green","white","yellow","magenta","cyan","warm_white","warm_yellow","off","zmsFourBacklightBrightness","zmsFourCountdown","zms206us4TimeZone","zmsFourBacklightSetting","zmsFourChildLock","zmsFourRadarConfig","none","zmsFourSwitchColorOn","zmsFourSwitchColorOff","zmsFourIndicatorStatus","on_off_status","switch_position","zmsFourDelayOffColor","zmsFourRelayStatus","power_on","power_off","restart_memory","lastPowerResponseTime","zms206us4SwitchName"}
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
a.numeric=z({{11,nil,11,"backlightBrightness",nil,nil,nil,"zms206_backlight_brightness","Zms Four Backlight Brightness",{0,100,1,"%",nil,1},nil,nil,"%"},{12,nil,12,"countdown",nil,nil,nil,"zms206_countdown","Zms Four Countdown",{0,43200,1,"s",nil,2},nil,nil,"s"},{13,nil,13,"timeZone",nil,nil,nil,"zms206_time_zone","Zms206us4Time Zone",{-12,14,0.25,"h",nil,3},nil,nil,"h"}},G)a.enum=z({{14,nil,14,"backlightSetting",nil,nil,nil,"zms206_backlight_mode","Zms Four Backlight Setting",{"OFF","ON"},{"OFF","ON"},4,5,4},{15,nil,15,"childLock",nil,nil,nil,"zms206_child_lock","Zms Four Child Lock",{10,"on"},{10,"on"},6,7,6},{16,nil,16,"radarConfig",nil,nil,nil,"zms206_radar_config","Zms Four Radar Config",{17,"10s","20s","30s","45s","60s"},{17,"10s","20s","30s","45s","60s"},8,9,8},{18,nil,18,"switchColorOn",nil,nil,nil,"zms206_switch_color_on","Zms Four Switch Color On",{1,2,3,4,5,6,7,8,9},{1,2,3,4,5,6,7,8,9},10,11,10},{19,nil,19,"switchColorOff",nil,nil,nil,"zms206_switch_color_off","Zms Four Switch Color Off",{1,2,3,4,5,6,7,8,9},{1,2,3,4,5,6,7,8,9},12,13,12},{20,nil,20,"indicatorStatus",nil,nil,nil,"zms206_indicator_status","Zms Four Indicator Status",{10,21,22},{10,21,22},14,15,14},{23,nil,23,"delayOffColor",nil,nil,nil,"zms206_delay_off_color","Zms Four Delay Off Color",{1,2,3,4,5,6,7,8,9},{1,2,3,4,5,6,7,8,9},16,17,16},{24,nil,24,"relayStatus",nil,nil,nil,"zms206_relay_status","Zms Four Relay Status",{25,26,27},{25,26,27},18,19,18}},K)a.text=z({{"last_power_response_time",28,28,0,0,nil,"Last power response time",64},{29,29,"switchName",nil,nil,"zms206_switch_name","Zms206us4Switch Name"}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
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
