local a,H={},{"off","on","C","s","min","F","%","previous","heating","cooling","countdown","power_on_behavior","indicator_mode","powerOnBehavior","delay","temperatureRange","temperature_range","temperatureCalibration","temperature_calibration","indicatorMode","mode","rjvxCountdown","rjvxTempCSetpoint","rjvxTempFSetpoint","rjvxTemperatureF","rjvxTemperatureRange","rjvxTempCalibration","rjvxCoolingDelay","apiuCountdown","mgzgCountdown1","countdownOne","usb4gCountdownUsba","usb4gCountdownUsbc","usb4gCountdownPlugOne","usb4gCountdownPlugTwo","scimagicTempCalibration","usb4gProducedEnergyStatus","sciThTarget","temperatureTarget","temperature_target","sciThRange","sciThDelayTime","delayTime","delay_time","sciThHumidityTarget","sciThHumidityRange","sciThHumidityCalibration","sciTempCalibration","sciTempTarget","sciTempRange","sciTempDelayTime","off/on","on/off","rjvxAutowork","autowork","rjvxWorkMode","workMode","rjvxTemperatureUnit","celsius","fahrenheit","rjvxCoolingDelaySwitch","usb4gRelayStatus","usb4gBacklight","usb4gChildLock","mgzgPowerOnBehavior","mgzgBacklightMode","scimagicMode","dehumidify","scimagicAutoWork","autoWork","auto_work","scimagicDelay","sciTempAuto","sciTempMode","sciTempDelay","ts6gPowerOnBehavior","memory","ts6gIndicatorMode","none","relay","lastPowerResponseTime"}
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
a.numeric=z({{22,nil,22,11,nil,nil,nil,11,"Rjvx Countdown",{0,86400,1,4,nil,1},nil,nil,4},{23,nil,23,"temperatureCelsiusSetpoint",nil,nil,nil,"temperature_c_setpoint","Rjvx Temp CSetpoint",{-20,102,0.5,3,nil,2},nil,nil,3},{24,nil,24,"temperatureFahrenheitSetpoint",nil,nil,nil,"temperature_f_setpoint","Rjvx Temp FSetpoint",{-4,221,0.5,6,nil,3},nil,nil,6},{25,nil,25,"temperatureFahrenheit",nil,0,0,"temperature_fahrenheit","Rjvx Temperature F",{-4,221,0.1,6,nil,4},nil,nil,6},{26,nil,26,16,nil,nil,nil,17,"Rjvx Temperature Range",{1,9,0.5,3,nil,5},nil,nil,3},{27,nil,27,18,nil,nil,nil,19,"Rjvx Temp Calibration",{-9,9,1,6,nil,6},nil,nil,6},{28,nil,28,"coolingDelay",nil,nil,nil,"cooling_delay","Rjvx Cooling Delay",{0,10,1,5,nil,7},nil,nil,5},{29,nil,29,11,nil,nil,nil,11,"Apiu Countdown",{0,120,1,5,nil,8},nil,nil,5},{30,nil,30,31,nil,nil,nil,11,"Mgzg Countdown1",{0,86400,1,4,nil,9},nil,nil,4},{32,nil,32,31,nil,nil,nil,"countdown_usb_a","Usb4g Countdown Usba",{0,86400,1,4,nil,10},nil,nil,4},{33,nil,33,"countdownTwo",nil,nil,nil,"countdown_usb_c","Usb4g Countdown Usbc",{0,86400,1,4,nil,11},nil,nil,4},{34,nil,34,"countdownThree",nil,nil,nil,"countdown_plug_1","Usb4g Countdown Plug One",{0,86400,1,4,nil,12},nil,nil,4},{35,nil,35,"countdownFour",nil,nil,nil,"countdown_plug_2","Usb4g Countdown Plug Two",{0,86400,1,4,nil,13},nil,nil,4},{36,nil,36,18,nil,nil,nil,19,"Scimagic Temp Calibration",{-10,10,0.5,3,nil,14},nil,nil,3},{37,nil,37,"producedEnergy",nil,0,0,"produced_energy","Usb4g Produced Energy Status",{nil,nil,nil,"kWh",nil,15},nil,nil,"kWh"},{38,nil,38,39,nil,nil,nil,40,"Sci Th Target",{-100,100,0.5,3,nil,16},nil,nil,3},{41,nil,41,16,nil,nil,nil,17,"Sci Th Range",{1,10,0.1,3,nil,17},nil,nil,3},{42,nil,42,43,nil,nil,nil,44,"Sci Th Delay Time",{0,10,1,5,nil,18},nil,nil,5},{45,nil,45,"humidityTarget",nil,nil,nil,"humidity_target","Sci Th Humidity Target",{1,99,1,7,nil,19},nil,nil,7},{46,nil,46,"humidityRange",nil,nil,nil,"humidity_range","Sci Th Humidity Range",{1,10,1,7,nil,20},nil,nil,7},{47,nil,47,"humidityCalibration",nil,nil,nil,"humidity_calibration","Sci Th Humidity Calibration",{-9,9,1,7,nil,21},nil,nil,7},{48,nil,48,18,nil,nil,nil,19,"Sci Temp Calibration",{-10,10,0.5,3,nil,22},nil,nil,3},{49,nil,49,39,nil,nil,nil,40,"Sci Temp Target",{-100,100,0.5,3,nil,23},nil,nil,3},{50,nil,50,16,nil,nil,nil,17,"Sci Temp Range",{1,10,0.1,3,nil,24},nil,nil,3},{51,nil,51,43,nil,nil,nil,44,"Sci Temp Delay Time",{0,10,1,5,nil,25},nil,nil,5}},G)a.enum=z({{13,13,20,20,"supportedIndicatorModes",nil,nil,13,"Indicator mode",{1,52,53,2},{1,52,53,2},26,27,26},{12,12,14,14,"supportedPowerOnBehaviors",nil,nil,12,"Power on behavior",{1,2,8},{1,2,8},28,29,28},{54,nil,54,55,nil,nil,nil,55,"Rjvx Autowork",{1,2},{1,2},30,31,30},{56,nil,56,57,nil,nil,nil,"work_mode","Rjvx Work Mode",{9,10},{9,10},32,33,32},{58,nil,58,"temperatureUnit",nil,nil,nil,"temperature_unit","Rjvx Temperature Unit",{59,60},{59,60},34,35,34},{61,nil,61,"coolingDelaySwitch",nil,nil,nil,"cooling_delay_switch","Rjvx Cooling Delay Switch",{1,2},{1,2},36,37,36},{62,nil,62,"relayStatus",nil,nil,nil,"relay_status","Usb4g Relay Status",{1,2,8},{1,2,8},38,39,38},{63,nil,63,"backlightSwitch",nil,nil,nil,"switch_backlight","Usb4g Backlight",{1,2},{1,2},40,41,40},{64,nil,64,"childLock",nil,nil,nil,"child_lock","Usb4g Child Lock",{1,2},{1,2},42,43,42},{65,nil,65,14,nil,nil,nil,12,"Mgzg Power On Behavior",{1,2,8},{1,2,8},44,45,44},{66,nil,66,"backlightMode",nil,nil,nil,"backlight_mode","Mgzg Backlight Mode",{1,2},{1,2},46,47,46},{67,nil,67,21,nil,nil,nil,21,"Scimagic Mode",{9,68,10,"wet"},{9,68,10,"wet"},48,49,48},{69,nil,69,70,nil,nil,nil,71,"Scimagic Auto Work",{1,2},{1,2},50,51,50},{72,nil,72,15,nil,nil,nil,15,"Scimagic Delay",{1,2},{1,2},52,53,52},{73,nil,73,70,nil,nil,nil,71,"Sci Temp Auto",{2,1},{2,1},54,55,54},{74,nil,74,57,nil,nil,nil,21,"Sci Temp Mode",{9,10},{9,10},56,57,56},{75,nil,75,15,nil,nil,nil,15,"Sci Temp Delay",{2,1},{2,1},58,59,58},{76,nil,76,14,nil,nil,nil,12,"Ts6g Power On Behavior",{1,2,77},{1,2,77},60,61,60},{78,nil,78,20,nil,nil,nil,13,"Ts6g Indicator Mode",{79,80,"pos"},{79,80,"pos"},62,63,62}},K)a.text=z({{"last_power_response_time",81,81,0,0,nil,"Last power response time",64}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
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
