local G,X,R,W,ab,b=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.capabilities",require"st.zigbee.device_management",require"st.zigbee.data_types"local E,H=R.definition_registry()local av,f,V,m,K,s,a,v,B,i="concertmirror08464.",5423,0,2,3,1026,513,516,2821,64719








local function aL(capability_id)
return assert(X[capability_id],"missing Wave19 Sber emitter: "..capability_id)()
end
local function aV(C)
local N={}for aZ,g in pairs(C or{})do N[aZ]=g end
return N
end
local function d(aP,j)
aP[#aP+1]=j
return j
end
local function j(w,p,ae,capability_id,x,C)
local t=aV(C)t.name=ae
t.emit=aL(capability_id)t.data_type=x
t.write_type=t.write_type or x
t.endpoint=t.endpoint or 1
return G.cluster_attribute(w,p,t)
end
local function h(w,p,ae,capability_id,x,C)
local t=aV(C)t.mfg_code=f
return j(w,p,ae,capability_id,x,t)
end
local function u(p,ae,capability_id,x,C)
return h(i,p,ae,capability_id,x,C)
end
local function I(aY)
return function(g)
return bit32.band(tonumber(g)or 0,aY)~=0 and"active"or"clear"
end
end
local function M(aW)
local to={}for ba,g in pairs(aW)do to[g]=ba end
return function(g)return aW[tonumber(g)]end,
function(g)return to[g]end
end
local function U(g)
local y=tonumber(g)if y==nil then return nil end
return math.floor(y*2+0.5)/2
end
local function aI(g)
local y=math.floor(tonumber(g)or 0)if y<0 then y=y+65536 end
return string.char(y%256,math.floor(y/256)%256)
end
local function ai(e,w,p,ad)
G.read_attribute(e,w,p,1,ad)
end
local function F(e,w,aF,ad)
for _,p in ipairs(aF)do ai(e,w,p,ad)end
end
local function aU(e,aR,aQ)
for _,w in ipairs(aQ)do
e:send(ab.build_bind_request(e,w,aR,1))end
end
local function am(e,_,_,Q)
return G.send_raw_cluster_command(e,K,0,aI(3),Q.endpoint or 1,nil,nil,false)
end
local function P(e,_,_,Q)
return G.send_raw_cluster_command(e,a,3,"",Q.endpoint or 1,nil,nil,false)
end
local aT={{"Sunday","sunday",1},{"Monday","monday",2},{"Tuesday","tuesday",4},{"Wednesday","wednesday",8},{"Thursday","thursday",16},{"Friday","friday",32},{"Saturday","saturday",64}}
local function z(e,T)
for _,day in ipairs(aT)do
G.send_raw_cluster_command(e,a,2,string.char(day[3],1),T or 1,nil,nil,true)end
end
local function aD(g)
local N={}for ap in string.gmatch(g,"%S+")do N[#N+1]=ap end
table.sort(N)return N
end
local function ag(ap)
local az,Z,temperature=ap:match"^(%d%d):(%d%d)/(%d+%.?%d*)$"az,Z,temperature=tonumber(az),tonumber(Z),tonumber(temperature)if az==nil or Z==nil or temperature==nil or az>23 or Z>59
or temperature<1 or temperature>50 or temperature*2%1~=0 then
return nil
end
return az*60+Z,math.floor(temperature*100+0.5)
end
local function aw(S)
return function(e,_,g,Q)
if type(g)~="string"then return false end
local k=g==""and{}or aD(g)if #k>10 then return false end
local Y={string.char(#k,S,1)}for _,ap in ipairs(k)do
local o,l=ag(ap)if o==nil then return false end
Y[#Y+1]=aI(o)Y[#Y+1]=aI(l)end
local T=Q.endpoint or 1
local aX=G.send_raw_cluster_command(e,a,1,table.concat(Y),T,nil,nil,false)if aX then z(e,T)end
return aX
end
end
local function aq(S)
return function(aJ)
local q=aJ and aJ.body and aJ.body.zcl_body or nil
local function aa(g)
if type(g)=="table"and g.value~=nil then return tonumber(g.value)end
return tonumber(g)
end
local k,D,day,aH,aB={},q and aa(q.number_of_transitions)or nil,q and aa(q.day_of_week)or nil,q and aa(q.mode)or nil,q and q.transitions_list or nil



if D~=nil and day~=nil and aH~=nil and type(aB)=="table"then
if D%1~=0 or D<0 or D>10 or bit32.band(day,S)==0
or bit32.band(aH,1)==0 or D>#aB then return nil end
for an=1,D do
local J=aB[an]local o,l=J and aa(J.transition_time)or nil,J and aa(J.heat_set_point)or nil

if o==nil or o%1~=0 or o<0 or o>1439
or l==nil or l<100 or l>5000 then return nil end
k[#k+1]=string.format("%02d:%02d/%g",math.floor(o/60),o%60,l/100)end
else
local O=q and q.body_bytes or nil
if type(O)~="string"or #O<3 or bit32.band(string.byte(O,2),S)==0 then return nil end
D=string.byte(O,1)aH=string.byte(O,3)if D>10 or bit32.band(aH,1)==0 or #O<3+D*4 then return nil end
for an=0,D-1 do
local ao=4+an*4
local o,l=string.byte(O,ao)+string.byte(O,ao+1)*256,string.byte(O,ao+2)+string.byte(O,ao+3)*256

if l>=32768 then l=l-65536 end
if o>1439 or l<100 or l>5000 then return nil end
k[#k+1]=string.format("%02d:%02d/%g",math.floor(o/60),o%60,l/100)end
end
table.sort(k)return table.concat(k," ")
end
end
local c,L={},{}for _,item in ipairs{{12289,"emergency_overcurrent","EmergencyOvercurrent",4,i},{12289,"emergency_overheat","EmergencyOverheat",8,i},{12289,"emergency_no_load","EmergencyNoLoad",16,i}}do
d(c,u(item[1],"sber_therm_"..item[2],"sberTherm"..item[3],b.Bitmap16,{read_only=true,from_device=I(item[4]),read_on_configure=false}))end
for _,item in ipairs{{16642,"sensor_error_remote_disconnected","RemoteDisconnected",1},{16642,"sensor_error_local_disconnected","SensorLocalDisconnected",2},{16642,"sensor_error_short_circuit","SensorShortCircuit",4},{16643,"status_heat_inefficient","HeatInefficient",1},{16643,"status_antifrost","Antifrost",2},{16643,"status_invalid_time","InvalidTime",8}}do
d(c,h(a,item[1],"sber_therm_"..item[2],"sberTherm"..item[3],b.Bitmap16,{read_only=true,from_device=I(item[4]),read_on_configure=false}))end
local aC,aN=M{[0]="unlock",[1]="lock1"}d(c,j(v,1,"sber_therm_keypad_lockout","sberThermKeypadLockout",b.Enum8,{from_device=aC,to_device=aN,numeric_range=nil,read_on_configure=false}))d(c,G.cluster_attribute(a,18,{name="current_heating_setpoint",endpoint=1,emit=X.heating_setpoint"C",data_type=b.Int16,write_type=b.Int16,scale=100,to_device=U,numeric_range={minimum=1,maximum=50,step=0.5,unit="C"},read_on_configure=false}))d(c,G.cluster_attribute(a,0,{name="local_temperature",endpoint=1,read_only=true,emit=X.temperature"C",data_type=b.Int16,scale=100,read_on_configure=false}))local aE,aO=M{[0]="off",[4]="heat",[9]="asleep"}d(c,G.cluster_attribute(a,28,{name="system_mode",endpoint=1,emit=X.thermostat_mode(),data_type=b.Enum8,write_type=b.Enum8,from_device=aE,to_device=aO,read_on_configure=false}))d(c,G.cluster_attribute(a,41,{name="thermostat_operating_state",endpoint=1,read_only=true,emit=X.thermostat_operating_state(),data_type=b.Bitmap16,
from_device=function(g)return bit32.band(tonumber(g)or 0,1)~=0 and"heating"or"idle"end,
read_on_configure=false}))d(c,j(a,16,"sber_therm_local_calibration","sber205Calibration",b.Int8,{scale=10,numeric_range={minimum=-10,maximum=10,step=0.5,unit="C"},read_on_configure=false}))local ax,aG=M{[2]="heating_only"}d(c,j(a,27,"sber_therm_control_sequence","sberThermControlSequence",b.Enum8,{from_device=ax,to_device=aG,read_on_configure=false}))
local ac=function(g)return({[0]="off",[4]="heat"})[tonumber(g)]end
d(c,j(a,30,"sber_therm_running_mode","sberThermRunningMode",b.Enum8,{read_only=true,from_device=ac,read_on_configure=false}))local ah,as=M{[0]="setpoint",[1]="schedule"}d(c,j(a,37,"sber_therm_programming_mode","sberThermProgrammingMode",b.Bitmap8,{from_device=ah,to_device=as,read_on_configure=false}))d(c,j(a,3,"sber_therm_abs_min_heat_limit","sberThermAbsMinHeatLimit",b.Int16,{read_only=true,scale=100,read_on_configure=false}))d(c,j(a,4,"sber_therm_abs_max_heat_limit","sberThermAbsMaxHeatLimit",b.Int16,{read_only=true,scale=100,read_on_configure=false}))d(c,j(a,21,"sber_therm_min_heat_limit","sberThermMinHeatLimit",b.Int16,{scale=100,to_device=U,numeric_range={minimum=1,maximum=35,step=0.5,unit="C"},read_on_configure=false}))d(c,j(a,22,"sber_therm_max_heat_limit","sberThermMaxHeatLimit",b.Int16,{scale=100,to_device=U,numeric_range={minimum=5,maximum=50,step=0.5,unit="C"},read_on_configure=false}))d(c,G.cluster_attribute(a,nil,{name="sber_therm_clear_schedule",endpoint=1,write_only=true,sender=P}))L[#L+1]={capability_id=av .."sberThermClearSchedule",command_name="clear",value=true,mapping_name="sber_therm_clear_schedule"}for an,day in ipairs(aT)do
local ae="sber_therm_"..day[2].."_schedule"d(c,G.cluster_attribute(a,61952+an,{name=ae,endpoint=1,emit=aL("sberTherm"..day[1].."Schedule"),read_only=false,data_type=b.CharString,write_type=b.CharString,sender=aw(day[3]),command_id=0,command_extractor=aq(day[3]),read_on_configure=false}))end
for _,field in ipairs{{16624,"min_local_temperature","MinLocalTemperature",b.Int16,100,1,35,0.01,"C"},{16625,"max_local_temperature","MaxLocalTemperature",b.Int16,100,5,50,0.01,"C"},{16409,"heating_hysteresis","HeatingHysteresis",b.Int8,10,1,10,0.1,"C"},{16385,"remote_temperature","RemoteTemperature",b.Int16,100,-273.15,327.67,0.01,"C"},{16386,"remote_calibration","RemoteCalibration",b.Int8,10,-12.8,12.7,0.1,"C"},{16899,"remote_sensor_timeout","RemoteSensorTimeout",b.Uint16,1,1,65535,1,"s"}}do
d(c,h(a,field[1],"sber_therm_"..field[2],"sberTherm"..field[3],field[4],{scale=field[5],numeric_range={minimum=field[6],maximum=field[7],step=field[8],unit=field[9]},read_on_configure=true}))end
local al,au=M{[0]="4p7K",[1]="6p8K",[2]="10K",[3]="12K",[4]="15K",[5]="33K",[6]="47K"}d(c,h(a,16641,"sber_therm_sensor_type","sberThermSensorType",b.Enum8,{from_device=al,to_device=au,read_on_configure=true}))local ak,at=M{[0]="local",[1]="remote",[2]="both"}d(c,h(a,16387,"sber_therm_sensor_mode","sberThermSensorMode",b.Enum8,{from_device=ak,to_device=at,read_on_configure=true}))local af,ar=M{[0]="normal",[1]="inverted"}d(c,h(a,16640,"sber_therm_output_mode","sberThermOutputMode",b.Enum8,{from_device=af,to_device=ar,read_on_configure=true}))d(c,j(m,0,"sber_therm_device_temperature","sberThermDeviceTemperature",b.Int16,{read_only=true,read_on_configure=false}))d(c,j(s,0,"sber_therm_wired_temperature","sberThermWiredTemperature",b.Int16,{read_only=true,scale=100,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}))d(c,G.cluster_attribute(i,16385,{name="voltage",endpoint=1,read_only=true,mfg_code=f,
data_type=b.Uint32,from_device=function(g)return g/1000 end,
emit=X.voltage(),read_on_configure=false}))d(c,G.cluster_attribute(i,16386,{name="current",endpoint=1,read_only=true,mfg_code=f,
data_type=b.Uint32,from_device=function(g)return g/1000 end,
emit=X.current(),read_on_configure=false}))d(c,G.cluster_attribute(i,16387,{name="power",endpoint=1,read_only=true,mfg_code=f,
data_type=b.Int32,from_device=function(g)return g/1000 end,
emit=X.power(),read_on_configure=false}))d(c,u(12307,"sber_therm_upper_current_threshold","sberThermUpperCurrentThreshold",b.Uint32,{numeric_range={minimum=100,maximum=16000,step=100,unit="mA"},read_on_configure=false}))d(c,u(12308,"sber_therm_temperature_threshold","sberThermTemperatureThreshold",b.Int16,{numeric_range={minimum=-200,maximum=200,step=1,unit="C"},read_on_configure=false}))d(c,h(v,8193,"sber_therm_brightness_operations","sberThermBrightnessOperations",b.Uint16,{numeric_range={minimum=0,maximum=1000,step=1},read_on_configure=true}))d(c,h(v,8194,"sber_therm_brightness_steady","sberThermBrightnessSteady",b.Uint16,{numeric_range={minimum=0,maximum=1000,step=1},read_on_configure=true}))d(c,G.cluster_attribute(K,nil,{name="sber_therm_identify",endpoint=1,write_only=true,sender=am}))L[#L+1]={capability_id=av .."sberThermIdentify",command_name="identify",value=true,mapping_name="sber_therm_identify"}d(c,u(20481,"sber_therm_rtc_unavailable","sberThermRtcUnavailable",b.Bitmap16,{read_only=true,from_device=I(1),read_on_configure=false}))d(c,u(20481,"sber_therm_rtc_data_not_vaild","sberThermRtcDataNotVaild",b.Bitmap16,{read_only=true,from_device=I(2),read_on_configure=false}))d(c,j(V,13,"sber_therm_serial_number","sberThermSerialNumber",b.CharString,{
read_only=true,from_device=function(g)return tostring(g)end,read_on_configure=false
}))for _,field in ipairs{{0,"resets_count","ResetsCount",b.Uint16,nil},{4097,"uptime","Uptime",b.Uint32,f},{4098,"button_clicks_one","ButtonClicksOne",b.Uint32,f},{4099,"button_clicks_two","ButtonClicksTwo",b.Uint32,f},{4100,"button_clicks_three","ButtonClicksThree",b.Uint32,f},{4101,"relay_switches_one","RelaySwitchesOne",b.Uint32,f}}do
d(c,j(B,field[1],"sber_therm_"..field[2],"sberTherm"..field[3],field[4],{read_only=true,mfg_code=field[5],read_on_configure=false}))end
local function aK(aM,e)
ai(e,V,13)F(e,i,{16385,16386,16387,12289,12307,12308},f)ai(e,m,0)ai(e,s,0)F(e,a,{18,0,16,3,4,21,22,27,28,30})F(e,a,{32,33,34,37,41})F(e,a,{16385,16386,16409,16624,16625,16642,16643},f)ai(e,a,16899,f)ai(e,v,1)F(e,v,{8193,8194},f)ai(e,i,20481,f)z(e,1)aU(e,aM.environment_info.hub_zigbee_eui,{m,s,a,v,i})aU(e,aM.environment_info.hub_zigbee_eui,{B})
end
local aj={profile="thermostats-wave19-sber-sbdv-00205",package_group="wave19-thermostat-zcl",zcl_clusters=c,capability_commands=L,thermostat_supported_modes={"off","heat","asleep"},heating_setpoint_range={minimum=1,maximum=50,step=0.5,unit="C"},configure=aK}
aj.runtime_start=function(e)
e:emit_component_event({id="main"},W.thermostatMode.supportedThermostatModes(aj.thermostat_supported_modes,{visibility={displayed=false}}))e:emit_component_event({id="main"},W.thermostatHeatingSetpoint.heatingSetpointRange{value={minimum=aj.heating_setpoint_range.minimum,maximum=aj.heating_setpoint_range.maximum,step=aj.heating_setpoint_range.step},unit=aj.heating_setpoint_range.unit})
end
H(aj,{R.create_fingerprint("SDevices","SBDV-00205")})G.attach_reporting_capabilities(E,{{1,"rpt-sas"}})return{id="zcl.thermostats.wave19.sber",registrations=E}
