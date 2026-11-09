local g,f,q,w,c,p=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.capabilities",require"st.zigbee.data_types",require"st.zigbee.cluster_base"local t,u=q.definition_registry()local v,G,P,af={[0]="air","floor","air_floor","external","external_floor","floor_percent","regulator"},{[0]="always_on","10s","30s","60s"},{[0]="mon_fri_sat_sun","mon_sat_sun","no_time_off","time_off"},{[0]="er0","zigbee_error","bluetooth_error","internal_sensor_error","floor_sensor_error","external_sensor_error","overheat_error","overload_error"}
local function j(a)
if type(a)=="table"then return a.value end
return a
end
local function x(a)
local k=j(a)return bit32.band(k,4)~=0 and"eco"or bit32.band(k,1)~=0 and"schedule"or"setpoint"
end
local function z(b,o)
b:send(p.read_attribute(b,c.ClusterId(513),c.AttributeId(o)):to_endpoint(1))
end
local function F(b)
for N,V in pairs{[0]={16384,6},[513]={0,18,17,28,41,16,8,37,3,4,32768,32769,32770,32771,32772,32773,32774,32775,32778,32779,32785,32786,32787,32797,32799,32800,32801,32802,32803,32804,32805,32809},[516]={0,1},[1794]={0,769,770},[2820]={1291,1288,1540,1541}}do
for _,o in ipairs(V)do
b:send(p.read_attribute(b,c.ClusterId(N),c.AttributeId(o)):to_endpoint(1))end
end
end
local function l(b,o,T,s,M)
if s then z(b,o)end
local U=p.write_attribute(b,c.ClusterId(513),c.AttributeId(o),T):to_endpoint(1)U.body.zcl_header.frame_ctrl:unset_disable_default_response()b:send(U)if M then
b.thread:call_with_delay(1,function()
for _,attr in ipairs(M)do z(b,attr)end
end)
end
end
local function r(b,s)
local Y=os.time()+(b:get_field"nam_edge_time_zone"or 0)*3600
l(b,32779,c.Uint32(Y),s)l(b,32778,c.Boolean(false),s)z(b,32779)return true
end
local function e(b,name,a,i)
if i then
for _,R in ipairs(i.zb_rx.body.zcl_body.attr_records or{})do
if R.data then
local attr,k=R.attr_id.value,j(R.data)local item,state
if attr==28 then item,state="system_mode",({[0]="off",[3]="cool",[4]="heat"})[k]elseif attr==37 then item,state="programming_operation_mode",x(k)elseif attr==32769 then item,state="frost",(k==true or k==1)and"ON"or"OFF"elseif attr==32772 then item,state="sensor_mode",v[k]elseif attr==32799 then item,state="vacation_mode",(k==true or k==1)and"ON"or"OFF"elseif attr==32803 then item,state="countdown_set",k*5 end
if item and state~=nil then b:set_field("nam_edge_"..item,state,{persist=true})end
end
end
end
if a==nil then return nil end
b:set_field("nam_edge_"..name,a,{persist=true})local K="manual"if b:get_field"nam_edge_frost"=="ON"then K="frost"elseif b:get_field"nam_edge_vacation_mode"=="ON"then K="holiday"elseif b:get_field"nam_edge_sensor_mode"=="regulator"then K="regulator"elseif(b:get_field"nam_edge_countdown_set"or 0)>0 then K="countdown"elseif b:get_field"nam_edge_programming_operation_mode"=="schedule"then K="schedule"elseif b:get_field"nam_edge_programming_operation_mode"=="eco"then K="eco"end
b:emit_component_event({id="main"},f.namEdgeThermostatMode()(b,K))return a
end
local function d(b,C,a,i)
local Z=g.mapping_meta(C)local attr=Z.attribute_id
if attr==32772 and a=="regulator"and b:get_field"nam_edge_system_mode"=="cool"then return false end
if attr==32803 and b:get_field"nam_edge_system_mode"=="cool"then return false end
local O=a
if Z.to_device then O=Z.to_device(a,b,i,C)end
if O==nil then return false end
local ag=attr==32768 or attr==32769 or attr==32772 or attr==32773 or
attr==32799 or attr==32800 or attr==32801 or attr==32802 or attr==32803 or attr==32809
local ai=attr==32772 and{32772,32797,32775}or
(attr==32773 or attr==32809)and{attr}or nil
l(b,attr,Z.data_type(O),ag,ai)if attr==32769 then e(b,"frost",a)elseif attr==32799 then e(b,"vacation_mode",a)elseif attr==32803 then e(b,"countdown_set",a)elseif attr==32787 or attr==32805 then
local X=math.floor((a*9/5+32)*10+0.5)/10
l(b,attr==32787 and 32795 or 32806,c.Int16(math.floor(X*(attr==32787 and 100 or 10)+0.5)))end
return true
end
local function n(a)
local k=j(a)if k==0 then return nil end
return os.date("!%Y-%m-%d",k*86400)
end
local function B(a)
local L,E,day=a:match"^(%d%d%d%d)%-(%d%d)%-(%d%d)$"if L==nil then return nil end
L,E,day=tonumber(L),tonumber(E),tonumber(day)if E<1 or E>12 or day<1 or day>31 then return nil end
L=L-(E<=2 and 1 or 0)local ak=math.floor(L/400)local y=L-ak*400
local ab=ak*146097+y*365+math.floor(y/4)-math.floor(y/100)+
math.floor((153*(E+(E>2 and-3 or 9))+2)/5)+day-1-719468
return ab>0 and n(ab)==a and ab or nil
end
local function m(a,b)
if b:get_field"nam_edge_display_unit"~="fahrenheit"then return nil end
return math.floor(((j(a)/100-32)*5/9)*10+0.5)/10
end
local function Q(rx,b)
local H=rx.body.zcl_body.body_bytes
if type(H)~="string"or #H~=32 then return nil end
local I={}for D=1,29,4 do
local A=(bit32.band(H:byte(D+2),15)*256+H:byte(D+3))/10
if b:get_field"nam_edge_display_unit"=="fahrenheit"then
A=math.floor((A-32)*5/9*2+0.5)/2
end
I[#I+1]=string.format("%02d:%02d %g",H:byte(D),H:byte(D+1),A)end
b:emit_component_event({id="main"},f.namEdgeWeekSchedule()(b,"Work days: "..table.concat(I,", ",1,6).." | Days off: "..table.concat(I,", ",7,8)))
end
local S={profile="thermostats-namron-edge",thermostat_supported_modes={"off","heat","cool"},heating_setpoint_range={minimum=5,maximum=35,step=0.5,unit="C"},cooling_setpoint_range={minimum=10,maximum=40,step=0.5,unit="C"},
runtime_start=function(b)
b:emit_component_event({id="main"},w.thermostatMode.supportedThermostatModes{"off","heat","cool"})b:emit_component_event({id="main"},w.thermostatHeatingSetpoint.heatingSetpointRange{value={minimum=5,maximum=35,step=0.5},unit="C"})b:emit_component_event({id="main"},w.thermostatCoolingSetpoint.coolingSetpointRange{value={minimum=10,maximum=40,step=0.5},unit="C"})b:emit_component_event({id="main"},f.namEdgeTimeZone()(b,b:get_field"nam_edge_time_zone"or 0))F(b)
end,
protocol_writers={
nam_edge_time_zone=function(b,D)
b:set_field("nam_edge_time_zone",D,{persist=true})return r(b,true)
end
},zcl_clusters={g.switch{endpoint=1,configure_reporting=true,minimum_interval=0,maximum_interval=65000},g.local_temperature{endpoint=1,read_only=true,minimum_interval=10,maximum_interval=300,reportable_change=10},g.heating_setpoint{endpoint=1,minimum_interval=10,maximum_interval=300,reportable_change=50,
to_device=function(a)return math.max(5,math.min(35,math.floor(a*2+0.5)/2))end
},g.cooling_setpoint{endpoint=1,minimum_interval=10,maximum_interval=300,reportable_change=50,
to_device=function(a)return math.max(10,math.min(40,math.floor(a*2+0.5)/2))end
},g.thermostat_system_mode{endpoint=1,name="system_mode",emit=f.thermostat_mode(),read_on_configure=true,
from_device=function(a,b,i)
return e(b,"system_mode",({[0]="off",[3]="cool",[4]="heat"})[j(a)],i)
end,
sender=function(b,C,a)
if a=="cool"and b:get_field"nam_edge_sensor_mode"=="regulator"then return false end
local k=({off=0,cool=3,heat=4})[a]if k==nil then return false end
l(b,28,c.Enum8(k))e(b,"system_mode",a)return true
end
},g.thermostat_running_state{endpoint=1,name="thermostat_operating_state",read_only=true,read_on_configure=true,emit=f.thermostat_operating_state(),
from_device=function(a)
local k=j(a)return bit32.band(k,1)~=0 and"heating"or bit32.band(k,2)~=0 and"cooling"or"idle"
end
},g.humidity{endpoint=1,read_only=true,minimum_interval=10,maximum_interval=300,reportable_change=100},g.cluster_attribute(2820,1291,{endpoint=1,name="power",emit=f.power(),data_type=c.Int16,metering_kind="power",scale=1,read_only=true,read_on_configure=true}),g.cluster_attribute(2820,1288,{endpoint=1,name="current",emit=f.current(),data_type=c.Uint16,metering_kind="current",scale=1,read_only=true,read_on_configure=true}),g.cluster_attribute(1794,0,{endpoint=1,name="energy",emit=f.energy(),data_type=c.Uint48,metering_kind="energy",scale=1,read_only=true,read_on_configure=true}),g.cluster_attribute(513,16,{endpoint=1,name="nam_edge_temperature_calibration",emit=f.namEdgeTemperatureCalibration(),data_type=c.Int8,read_on_configure=true,
from_device=function(a)return a/10 end,
to_device=function(a)return math.floor(a*10+0.5)end
}),g.cluster_attribute(513,8,{endpoint=1,name="nam_edge_pi_heating_demand",emit=f.namEdgePiHeatingDemand(),data_type=c.Uint8,read_only=true,read_on_configure=true,
from_device=function(a)return a*100/255 end
}),g.cluster_attribute(513,37,{endpoint=1,name="nam_edge_programming_operation_mode",emit=f.namEdgeProgrammingOperationMode(),data_type=c.Bitmap8,read_on_configure=true,
from_device=function(a,b,i)return e(b,"programming_operation_mode",x(a),i)end,
sender=function(b,C,a)
if a~="eco"then g.send_raw_cluster_command(b,513,8,string.char(0),1)end
l(b,32799,c.Boolean(false),true)e(b,"vacation_mode","OFF")if a=="eco"then g.send_raw_cluster_command(b,513,8,string.char(1),1)else g.send_raw_cluster_command(b,513,7,string.char(a=="schedule"and 1 or 0),1)end
e(b,"programming_operation_mode",a)return true
end
}),g.cluster_attribute(513,32768,{endpoint=1,name="nam_edge_window_open_check",emit=f.namEdgeWindowOpenCheck(),data_type=c.Boolean,read_on_configure=true,sender=d,
from_device=function(a)return(a==true or a==1)and"ON"or"OFF"end,
to_device=function(a)return a=="ON"end
}),g.cluster_attribute(513,32769,{endpoint=1,name="nam_edge_frost",emit=f.namEdgeFrost(),data_type=c.Boolean,read_on_configure=true,sender=d,
from_device=function(a,b,i)return e(b,"frost",(a==true or a==1)and"ON"or"OFF",i)end,
to_device=function(a)return a=="ON"end
}),g.cluster_attribute(513,32770,{endpoint=1,name="nam_edge_window_state",emit=f.namEdgeWindowState(),data_type=c.Boolean,read_on_configure=true,read_only=true,
from_device=function(a)return(a==true or a==1)and"open"or"closed"end
}),g.cluster_attribute(513,32772,{endpoint=1,name="nam_edge_sensor_mode",emit=f.namEdgeSensorMode(),data_type=c.Enum8,read_on_configure=true,sender=d,suppress_optimistic_state=true,
from_device=function(a,b,i)return e(b,"sensor_mode",v[j(a)],i)end,
to_device=function(a)for k,name in pairs(v)do if a==name then return k end end end
}),g.cluster_attribute(513,32773,{endpoint=1,name="nam_edge_panel_brightness",emit=f.namEdgePanelBrightness(),data_type=c.Uint8,read_on_configure=true,sender=d}),g.cluster_attribute(513,32774,{endpoint=1,name="nam_edge_fault",emit=f.namEdgeFault(),data_type=c.Bitmap32,read_on_configure=true,read_only=true,
from_device=function(a)
local W,k={},j(a)for aj=0,7 do if bit32.band(k,2 ^ aj)~=0 then W[#W+1]=af[aj]end end
return #W>0 and table.concat(W,",")or"none"
end
}),g.cluster_attribute(513,32775,{endpoint=1,name="nam_edge_regulator_cycle",emit=f.namEdgeRegulatorCycleStatus(),data_type=c.Uint8,read_on_configure=true,read_only=true}),g.cluster_attribute(513,32771,{endpoint=1,name="nam_edge_week_program",emit=f.namEdgeWeekProgram(),data_type=c.Enum8,read_on_configure=true,read_only=true,poll_interval=900,
from_device=function(a)return P[j(a)]end
}),g.cluster_attribute(513,32778,{endpoint=1,name="nam_edge_auto_time_pending",emit=f.namEdgeAutoTimePending(),data_type=c.Boolean,read_only=true,read_on_configure=true,
from_device=function(a)return(j(a)==true or j(a)==1)and"ON"or"OFF"end,
handler=function(b,a)
if a=="ON"then r(b,false);z(b,32778)end
end
}),g.cluster_attribute(513,32779,{endpoint=1,name="nam_edge_clock_last_synced",emit=f.namEdgeClockLastSynced(),data_type=c.Uint32,read_only=true,read_on_configure=true,
from_device=function(a)return os.date("!%Y-%m-%d %H:%M:%S",a)end
}),g.cluster_attribute(513,32787,{endpoint=1,name="nam_edge_holiday_temp_set",emit=f.namEdgeHolidayTempSet(),data_type=c.Int16,read_on_configure=true,sender=d,
from_device=function(a)return a/100 end,
to_device=function(a)return math.floor(a*100+0.5)end
}),g.cluster_attribute(513,32797,{endpoint=1,name="nam_edge_regulator_percentage",emit=f.namEdgeRegulatorPercentage(),data_type=c.Int16,read_on_configure=true,sender=d}),g.cluster_attribute(513,32799,{endpoint=1,name="nam_edge_vacation_mode",emit=f.namEdgeVacationMode(),data_type=c.Boolean,read_on_configure=true,sender=d,
from_device=function(a,b,i)return e(b,"vacation_mode",(a==true or a==1)and"ON"or"OFF",i)end,
to_device=function(a)return a=="ON"end
}),g.cluster_attribute(513,32800,{endpoint=1,name="nam_edge_vacation_start",emit=f.namEdgeVacationStart(),data_type=c.Uint32,read_on_configure=true,sender=d,from_device=n,to_device=B}),g.cluster_attribute(513,32801,{endpoint=1,name="nam_edge_vacation_end",emit=f.namEdgeVacationEnd(),data_type=c.Uint32,read_on_configure=true,sender=d,from_device=n,to_device=B}),g.cluster_attribute(513,32802,{endpoint=1,name="nam_edge_auto_time",emit=f.namEdgeAutoTime(),data_type=c.Boolean,read_on_configure=true,sender=d,
from_device=function(a)return(a==true or a==1)and"ON"or"OFF"end,
to_device=function(a)return a=="ON"end
}),g.cluster_attribute(513,32803,{endpoint=1,name="nam_edge_countdown_set",emit=f.namEdgeCountdownSet(),data_type=c.Enum8,read_on_configure=true,sender=d,
from_device=function(a,b,i)return e(b,"countdown_set",j(a)*5,i)end,
to_device=function(a)return a/5 end
}),g.cluster_attribute(513,32804,{endpoint=1,name="nam_edge_countdown_left",emit=f.namEdgeCountdownLeft(),data_type=c.Uint32,read_on_configure=true,read_only=true,
from_device=function(a)return a>120 and 0 or a end
}),g.cluster_attribute(513,32805,{endpoint=1,name="nam_edge_max_heat_temp",emit=f.namEdgeMaxHeatTemp(),data_type=c.Int16,read_on_configure=true,sender=d,
from_device=function(a)return a/10 end,
to_device=function(a)return math.floor(a*10+0.5)end
}),g.cluster_attribute(513,32809,{endpoint=1,name="nam_edge_screen_on_time",emit=f.namEdgeScreenOnTime(),data_type=c.Enum8,read_on_configure=true,sender=d,
from_device=function(a)return G[j(a)]end,
to_device=function(a)for k,name in pairs(G)do if a==name then return k end end end
}),g.cluster_attribute(513,65535,{endpoint=1,name="nam_edge_sync_time",write_only=true,suppress_optimistic_state=true,
sender=function(b)return r(b,true)end
}),g.cluster_attribute(516,0,{endpoint=1,name="nam_edge_temperature_display_mode",emit=f.namEdgeTemperatureDisplayMode(),data_type=c.Enum8,read_on_configure=true,
from_device=function(a,b)
local ac=({[0]="celsius",[1]="fahrenheit"})[j(a)]if ac then b:set_field("nam_edge_display_unit",ac,{persist=true})end
return ac
end,
to_device=function(a)return({celsius=0,fahrenheit=1})[a]end,
sender=function(b,C,a)
local k=({celsius=0,fahrenheit=1})[a]b:send(p.write_attribute(b,c.ClusterId(516),c.AttributeId(0),c.Enum8(k)):to_endpoint(1))b:set_field("nam_edge_display_unit",a,{persist=true})return true
end
}),g.cluster_attribute(516,1,{endpoint=1,name="nam_edge_keypad_lockout",emit=f.namEdgeKeypadLockout(),data_type=c.Enum8,read_on_configure=true,
from_device=function(a)return({[0]="UNLOCK",[1]="LOCK"})[j(a)]end,
to_device=function(a)return({UNLOCK=0,LOCK=1})[a]end
}),g.cluster_attribute(0,16384,{endpoint=1,name="nam_edge_firmware_version",emit=f.namEdgeFirmwareVersion(),data_type=c.CharString,read_on_configure=true,read_only=true}),g.cluster_attribute(0,6,{endpoint=1,name="nam_edge_firmware_date",emit=f.namEdgeFirmwareDate(),data_type=c.CharString,read_on_configure=true,read_only=true}),g.cluster_attribute(513,3,{endpoint=1,name="nam_edge_abs_min_heat",emit=f.namEdgeAbsMinHeat(),
data_type=c.Int16,read_only=true,read_on_configure=true,from_device=function(a)return a>=-27315 and a/100 or nil end}),
g.cluster_attribute(513,4,{endpoint=1,name="nam_edge_abs_max_heat",emit=f.namEdgeAbsMaxHeat(),
data_type=c.Int16,read_only=true,read_on_configure=true,from_device=function(a)return a>=-27315 and a/100 or nil end}),
g.cluster_attribute(513,32785,{endpoint=1,name="heating_setpoint_f",emit=f.heating_setpoint(),data_type=c.Int16,read_only=true,read_on_configure=true,from_device=m}),g.cluster_attribute(513,32786,{endpoint=1,name="temperature_f",emit=f.temperature(),data_type=c.Int16,read_only=true,read_on_configure=true,from_device=m}),g.cluster_attribute(57346,nil,{endpoint=1,name="nam_edge_week_schedule",emit=f.namEdgeWeekSchedule(),command_id=7,command_extractor=Q,read_only=true,read_on_configure=false})},
configure=function(ah,b)
for _,N in ipairs{6,10,513,516,1029,1794,2820}do
g.bind_cluster(b,N,ah.environment_info.hub_zigbee_eui,1)end
F(b)
end
}u(S,{q.create_fingerprint("Namron AS","4566702"),q.create_fingerprint("Namron AS","4512783")})g.attach_reporting_capabilities(t,{{1,"rpt-zps"}})return{id="zcl.thermostats.namron_edge",registrations=t}
