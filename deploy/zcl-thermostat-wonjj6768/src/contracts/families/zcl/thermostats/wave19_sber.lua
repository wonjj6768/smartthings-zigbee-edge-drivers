local H,U,S,Y,ac,b=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.capabilities",require"st.zigbee.device_management",require"st.zigbee.data_types"local F,I=S.definition_registry()local aw,g,X,m,L,s,a,v,D,i="concertmirror08464.",5423,0,2,3,1026,513,516,2821,64719








local function aV(capability_id)
return assert(U[capability_id],"missing Wave19 Sber emitter: "..capability_id)()
end
local function aU(E)
local O={}for aZ,e in pairs(E or{})do O[aZ]=e end
return O
end
local function d(aO,j)
aO[#aO+1]=j
return j
end
local function j(w,p,af,capability_id,x,E)
local t=aU(E)t.name=af
t.emit=aV(capability_id)t.data_type=x
t.write_type=t.write_type or x
t.endpoint=t.endpoint or 1
return H.cluster_attribute(w,p,t)
end
local function h(w,p,af,capability_id,x,E)
local t=aU(E)t.mfg_code=g
return j(w,p,af,capability_id,x,t)
end
local function u(p,af,capability_id,x,E)
return h(i,p,af,capability_id,x,E)
end
local function C(e)
return type(e)=="table"and e.value or e
end
local function J(aY)
return function(e)
return((tonumber(C(e))or 0)&(aY))~=0 and"active"or"clear"
end
end
local function N(aW)
local to={}for ba,e in pairs(aW)do to[e]=ba end
return function(e)return aW[tonumber(C(e))]end,
function(e)return to[e]end
end
local function W(e)
local y=tonumber(e)if y==nil then return nil end
return math.floor(y*2+0.5)/2
end
local function aI(e)
local y=math.floor(tonumber(e)or 0)if y<0 then y=y+65536 end
return string.char(y%256,math.floor(y/256)%256)
end
local function aj(f,w,p,ae)
H.read_attribute(f,w,p,1,ae)
end
local function G(f,w,aF,ae)
for _,p in ipairs(aF)do aj(f,w,p,ae)end
end
local function aT(f,aQ,aP)
for _,w in ipairs(aP)do
f:send(ac.build_bind_request(f,w,aQ,1))end
end
local function an(f,_,_,R)
return H.send_raw_cluster_command(f,L,0,aI(3),R.endpoint or 1,nil,nil,false)
end
local function Q(f,_,_,R)
return H.send_raw_cluster_command(f,a,3,"",R.endpoint or 1,nil,nil,false)
end
local aS={{"Sunday","sunday",1},{"Monday","monday",2},{"Tuesday","tuesday",4},{"Wednesday","wednesday",8},{"Thursday","thursday",16},{"Friday","friday",32},{"Saturday","saturday",64}}
local function z(f,V)
for _,day in ipairs(aS)do
H.send_raw_cluster_command(f,a,2,string.char(day[3],1),V or 1,nil,nil,true)end
end
local function aD(e)
local O={}for aq in string.gmatch(e,"%S+")do O[#O+1]=aq end
table.sort(O)return O
end
local function ah(aq)
local aA,aa,temperature=aq:match"^(%d%d):(%d%d)/(%d+%.?%d*)$"aA,aa,temperature=tonumber(aA),tonumber(aa),tonumber(temperature)if aA==nil or aa==nil or temperature==nil or aA>23 or aa>59
or temperature<1 or temperature>50 or temperature*2%1~=0 then
return nil
end
return aA*60+aa,math.floor(temperature*100+0.5)
end
local function ax(T)
return function(f,_,e,R)
if type(e)~="string"then return false end
local k=e==""and{}or aD(e)if #k>10 then return false end
local Z={string.char(#k,T,1)}for _,aq in ipairs(k)do
local o,l=ah(aq)if o==nil then return false end
Z[#Z+1]=aI(o)Z[#Z+1]=aI(l)end
local V=R.endpoint or 1
local aX=H.send_raw_cluster_command(f,a,1,table.concat(Z),V,nil,nil,false)if aX then z(f,V)end
return aX
end
end
local function ar(T)
return function(aJ)
local q=aJ and aJ.body and aJ.body.zcl_body or nil
local function C(e)
if type(e)=="table"and e.value~=nil then return tonumber(e.value)end
return tonumber(e)
end
local k,A,day,aH,ab={},q and C(q.number_of_transitions)or nil,q and C(q.day_of_week)or nil,q and C(q.mode)or nil,q and q.transitions_list or nil



if A==0 and ab==nil then ab={}end if A~=nil and day~=nil and aH~=nil and type(ab)=="table"then
if A%1~=0 or A<0 or A>10 or((day)&(T))==0
or((aH)&(1))==0 or A>#ab then return nil end
for ao=1,A do
local K=ab[ao]local o,l=K and C(K.transition_time)or nil,K and C(K.heat_set_point)or nil

if o==nil or o%1~=0 or o<0 or o>1439
or l==nil or l<100 or l>5000 then return nil end
k[#k+1]=string.format("%02d:%02d/%g",math.floor(o/60),o%60,l/100)end
else
local P=q and q.body_bytes or nil
if type(P)~="string"or #P<3 or((string.byte(P,2))&(T))==0 then return nil end
A=string.byte(P,1)aH=string.byte(P,3)if A>10 or((aH)&(1))==0 or #P<3+A*4 then return nil end
for ao=0,A-1 do
local ap=4+ao*4
local o,l=string.byte(P,ap)+string.byte(P,ap+1)*256,string.byte(P,ap+2)+string.byte(P,ap+3)*256

if l>=32768 then l=l-65536 end
if o>1439 or l<100 or l>5000 then return nil end
k[#k+1]=string.format("%02d:%02d/%g",math.floor(o/60),o%60,l/100)end
end
table.sort(k)return table.concat(k," ")
end
end
local c,M={},{}for _,item in ipairs{{12289,"emergency_overcurrent","EmergencyOvercurrent",4,i},{12289,"emergency_overheat","EmergencyOverheat",8,i},{12289,"emergency_no_load","EmergencyNoLoad",16,i}}do
d(c,u(item[1],"sber_therm_"..item[2],"sberTherm"..item[3],b.Bitmap16,{read_only=true,from_device=J(item[4]),read_on_configure=false}))end
for _,item in ipairs{{16642,"sensor_error_remote_disconnected","RemoteDisconnected",1},{16642,"sensor_error_local_disconnected","SensorLocalDisconnected",2},{16642,"sensor_error_short_circuit","SensorShortCircuit",4},{16643,"status_heat_inefficient","HeatInefficient",1},{16643,"status_antifrost","Antifrost",2},{16643,"status_invalid_time","InvalidTime",8}}do
d(c,h(a,item[1],"sber_therm_"..item[2],"sberTherm"..item[3],b.Bitmap16,{read_only=true,from_device=J(item[4]),read_on_configure=false}))end
local aC,aM=N{[0]="unlock",[1]="lock1"}d(c,j(v,1,"sber_therm_keypad_lockout","sberThermKeypadLockout",b.Enum8,{from_device=aC,to_device=aM,numeric_range=nil,read_on_configure=false}))d(c,H.cluster_attribute(a,18,{name="current_heating_setpoint",endpoint=1,emit=U.heating_setpoint"C",data_type=b.Int16,write_type=b.Int16,scale=100,to_device=W,numeric_range={minimum=1,maximum=50,step=0.5,unit="C"},read_on_configure=false}))d(c,H.cluster_attribute(a,0,{name="local_temperature",endpoint=1,read_only=true,emit=U.temperature"C",data_type=b.Int16,scale=100,read_on_configure=false}))local aE,aN=N{[0]="off",[4]="heat",[9]="asleep"}d(c,H.cluster_attribute(a,28,{name="system_mode",endpoint=1,emit=U.thermostat_mode(),data_type=b.Enum8,write_type=b.Enum8,from_device=aE,to_device=aN,read_on_configure=false}))d(c,H.cluster_attribute(a,41,{name="thermostat_operating_state",endpoint=1,read_only=true,emit=U.thermostat_operating_state(),data_type=b.Bitmap16,
from_device=function(e)return((tonumber(C(e))or 0)&(1))~=0 and"heating"or"idle"end,
read_on_configure=false}))d(c,j(a,16,"sber_therm_local_calibration","sber205Calibration",b.Int8,{scale=10,numeric_range={minimum=-10,maximum=10,step=0.5,unit="C"},read_on_configure=false}))local ay,aG=N{[2]="heating_only"}d(c,j(a,27,"sber_therm_control_sequence","sberThermControlSequence",b.Enum8,{from_device=ay,to_device=aG,read_on_configure=false}))
local ad=function(e)return({[0]="off",[4]="heat"})[tonumber(e)]end
d(c,j(a,30,"sber_therm_running_mode","sberThermRunningMode",b.Enum8,{read_only=true,from_device=ad,read_on_configure=false}))local ai,at=N{[0]="setpoint",[1]="schedule"}d(c,j(a,37,"sber_therm_programming_mode","sberThermProgrammingMode",b.Bitmap8,{from_device=ai,to_device=at,read_on_configure=false}))d(c,j(a,3,"sber_therm_abs_min_heat_limit","sberThermAbsMinHeatLimit",b.Int16,{read_only=true,scale=100,read_on_configure=false}))d(c,j(a,4,"sber_therm_abs_max_heat_limit","sberThermAbsMaxHeatLimit",b.Int16,{read_only=true,scale=100,read_on_configure=false}))d(c,j(a,21,"sber_therm_min_heat_limit","sberThermMinHeatLimit",b.Int16,{scale=100,to_device=W,numeric_range={minimum=1,maximum=35,step=0.5,unit="C"},read_on_configure=false}))d(c,j(a,22,"sber_therm_max_heat_limit","sberThermMaxHeatLimit",b.Int16,{scale=100,to_device=W,numeric_range={minimum=5,maximum=50,step=0.5,unit="C"},read_on_configure=false}))d(c,H.cluster_attribute(a,nil,{name="sber_therm_clear_schedule",endpoint=1,write_only=true,sender=Q}))M[#M+1]={capability_id=aw .."sberThermClearSchedule",command_name="clear",value=true,mapping_name="sber_therm_clear_schedule"}for ao,day in ipairs(aS)do
local af="sber_therm_"..day[2].."_schedule"d(c,H.cluster_attribute(a,61952+ao,{name=af,endpoint=1,emit=U["sberTherm"..day[1].."Schedule"]{allow_empty=true},read_only=false,data_type=b.CharString,write_type=b.CharString,sender=ax(day[3]),command_id=0,command_extractor=ar(day[3]),read_on_configure=false}))end
for _,field in ipairs{{16624,"min_local_temperature","MinLocalTemperature",b.Int16,100,1,35,0.01,"C"},{16625,"max_local_temperature","MaxLocalTemperature",b.Int16,100,5,50,0.01,"C"},{16409,"heating_hysteresis","HeatingHysteresis",b.Int8,10,1,10,0.1,"C"},{16385,"remote_temperature","RemoteTemperature",b.Int16,100,-273.15,327.67,0.01,"C"},{16386,"remote_calibration","RemoteCalibration",b.Int8,10,-12.8,12.7,0.1,"C"},{16899,"remote_sensor_timeout","RemoteSensorTimeout",b.Uint16,1,1,65535,1,"s"}}do
d(c,h(a,field[1],"sber_therm_"..field[2],"sberTherm"..field[3],field[4],{scale=field[5],numeric_range={minimum=field[6],maximum=field[7],step=field[8],unit=field[9]},read_on_configure=true}))end
local am,av=N{[0]="4p7K",[1]="6p8K",[2]="10K",[3]="12K",[4]="15K",[5]="33K",[6]="47K"}d(c,h(a,16641,"sber_therm_sensor_type","sberThermSensorType",b.Enum8,{from_device=am,to_device=av,read_on_configure=true}))local al,au=N{[0]="local",[1]="remote",[2]="both"}d(c,h(a,16387,"sber_therm_sensor_mode","sberThermSensorMode",b.Enum8,{from_device=al,to_device=au,read_on_configure=true}))local ag,as=N{[0]="normal",[1]="inverted"}d(c,h(a,16640,"sber_therm_output_mode","sberThermOutputMode",b.Enum8,{from_device=ag,to_device=as,read_on_configure=true}))d(c,j(m,0,"sber_therm_device_temperature","sberThermDeviceTemperature",b.Int16,{read_only=true,read_on_configure=false}))d(c,j(s,0,"sber_therm_wired_temperature","sberThermWiredTemperature",b.Int16,{read_only=true,scale=100,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}))d(c,H.cluster_attribute(i,16385,{name="voltage",endpoint=1,read_only=true,mfg_code=g,
data_type=b.Uint32,from_device=function(e)return e/1000 end,
emit=U.voltage(),read_on_configure=false}))d(c,H.cluster_attribute(i,16386,{name="current",endpoint=1,read_only=true,mfg_code=g,
data_type=b.Uint32,from_device=function(e)return e/1000 end,
emit=U.current(),read_on_configure=false}))d(c,H.cluster_attribute(i,16387,{name="power",endpoint=1,read_only=true,mfg_code=g,
data_type=b.Int32,from_device=function(e)return e/1000 end,
emit=U.power(),read_on_configure=false}))d(c,u(12307,"sber_therm_upper_current_threshold","sberThermUpperCurrentThreshold",b.Uint32,{numeric_range={minimum=100,maximum=16000,step=100,unit="mA"},read_on_configure=false}))d(c,u(12308,"sber_therm_temperature_threshold","sberThermTemperatureThreshold",b.Int16,{numeric_range={minimum=-200,maximum=200,step=1,unit="C"},read_on_configure=false}))d(c,h(v,8193,"sber_therm_brightness_operations","sberThermBrightnessOperations",b.Uint16,{numeric_range={minimum=0,maximum=1000,step=1},read_on_configure=true}))d(c,h(v,8194,"sber_therm_brightness_steady","sberThermBrightnessSteady",b.Uint16,{numeric_range={minimum=0,maximum=1000,step=1},read_on_configure=true}))d(c,H.cluster_attribute(L,nil,{name="sber_therm_identify",endpoint=1,write_only=true,sender=an}))M[#M+1]={capability_id=aw .."sberThermIdentify",command_name="identify",value=true,mapping_name="sber_therm_identify"}d(c,u(20481,"sber_therm_rtc_unavailable","sberThermRtcUnavailable",b.Bitmap16,{read_only=true,from_device=J(1),read_on_configure=false}))d(c,u(20481,"sber_therm_rtc_data_not_vaild","sberThermRtcDataNotVaild",b.Bitmap16,{read_only=true,from_device=J(2),read_on_configure=false}))d(c,j(X,13,"sber_therm_serial_number","sberThermSerialNumber",b.CharString,{
read_only=true,from_device=function(e)return tostring(e)end,read_on_configure=false
}))for _,field in ipairs{{0,"resets_count","ResetsCount",b.Uint16,nil},{4097,"uptime","Uptime",b.Uint32,g},{4098,"button_clicks_one","ButtonClicksOne",b.Uint32,g},{4099,"button_clicks_two","ButtonClicksTwo",b.Uint32,g},{4100,"button_clicks_three","ButtonClicksThree",b.Uint32,g},{4101,"relay_switches_one","RelaySwitchesOne",b.Uint32,g}}do
d(c,j(D,field[1],"sber_therm_"..field[2],"sberTherm"..field[3],field[4],{read_only=true,mfg_code=field[5],read_on_configure=false}))end
local function aK(aL,f)
aj(f,X,13)G(f,i,{16385,16386,16387,12289,12307,12308},g)aj(f,m,0)aj(f,s,0)G(f,a,{18,0,16,3,4,21,22,27,28,30})G(f,a,{32,33,34,37,41})G(f,a,{16385,16386,16409,16624,16625,16642,16643},g)aj(f,a,16899,g)aj(f,v,1)G(f,v,{8193,8194},g)aj(f,i,20481,g)z(f,1)aT(f,aL.environment_info.hub_zigbee_eui,{m,s,a,v,i})aT(f,aL.environment_info.hub_zigbee_eui,{D})
end
local ak={profile="thermostats-wave19-sber-sbdv-00205",package_group="wave19-thermostat-zcl",zcl_clusters=c,capability_commands=M,thermostat_supported_modes={"off","heat","asleep"},heating_setpoint_range={minimum=1,maximum=50,step=0.5,unit="C"},configure=aK}
ak.runtime_start=function(f)
f:emit_component_event({id="main"},Y.thermostatMode.supportedThermostatModes(ak.thermostat_supported_modes,{visibility={displayed=false}}))f:emit_component_event({id="main"},Y.thermostatHeatingSetpoint.heatingSetpointRange{value={minimum=ak.heating_setpoint_range.minimum,maximum=ak.heating_setpoint_range.maximum,step=ak.heating_setpoint_range.step},unit=ak.heating_setpoint_range.unit})
end
I(ak,{S.create_fingerprint("SDevices","SBDV-00205")})H.attach_reporting_capabilities(F,{{1,"rpt-sas"}})return{id="zcl.thermostats.wave19.sber",registrations=F}
