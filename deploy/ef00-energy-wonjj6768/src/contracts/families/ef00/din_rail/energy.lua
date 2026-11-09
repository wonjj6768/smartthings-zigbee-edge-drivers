local b,a,e,aG=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00_din_rail"local ao,c=e.definition_registry()local d,g,j,z,aI,aH,ag,i,l=b.converter,aG.emit_metric_bundle,aG.circuit_breaker_faults_converter,aG.BREAKER_EVENT_LOOKUP,a.voltage(),a.current(),a.power(),{ignore=0,alarm=1,trip=2},{closed=0,alarm=1,trip=2}



local w={profile="din-rail-switch-power-energy-voltage-current-din1",package_group="energy",b.dp_energy(1,{emit=a.energy(),scale=100}),b.dp_phase_variant1(6,{emit=g{voltage=true,current=true}}),b.dp_on_off(16,{name="switch",emit=a.switch()}),b.dp_numeric(101,{name="total_energy",scale=100,read_only=true,emit=a.din1TotalEnergy()}),b.dp_energy(102,{name="produced_energy",scale=100,emit=a.producedEnergyDin()}),b.dp_power(103,{emit=a.power()}),b.dp_ac_frequency(105,{scale=100,read_only=true,emit=a.din1AcFrequency()}),b.dp_numeric(109,{name="energy_reactive",scale=100,read_only=true,emit=a.din1EnergyReactive()}),b.dp_numeric(110,{name="power_reactive",emit=a.reactivePowerDin1()}),b.dp_power_factor(111,{scale=10,read_only=true,emit=a.din1PowerFactor()}),b.dp_numeric(9,{name="faults",read_only=true,emit=a.din1Faults(),converter=j}),b.dp_raw(17,{name="alarm_set_1"}),b.dp_raw(18,{name="alarm_set_2"})}c(w,e.create_fingerprints("TS0601",{"_TZE200_bkkmqmyo","_TZE200_eaac7dkw","_TZE204_bkkmqmyo"}))c(w,{e.create_fingerprint("Hiking","DDS238-2"),e.create_fingerprint("Tuya","RC-MCB")})local x={profile="din-rail-switch-power-energy-voltage-current-din2",package_group="energy",b.dp_energy(1,{emit=a.energy(),scale=100}),b.dp_numeric(3,{name="monthly_energy"}),b.dp_numeric(4,{name="daily_energy"}),b.dp_phase_variant2(6,{emit=g{voltage=true,current=true,power=true}}),b.dp_enum(10,{name="fault",read_only=true,emit=a.din2Fault(),converter=d.from_only(d.lookup_value{[0]="clear",[1]="over_current_threshold",[2]="over_power_threshold",[4]="over_voltage_threshold",[8]="wrong_frequency_threshold"})}),b.dp_raw(11,{name="frozen"}),b.dp_on_off(16,{name="switch",emit=a.switch()}),b.dp_threshold(17,{}),b.dp_string(18,{name="meter_id",read_only=true,emit=a.din2MeterId()}),b.dp_on_off(20,{name="clear_fault",emit=a.clearFaultDin2(),converter=d.lookup_from_to{on=true,off=false}}),b.dp_numeric(21,{name="forward_energy_t1"}),b.dp_numeric(22,{name="forward_energy_t2"}),b.dp_numeric(23,{name="forward_energy_t3"}),b.dp_numeric(24,{name="forward_energy_t4"})}c(x,e.create_fingerprints("TS0601",{"_TZE200_lsanae15","_TZE204_l6llgoxq","_TZE204_lsanae15"}))c(x,{e.create_fingerprint("MatSee Plus","DAC2161C")})local y={profile="din-rail-switch-power-energy-voltage-current-din3",package_group="energy",b.dp_energy(1,{emit=a.energy(),scale=100}),b.dp_energy(2,{name="produced_energy",scale=100,emit=a.producedEnergyDin()}),b.dp_numeric(3,{name="monthly_energy"}),b.dp_numeric(4,{name="daily_energy"}),b.dp_phase_variant2(6,{emit=g{voltage=true,current=true,power=true}}),b.dp_enum(10,{name="fault",read_only=true,emit=a.din3Fault(),converter=d.from_only(d.lookup_value{[0]="clear",[1]="over_current_threshold",[2]="over_power_threshold",[4]="over_voltage_threshold",[8]="wrong_frequency_threshold"})}),b.dp_raw(11,{name="frozen"}),b.dp_on_off(16,{name="switch",emit=a.switch()}),b.dp_threshold(17,{}),b.dp_string(18,{name="meter_id",read_only=true,emit=a.din3MeterId()}),b.dp_on_off(20,{name="clear_fault",emit=a.clearFaultDin3(),converter=d.lookup_from_to{on=true,off=false}}),b.dp_numeric(21,{name="forward_energy_t1"}),b.dp_numeric(22,{name="forward_energy_t2"}),b.dp_numeric(23,{name="forward_energy_t3"}),b.dp_numeric(24,{name="forward_energy_t4"})}c(y,e.create_fingerprints("TS0601",{"_TZE200_rhblgy0z","_TZE204_rhblgy0z"}))c(y,{e.create_fingerprint("XOCA","DAC2161C")})local J={package_group="energy",b.dp_energy(1,{emit=a.energy(),scale=100}),b.dp_phase_variant2(6,{emit=g{voltage=true,current=true,power=true}}),b.dp_on_off(16,{name="switch",emit=a.switch()})}c(J,e.create_fingerprints("TS0601",{"_TZE200_byzdayie","_TZE200_ewxhg6o9","_TZE200_fsb6zw01"}))local S={profile="din-rail-switch-power-energy-voltage-current-din4",package_group="energy",b.dp_energy(1,{emit=a.energy(),scale=100}),b.dp_phase_variant2(6,{emit=g{voltage=true,current=true,power=true}}),b.dp_numeric(9,{name="faults",read_only=true,emit=a.din4Faults(),converter=j}),b.dp_binary(12,{name="clear_energy",emit=a.din4ClearEnergy(),converter=d.lookup_from_to{off=false,on=true}}),b.dp_numeric(15,{name="leakage",read_only=true,emit=a.din4Leakage()}),b.dp_on_off(16,{name="switch",emit=a.switch()}),b.dp_numeric(102,{name="reclosing_allowed_times",emit=a.din4ReclosingTimes()}),b.dp_temperature(103,{name="temperature",scale=1,read_only=true,emit=a.din4Temperature()}),b.dp_binary(104,{name="reclosing_enable",emit=a.din4ReclosingEnable(),converter=d.lookup_from_to{off=false,on=true}}),b.dp_numeric(105,{name="timer",emit=a.din4Timer()}),b.dp_enum(127,{name="status",read_only=true,emit=a.din4Status(),converter=d.from_only(d.lookup_value{[0]="standby",[1]="active"})}),b.dp_power_on_behavior(134,{emit=a.din4PowerOnBehavior()})}c(S,e.create_fingerprints("TS0601",{"_TZE200_abatw3kj","_TZE204_4bjixefp","_TZE204_fhvdgeuh"}))local I={profile="din-rail-switch-power-energy-voltage-current-leakage-protector",package_group="energy",query_on_configure=true,named_datapoints=true,datapoints={b.dp_on_off(1,{name="switch",component="main",emit=a.switch()}),b.dp_energy(17,{emit=a.energy(),scale=100}),b.dp_current(18,{emit=a.current(),scale=100}),b.dp_power(19,{emit=a.power(),scale=10}),b.dp_voltage(20,{emit=a.voltage(),scale=10}),b.dp_numeric(9,{name="faults",read_only=true,emit=a.smkg2knlFaults(),converter=j}),b.dp_numeric(41,{name="leakage_threshold",emit=a.leakageThresholdProtector100ma()}),b.dp_numeric(42,{name="over_voltage_threshold",emit=a.smkg2knlOverVoltageThreshold()}),b.dp_numeric(43,{name="under_voltage_threshold",emit=a.smkg2knlUnderVoltageThreshold()}),b.dp_numeric(44,{name="over_current_threshold",emit=a.smkg2knlOverCurrentThreshold()}),b.dp_numeric(45,{name="temperature_threshold",emit=a.smkg2knlTemperatureThreshold()}),b.dp_temperature(47,{name="temperature",scale=1,read_only=true,emit=a.temperature()}),b.dp_numeric(53,{name="leakage_current",emit=a.leakageCurrentProtector()})}}c(I,e.create_fingerprints("TS0601",{"_TZE284_5m4nchbm"}))local ad=a.zjsbl7Trip()local k={profile="din-rail-switch-power-energy-voltage-current-rcbo",package_group="energy",capability_commands={{capability_id="concertmirror08464.zjsbl7ClearData",command_name="clearData",mapping_name="clear_device_data",value=true},{capability_id="concertmirror08464.zjsbl7Trip",command_name="clearTrip",mapping_name="clear_trip",value=true}},datapoints={b.dp_on_off(1,{name="switch",emit=a.switch(),
handler=function(f,h)
if h==true then
f:set_field("trip","clear",{persist=true})f:emit_event(ad(f,"clear"))end
end
}),b.dp_numeric(9,{name="countdown_timer",emit=a.rcboCountdownTimer()}),b.dp_enum(26,{name="alarm",read_only=true,emit=a.rcboAlarm(),converter=d.from_only(d.lookup_value{[0]="clear",[1]="over_voltage_threshold",[2]="under_voltage_threshold",[4]="over_current_threshold",[8]="over_temperature_threshold",[10]="over_leakage_current_threshold",[16]="trip_test",[128]="safety_lock"})}),b.dp_power_on_behavior(27,{name="power_on_behavior",command_id=4,emit=a.rcboPowerOnBehavior(),converter=d.lookup_from_to{off=0,on=1,previous=2}}),b.dp_child_lock(29,{name="child_lock",emit=a.rcboChildLock(),converter=d.lookup_from_to{off=false,on=true}}),b.dp_raw(101,{name="voltage",read_only=true,converter=d.raw_uint_be(10,{length=2}),emit=aI}),b.dp_raw(102,{name="current",read_only=true,converter=d.raw_uint_be(1000,{start=2,length=2}),emit=aH}),b.dp_raw(103,{name="power",read_only=true,converter=d.raw_uint_be(10,{start=2,length=2}),emit=ag}),b.dp_temperature(105,{name="temperature",scale=1,read_only=true,emit=a.temperature()}),b.dp_energy(113,{emit=a.energy(),scale=100,read_only=true}),b.dp_string(114,{name="meter_number",read_only=true,emit=a.zjsbl7MeterNumber(),
from_device=function(h)return h:match"^%s*(.-)%s*$"end
}),b.dp_binary(115,{name="clear_device_data",write_only=true,command_id=4}),b.dp_binary(116,{name="trip",read_only=true,persist=true,emit=ad,converter=d.from_only(d.lookup_value{[true]="trip",[false]="clear"})}),b.dp_binary(116,{name="clear_trip",write_only=true,command_id=4}),b.dp_raw(118,{name="voltage_rms",read_only=true,converter=d.raw_uint_be(10,{length=2}),emit=a.zjsbl7VoltageRms()}),b.dp_raw(119,{name="current_average",read_only=true,converter=d.raw_uint_be(1000,{start=2,length=2}),emit=a.rcboCurrentAverage()})}}for phase=1,3 do
local aX=3*phase+2
local aV=d.raw_uint_be(10,{start=aX,length=2}).from
k.datapoints[#k.datapoints+1]=b.dp_raw(103,{name="power_l"..phase,component="l"..phase,read_only=true,emit=ag,
from_device=function(h)
if #h>=aX+1 then return aV(h)end
end
})end
for _,aW in ipairs{{109,{{"self_test_auto_days",a.zjsbl7SelfTestAutoDays(),1,1,0},{"self_test_auto_hours",a.zjsbl7SelfTestAutoHours(),1,1,0},{"self_test_auto",a.zjsbl7SelfTestAuto(),1,"flag","off"},{"over_leakage_current_threshold",a.zjsbl7OverLeakageThreshold(),2,1,30,10,100},{"over_leakage_current_trip",a.zjsbl7OverLeakageTrip(),1,"flag","off",true},{"over_leakage_current_alarm",a.zjsbl7OverLeakageAlarm(),1,"flag","off",true},{"self_test",a.zjsbl7SelfTest(),1,"test","clear"}}},{110,{{"over_voltage_threshold",a.zjsbl7OverVoltageThreshold(),2,10,280,200,300},{"over_voltage_trip",a.zjsbl7OverVoltageTrip(),1,"flag","off",true},{"over_voltage_alarm",a.zjsbl7OverVoltageAlarm(),1,"flag","off",true},{"under_voltage_threshold",a.zjsbl7UnderVoltageThreshold(),2,10,150,100,215},{"under_voltage_trip",a.zjsbl7UnderVoltageTrip(),1,"flag","off",true},{"under_voltage_alarm",a.zjsbl7UnderVoltageAlarm(),1,"flag","off",true}}},{111,{{"over_current_threshold",a.zjsbl7OverCurrentThreshold(),3,1000,63,1,100},{"over_current_trip",a.zjsbl7OverCurrentTrip(),1,"flag","off",true},{"over_current_alarm",a.zjsbl7OverCurrentAlarm(),1,"flag","off",true}}},{112,{{"over_temperature_threshold",a.zjsbl7OverTempThreshold(),1,"signed",80,30,100},{"over_temperature_trip",a.zjsbl7OverTempTrip(),1,"flag","off",true},{"over_temperature_alarm",a.zjsbl7OverTempAlarm(),1,"flag","off",true}}}}do
local dp,aJ,aK=aW[1],aW[2],">!1"for _,field in ipairs(aJ)do aK=aK.."I"..field[3]end
local aL=1
for _,field in ipairs(aJ)do
local A,aO=field[4],field[6]~=nil
local aV=d.raw_uint_be(type(A)=="number"and A or 1,{start=aL,length=field[3]}).from
k.datapoints[#k.datapoints+1]=b.dp_raw(dp,{name=field[1],emit=field[2],read_only=not aO,persist=true,command_id=4,suppress_optimistic_state=true,
from_device=function(h)
h=aV(h)if h==nil then return nil end
if A=="flag"then return h~=0 and"on"or"off"end
if A=="test"then return h~=0 and"test"or"clear"end
if A=="signed"and h>127 then return 128-h end
return h
end,
to_device=aO and function(h,f)
if A=="flag"then
if h~="on"and h~="off"then return nil end
elseif type(h)~="number"or h%1~=0 or h<field[6]or h>field[7]then
return nil
end
local aU={}for bg,M in ipairs(aJ)do
local s=M==field and h or f:get_field(M[1])if s==nil then s=M[5]end
if M[4]=="test"then s=0
elseif M[4]=="flag"then s=s=="on"and 1 or 0
elseif M[4]=="signed"then s=s<0 and 128-s or s
else s=math.floor(s*M[4]+0.5)end
aU[bg]=s
end
return string.pack(aK,table.unpack(aU))
end or nil
})aL=aL+field[3]end
end
c(k,{e.create_fingerprint("_TZE200_hkdl5fmv","TS0601"),e.create_fingerprint("_TZE284_hkdl5fmv","TS0601"),e.create_fingerprint("HOCH","ZJSBL7-100Z"),e.create_fingerprint("WDYK","ZJSBL7-100Z")})local ai=g{voltage=true,current=true}
local function ak(f,h,ah,aZ)
if type(h)~="table"then return nil end
local n=ai(f,h,ah,aZ)or{}if h.power~=nil then
local Y=ag(f,h.power)if Y[1]~=nil then
for _,aR in ipairs(Y)do n[#n+1]=aR end
else
n[#n+1]=Y
end
end
return #n>0 and n or nil
end
local O={profile="din-rail-switch-power-energy-voltage-current-toqjzt",package_group="energy",query_on_configure=true,respond_to_mcu_version_response=true,default_power_poll_interval_seconds=10,b.dp_energy(1,{emit=a.energy(),scale=100}),b.dp_phase_variant2(6,{emit=ak}),b.dp_numeric(13,{name="test1"}),b.dp_numeric(15,{name="leakage_current",emit=a.leakageCurrentToqJzt()}),b.dp_on_off(16,{name="switch",emit=a.switch()}),b.dp_ac_frequency(32,{name="ac_frequency",converter=d.signed_number_pair(1),read_only=true,emit=a.toqjztAcFrequencyV2()}),b.dp_power_factor(50,{name="power_factor",converter=d.signed_number_pair(1),read_only=true,emit=a.toqjztPowerFactorV2()}),b.dp_enum(102,{name="over_voltage_setting",emit=a.toqjztOverVoltageSetting(),converter=d.lookup_from_to(i)}),b.dp_enum(103,{name="under_voltage_setting",emit=a.toqjztUnderVoltageSetting(),converter=d.lookup_from_to(i)}),b.dp_enum(104,{name="over_current_setting",emit=a.toqjztOverCurrentSetting(),converter=d.lookup_from_to(i)}),b.dp_enum(105,{name="over_power_setting",emit=a.toqjztOverPowerSetting(),converter=d.lookup_from_to(i)}),b.dp_enum(107,{name="temperature_setting",emit=a.toqjztTemperatureSetting(),converter=d.lookup_from_to(i)}),b.dp_enum(108,{name="control_mode",emit=a.toqjztControlMode(),converter=d.lookup_from_to{local_lock=0,local_mode=1,remote_mode=2,full_control=3}}),b.dp_enum(110,{name="event",read_only=true,emit=a.toqjztEvent(),converter=d.from_only(d.lookup_value(z))}),b.dp_numeric(114,{name="over_current_threshold",emit=a.toqjztOverCurrentThreshold()}),b.dp_numeric(115,{name="over_voltage_threshold",emit=a.toqjztOverVoltageThreshold()}),b.dp_numeric(116,{name="under_voltage_threshold",emit=a.toqjztUnderVoltageThreshold()}),b.dp_temperature(118,{name="temperature_threshold",converter=d.signed_number_pair(10),signed=true,emit=a.toqjztTemperatureThreshold()}),b.dp_numeric(119,{name="over_power_threshold",emit=a.toqjztOverPowerThreshold()}),b.dp_numeric(125,{name="test5"}),b.dp_temperature(131,{name="temperature",converter=d.signed_number_pair(10),signed=true,read_only=true,emit=a.temperature()})}c(O,{e.create_fingerprint("_TZE284_6ocnqlhn","TS0601")})local ab={profile="din-rail-switch-power-energy-voltage-current-towsmr1",package_group="energy",b.dp_energy(1,{emit=a.energy(),scale=100}),b.dp_phase_variant2(6,{emit=g{voltage=true,current=true,power=true}}),b.dp_numeric(15,{name="leakage_current",read_only=true,emit=a.towsmr1LeakageCurrent()}),b.dp_on_off(16,{name="switch",emit=a.switch()}),b.dp_enum(102,{name="over_voltage_setting",emit=a.towsmr1OverVoltageSetting(),converter=d.lookup_from_to(i)}),b.dp_enum(103,{name="under_voltage_setting",emit=a.towsmr1UnderVoltageSetting(),converter=d.lookup_from_to(i)}),b.dp_enum(104,{name="over_current_setting",emit=a.towsmr1OverCurrentSetting(),converter=d.lookup_from_to(i)}),b.dp_enum(105,{name="over_power_setting",emit=a.towsmr1OverPowerSetting(),converter=d.lookup_from_to(i)}),b.dp_enum(107,{name="temperature_setting",emit=a.towsmr1TemperatureSetting(),converter=d.lookup_from_to(i)}),b.dp_enum(108,{name="leakage_setting",emit=a.towsmr1LeakageSetting(),converter=d.lookup_from_to(i)}),b.dp_enum(110,{name="event",read_only=true,emit=a.towsmr1Event(),converter=d.from_only(d.lookup_value(z))}),b.dp_on_off(112,{name="auto_reclosing",emit=a.towsmr1AutoReclosing(),converter=d.lookup_from_to{off=false,on=true}}),b.dp_on_off(113,{name="restore_default",emit=a.towsmr1RestoreDefault(),converter=d.lookup_from_to{off=false,on=true}}),b.dp_numeric(114,{name="over_current_threshold",emit=a.towsmr1OverCurrentThreshold()}),b.dp_numeric(115,{name="over_voltage_threshold",emit=a.towsmr1OverVoltageThreshold()}),b.dp_numeric(116,{name="under_voltage_threshold",emit=a.towsmr1UnderVoltageThreshold()}),b.dp_numeric(117,{name="leakage_threshold",emit=a.towsmr1LeakageThreshold()}),b.dp_temperature(118,{name="temperature_threshold",scale=10,emit=a.towsmr1TemperatureThreshold()}),b.dp_numeric(119,{name="over_power_threshold",emit=a.towsmr1OverPowerThreshold()}),b.dp_temperature(131,{name="temperature",scale=10,read_only=true,emit=a.temperature()}),b.dp_on_off(143,{name="overcurrent_recloser",emit=a.towsmr1OvercurrentRecloser(),converter=d.lookup_from_to{off=false,on=true}}),b.dp_on_off(144,{name="leakage_recloser",emit=a.towsmr1LeakageRecloser(),converter=d.lookup_from_to{off=false,on=true}}),b.dp_on_off(145,{name="overpower_recloser",emit=a.towsmr1OverpowerRecloser(),converter=d.lookup_from_to{off=false,on=true}})}
local function aC(h,_,ah)
if type(h)~="number"then return end
if ah and(ah.datatype==2 or ah.datatype==5)and ah.length==4 then
return ah.signed_value
end
return h
end
local function m(dp,name,aR,an,aD)
aD=aD or 1
return b.dp_numeric(dp,{name=name,emit=aR,read_only=an==false,signed=dp==118,
from_device=function(h,f,ah)
local aT=aC(h,f,ah)if aT~=nil then return aT/aD end
end,
to_device=an~=false and function(h)
if type(h)~="number"or h~=h or h==math.huge or h==-math.huge then return end
if an and(h<an[1]or h>an[2])then return end
return h*aD
end or nil
})
end
local aq=a.temperature()
local function aa(f,h)
if type(h)=="number"and h>=-460 and h<=10000 then
return aq(f,h)end
end
local aN,aj,av,aw,aB,q,p,H=require"st.zigbee.zcl.clusters".Basic,"towsmr1:native_sw_build_id","towsmr1:app_version","towsmr1:firmware_id","towsmr1:custom_firmware_id","towsmr1:native_probe",{persist=true},{persist=false}

local function t(f)
local h=f:get_field(aj)return type(h)=="string"and h~=""
end
local function towsmr_version(h)
return string.format("%d.%d.%d",h>>6,(h&48)>>4,h&15)
end
local function L(f,h,be)
f:set_field(aw,h,p)f:set_field(aB,be,p)
end
local function r(f,o)
if f:get_field(q)~=o then return end
f:set_field(q,nil,H)if o.timer then f.thread:cancel_timer(o.timer)end
if not t(f)then
return b.send_raw(f,16,"\x02\x00")end
end
local function au(_,f)
local at=f:get_field(q)if at then
f:set_field(q,nil,H)if at.timer then f.thread:cancel_timer(at.timer)end
end
b.send_magic_packet(f)b.send_state_request(f)if t(f)then return end
local o={}f:set_field(q,o,H)
o.timer=f.thread:call_with_delay(10,function()
if f:get_field(q)==o then
o.timer=nil
r(f,o)end
end,"TOWSMR1 native firmware read timeout")
local bj=pcall(f.send,f,aN.attributes.SWBuildID:read(f))if not bj then r(f,o)end
end
local function af(f,rx)
local ax,ay=rx.address_header,rx.body
local ae=ay and ay.zcl_header
if not ax or not ae or ax.src_endpoint.value~=1 then return end
if ae.frame_ctrl:is_mfg_specific_set()or not ae.frame_ctrl:is_direction_set()then return end
local aP,ac,am=ax.cluster.value,ae.cmd.value,ay.zcl_body
if aP==0 and not ae.frame_ctrl:is_cluster_specific_set()then
local o=f:get_field(q)if(ac==1 or ac==10)and type(am.attr_records)=="table"then
local V=false
for _,Z in ipairs(am.attr_records)do
local id,aQ,bf,h=Z.attr_id.value,not Z.status or Z.status.value==0,Z.data_type and Z.data_type.value,Z.data and Z.data.value



if id==1 and aQ and bf==32 and type(h)=="number"then
f:set_field(av,h,p)elseif id==16384 then
V=true
if aQ and bf==66 and type(h)=="string"and h~=""then
f:set_field(aj,h,p)L(f,h,false)end
end
end
if o and((ac==1 and(V or #am.attr_records==0))or(V and t(f)))then
r(f,o)end
elseif ac==11 and o and am.cmd and am.cmd.value==0
and am.status and am.status.value~=0 then
r(f,o)end
elseif aP==61184 and ae.frame_ctrl:is_cluster_specific_set()and ac==17 then
local az=am.body_bytes
if type(az)~="string"or #az~=3 or t(f)then return end
local bd,bi=f:get_field(av),az:byte(3)if type(bd)=="number"and bd~=0 and bi~=0 then
L(f,"Zigbee module: "..towsmr_version(bd)..", MCU module: "..towsmr_version(bi),true)end
end
end
local function K(f,A,F)
local aY=os.time()if A=="1970"then return b.send_time(f,aY,aY+F*3600)end
if A=="2000"then return b.send_time_with_offset(f,946684800,aY,aY+F*3600)end
return false
end
local aE,aA,aF=d.lookup_from_to{ignore=0,alarm=1,trip=2},d.lookup_from_to{off=false,on=true},d.from_only(d.lookup_value(z))
local function G(bb,aM,n,as,ba)
local function C(name)return aM.."_"..name end
local B,D=C"time_start",C"time_zone"
local function ar(dp,name)
return b.dp_enum(dp,{name=C(name),converter=aE,emit=n[name]})
end
local function al(dp,name)
return b.dp_on_off(dp,{name=C(name),converter=aA,emit=n[name]})
end
return{profile=bb,package_group="energy",default_power_poll_interval_seconds=10,configure=au,magic_packet=false,query_on_configure=false,mcu_version_request_on_configure=false,query_on_announce=false,refresh_state_query=true,time_start="off",
time_handler=function(f)
return K(f,f:get_field(B)or"off",f:get_field(D)or 0)
end,
protocol_writers={
[C"time_start"]=function(f,A)
if A~="off"and A~="1970"and A~="2000"then return false end
if A~="off"and not K(f,A,f:get_field(D)or 0)then return false end
f:set_field(B,A,p)return true
end,
[C"time_zone"]=function(f,F)
if type(F)~="number"or F~=F or F<-12 or F>14 or F*4~=math.floor(F*4)then return false end
local A=f:get_field(B)or"off"if A~="off"and not K(f,A,F)then return false end
f:set_field(D,F,p)return true
end
},
runtime_start=function(f)
f:emit_component_event({id="main"},n.time_start(f,f:get_field(B)or"off"))f:emit_component_event({id="main"},n.time_zone(f,f:get_field(D)or 0))
end,
force_time_updates=false,respond_to_mcu_version_response=false,zigbee_message_handler=af,m(1,"energy",a.energy(),false,100),b.dp_phase_variant2(6,{read_only=true,emit=g{voltage=true,current=true,power=true}}),m(15,C"leakage_current",n.leakage_current,false),b.dp_on_off(16,{name="switch",emit=a.switch()}),ar(102,"over_voltage_setting"),ar(103,"under_voltage_setting"),ar(104,"over_current_setting"),ar(105,"over_power_setting"),ar(107,"temperature_setting"),ar(108,"leakage_setting"),b.dp_enum(110,{name=C"event",read_only=true,converter=aF,emit=n.event}),al(112,"auto_reclosing"),al(113,"restore_default"),m(114,C"over_current_threshold",n.over_current_threshold,as and{1,as}or nil),m(115,C"over_voltage_threshold",n.over_voltage_threshold,{240,295}),m(116,C"under_voltage_threshold",n.under_voltage_threshold,{145,220}),m(117,C"leakage_threshold",n.leakage_threshold,ba and{30,100}or nil),m(118,C"temperature_threshold",n.temperature_threshold,{-25,100},10),m(119,C"over_power_threshold",n.over_power_threshold,{5,25000}),m(131,"temperature",aa,false,10),al(143,"overcurrent_recloser"),al(144,"leakage_recloser"),al(145,"overpower_recloser")}
end
local P=G("energy-towsmr1-20ac","towsmr20ac",{leakage_current=a.towsmr20AcLeakageCurrent(),event=a.towsmr20AcEvent(),time_start=a.towsmr20AcTimeStart(),time_zone=a.towsmr20AcTimeZone(),over_voltage_setting=a.towsmr20AcOverVoltageSetting(),over_voltage_threshold=a.towsmr20AcOverVoltageThreshold(),under_voltage_setting=a.towsmr20AcUnderVoltageSetting(),under_voltage_threshold=a.towsmr20AcUnderVoltageThreshold(),over_current_setting=a.towsmr20AcOverCurrentSetting(),over_current_threshold=a.towsmr20AcOverCurrentThreshold(),over_power_setting=a.towsmr20AcOverPowerSetting(),over_power_threshold=a.towsmr20AcOverPowerThreshold(),temperature_setting=a.towsmr20AcTemperatureSetting(),temperature_threshold=a.towsmr20AcTemperatureThreshold(),leakage_setting=a.towsmr20AcLeakageSetting(),leakage_threshold=a.towsmr20AcLeakageThreshold(),auto_reclosing=a.towsmr20AcAutoReclosing(),restore_default=a.towsmr20AcRestoreDefault(),overcurrent_recloser=a.towsmr20AcOvercurrentRecloser(),leakage_recloser=a.towsmr20AcLeakageRecloser(),overpower_recloser=a.towsmr20AcOverpowerRecloser()},20,true)c(P,e.create_fingerprints("TS0601",{"_TZE284_tuhfx7tf","_TZE204_tuhfx7tf"}))local Q=G("energy-towsmr1-40ac","towsmr40ac",{leakage_current=a.towsmr40AcLeakageCurrent(),event=a.towsmr40AcEvent(),time_start=a.towsmr40AcTimeStart(),time_zone=a.towsmr40AcTimeZone(),over_voltage_setting=a.towsmr40AcOverVoltageSetting(),over_voltage_threshold=a.towsmr40AcOverVoltageThreshold(),under_voltage_setting=a.towsmr40AcUnderVoltageSetting(),under_voltage_threshold=a.towsmr40AcUnderVoltageThreshold(),over_current_setting=a.towsmr40AcOverCurrentSetting(),over_current_threshold=a.towsmr40AcOverCurrentThreshold(),over_power_setting=a.towsmr40AcOverPowerSetting(),over_power_threshold=a.towsmr40AcOverPowerThreshold(),temperature_setting=a.towsmr40AcTemperatureSetting(),temperature_threshold=a.towsmr40AcTemperatureThreshold(),leakage_setting=a.towsmr40AcLeakageSetting(),leakage_threshold=a.towsmr40AcLeakageThreshold(),auto_reclosing=a.towsmr40AcAutoReclosing(),restore_default=a.towsmr40AcRestoreDefault(),overcurrent_recloser=a.towsmr40AcOvercurrentRecloser(),leakage_recloser=a.towsmr40AcLeakageRecloser(),overpower_recloser=a.towsmr40AcOverpowerRecloser()},40,true)c(Q,e.create_fingerprints("TS0601",{"_TZE204_kobbcyum","_TZE284_432zhuwe","_TZE204_432zhuwe"}))local U=G("energy-towsmr1-40a","towsmr40a",{event=a.towsmr40AEvent(),time_start=a.towsmr40ATimeStart(),time_zone=a.towsmr40ATimeZone(),over_voltage_setting=a.towsmr40AOverVoltageSetting(),over_voltage_threshold=a.towsmr40AOverVoltageThreshold(),under_voltage_setting=a.towsmr40AUnderVoltageSetting(),under_voltage_threshold=a.towsmr40AUnderVoltageThreshold(),over_current_setting=a.towsmr40AOverCurrentSetting(),over_current_threshold=a.towsmr40AOverCurrentThreshold(),over_power_setting=a.towsmr40AOverPowerSetting(),over_power_threshold=a.towsmr40AOverPowerThreshold(),temperature_setting=a.towsmr40ATemperatureSetting(),temperature_threshold=a.towsmr40ATemperatureThreshold(),auto_reclosing=a.towsmr40AAutoReclosing(),restore_default=a.towsmr40ARestoreDefault(),overcurrent_recloser=a.towsmr40AOvercurrentRecloser(),leakage_recloser=a.towsmr40ALeakageRecloser(),overpower_recloser=a.towsmr40AOverpowerRecloser()},40,false)c(U,e.create_fingerprints("TS0601",{"_TZE284_s5vuaadg"}))local R=G("energy-towsmr1-base","towsmr1base",{event=a.towsmr1BaseEvent(),time_start=a.towsmr1BaseTimeStart(),time_zone=a.towsmr1BaseTimeZone(),over_voltage_setting=a.towsmr1BaseOverVoltageSetting(),over_voltage_threshold=a.towsmr1BaseOverVoltageThreshold(),under_voltage_setting=a.towsmr1BaseUnderVoltageSetting(),under_voltage_threshold=a.towsmr1BaseUnderVoltageThreshold(),over_power_setting=a.towsmr1BaseOverPowerSetting(),over_power_threshold=a.towsmr1BaseOverPowerThreshold(),temperature_setting=a.towsmr1BaseTemperatureSetting(),temperature_threshold=a.towsmr1BaseTemperatureThreshold(),auto_reclosing=a.towsmr1BaseAutoReclosing(),restore_default=a.towsmr1BaseRestoreDefault(),overcurrent_recloser=a.towsmr1BaseOvercurrentRecloser(),leakage_recloser=a.towsmr1BaseLeakageRecloser(),overpower_recloser=a.towsmr1BaseOverpowerRecloser()},nil,false)c(R,e.create_fingerprints("TS0601",{"_TZE284_kobbcyum","_TZE284_hecsejsb"}))c(ab,{e.create_fingerprint("Tongou","TOWSMR1-40A-AC"),e.create_fingerprint("Tongou","TOWSMR1-40A-A"),e.create_fingerprint("Tongou","TOWSMR1-20A-AC")})local X={profile="din-rail-switch-power-energy-voltage-current-zbnjt63",package_group="energy",b.dp_energy(1,{emit=a.energy(),scale=100}),b.dp_numeric(3,{name="monthly_energy"}),b.dp_numeric(4,{name="daily_energy"}),b.dp_phase_variant3(6,{emit=g{voltage=true,current=true,power=true}}),b.dp_enum(10,{name="fault",read_only=true,emit=a.zbnjt63Fault(),converter=d.from_only(d.lookup_value{[0]="clear",[1]="ov_cr",[2]="unbalance_alarm",[4]="ov_vol",[8]="undervoltage_alarm",[16]="miss_phase_alarm",[32]="outage_alarm",[64]="magnetism_alarm",[128]="terminal_alarm",[256]="cover_alarm",[512]="credit_alarm",[1024]="no_balance_alarm",[2048]="battery_alarm",[4096]="meter_hardware_alarm"})}),b.dp_on_off(16,{name="switch",emit=a.switch()}),b.dp_raw(18,{name="meter_id",read_only=true,emit=a.zbnjt63MeterId(),converter=d.raw_identifier()}),b.dp_power_outage_memory(23,{name="power_outage_memory",emit=a.zbnjt63PowerOutageMemory(),converter=d.lookup_from_to{on=0,off=1,restore=2}})}c(X,e.create_fingerprints("TS0601",{"_TZE204_jcwbwckh"}))local T={profile="din-rail-switch-power-energy-voltage-current",package_group="energy",b.dp_on_off(1,{name="switch",emit=a.switch()}),b.dp_energy(17,{emit=a.energy(),scale=100}),b.dp_current(18,{emit=a.current(),scale=1000}),b.dp_power(19,{emit=a.power(),scale=10}),b.dp_voltage(20,{emit=a.voltage(),scale=10})}c(T,e.create_fingerprints("TS0601",{"_TZE204_byzdayie"}))local u={profile="din-rail-switch-power-energy-voltage-current-rmdzb1pnl63",package_group="energy",b.dp_energy(1,{emit=a.energy(),scale=100}),b.dp_phase_variant2(6,{signed_power=true,emit=g{voltage=true,current=true,power=true}}),b.dp_numeric(9,{name="faults",read_only=true,emit=a.rmdzb1pnl63Faults(),converter=j}),b.dp_on_off(16,{name="switch",emit=a.switch()}),b.dp_threshold(17,{}),b.dp_threshold(18,{}),b.dp_temperature(103,{name="temperature",scale=1,read_only=true,emit=a.temperature()})}c(u,e.create_fingerprints("TS0601",{"_TZE204_m64smti7"}))c(u,{e.create_fingerprint("TNCE","RMDZB-1PNL63")})local v={profile="din-rail-switch-power-energy-3phase-stb3l125zj",package_group="energy",b.dp_energy(1,{emit=a.energy(),scale=100}),b.dp_phase_variant2(6,{signed_power=true,phase="a",component="l1",emit=g{voltage=true,current=true,power=true}}),b.dp_phase_variant2(7,{signed_power=true,phase="b",component="l2",emit=g{voltage=true,current=true,power=true}}),b.dp_phase_variant2(8,{signed_power=true,phase="c",component="l3",emit=g{voltage=true,current=true,power=true}}),b.dp_numeric(9,{name="faults",read_only=true,emit=a.stb3l125zjFaults(),converter=j}),b.dp_on_off(16,{name="switch",emit=a.switch()}),b.dp_threshold(17,{}),b.dp_threshold(18,{}),b.dp_on_off(21,{name="leakage_test",emit=a.stb3l125zjLeakageTest(),converter=d.lookup_from_to{off=false,on=true}}),b.dp_temperature(102,{name="temperature",scale=10,read_only=true,emit=a.temperature()})}c(v,e.create_fingerprints("TS0601",{"_TZE200_wbhaespm","_TZE204_wbhaespm","_TZE284_wbhaespm"}))c(v,{e.create_fingerprint("SUTON","STB3L-125/ZJ")})local W={profile="din-rail-switch-power-energy-voltage-current-zbndj63",package_group="energy",b.dp_energy(1,{emit=a.energy(),scale=100}),b.dp_phase_variant2(6,{emit=g{voltage=true,current=true,power=true}}),b.dp_enum(9,{name="faults",read_only=true,emit=a.zbndj63Faults(),converter=d.from_only(d.lookup_value{[0]="clear",[1]="short_circuit_alarm",[2]="surge_alarm",[4]="overload_alarm",[8]="leakagecurr_alarm",[16]="temp_dif_fault",[32]="fire_alarm",[64]="high_power_alarm",[128]="self_test_alarm",[256]="ov_cr",[512]="unbalance_alarm",[1024]="ov_vol",[2048]="undervoltage_alarm",[4096]="miss_phase_alarm",[8192]="outage_alarm",[16384]="magnetism_alarm",[32768]="credit_alarm",[65536]="no_balance_alarm"})}),b.dp_on_off(11,{name="switch_prepayment",emit=a.zbndj63SwitchPrepayment(),converter=d.lookup_from_to{off=false,on=true}}),b.dp_on_off(12,{name="clear_energy",emit=a.zbndj63ClearEnergy(),converter=d.lookup_from_to{off=false,on=true}}),b.dp_energy(13,{name="balance_energy",scale=100,read_only=true,emit=a.zbndj63BalanceEnergy()}),b.dp_energy(14,{name="charge_energy",scale=100,emit=a.zbndj63ChargeEnergy()}),b.dp_numeric(15,{name="leakage_current",read_only=true,emit=a.zbndj63LeakageCurrent()}),b.dp_on_off(16,{name="switch",emit=a.switch()}),b.dp_threshold(17,{}),b.dp_threshold(18,{}),b.dp_numeric(102,{name="recover_count",emit=a.zbndj63RecoverCount()}),b.dp_temperature(103,{name="temperature",scale=1,read_only=true,emit=a.zbndj63Temperature()}),b.dp_on_off(104,{name="recover_enable",emit=a.zbndj63RecoverEnable(),converter=d.lookup_from_to{off=false,on=true}}),b.dp_numeric(105,{name="countdown",emit=a.zbndj63Countdown()}),b.dp_numeric(107,{name="leakage_delay",emit=a.zbndj63LeakageDelay()}),b.dp_energy(110,{name="reverse_energy",scale=100,read_only=true,emit=a.zbndj63ReverseEnergy()}),b.dp_numeric(119,{name="power_on_delay",emit=a.zbndj63PowerOnDelay()}),b.dp_numeric(124,{name="alarm_over_current_count"}),b.dp_numeric(125,{name="alarm_low_current_count"}),b.dp_numeric(127,{name="status"}),b.dp_numeric(134,{name="relay_power_on_state",emit=a.zbndj63RelayPowerOnState(),converter=d.lookup_from_to{off=0,on=1,restore=2}})}c(W,e.create_fingerprints("TS0601",{"_TZE204_lb0fsvba"}))local E={profile="din-rail-switch-power-energy-voltage-current-toqcb2",package_group="energy",b.dp_energy(1,{emit=a.energy(),scale=100}),b.dp_phase_variant2(6,{signed_power=true,phase="a",component="l1",emit=g{voltage=true,current=true,power=true}}),b.dp_phase_variant2(7,{signed_power=true,phase="b",component="l2",emit=g{voltage=true,current=true,power=true}}),b.dp_phase_variant2(8,{signed_power=true,phase="c",component="l3",emit=g{voltage=true,current=true,power=true}}),b.dp_on_off(16,{name="switch",emit=a.switch()}),b.dp_enum(102,{name="over_voltage_setting",emit=a.toqcb2OverVoltageSetting(),converter=d.lookup_from_to(l)}),b.dp_enum(103,{name="under_voltage_setting",emit=a.toqcb2UnderVoltageSetting(),converter=d.lookup_from_to(l)}),b.dp_enum(104,{name="over_current_setting",emit=a.toqcb2OverCurrentSetting(),converter=d.lookup_from_to(l)}),b.dp_enum(105,{name="over_power_setting",emit=a.toqcb2OverPowerSetting(),converter=d.lookup_from_to(l)}),b.dp_enum(107,{name="temperature_setting",emit=a.toqcb2TemperatureSetting(),converter=d.lookup_from_to(l)}),b.dp_enum(110,{name="last_event",read_only=true,emit=a.toqcb2LastEvent(),converter=d.from_only(d.lookup_value{[0]="normal",[1]="trip_over_current",[2]="trip_over_power",[3]="trip_over_temperature",[4]="trip_voltage_1",[5]="trip_voltage_2",[6]="alarm_over_current",[7]="alarm_over_power",[8]="alarm_over_temperature",[9]="alarm_voltage_1",[10]="alarm_voltage_2",[11]="remote_on",[12]="remote_off",[13]="manual_on",[14]="manual_off",[15]="value_15",[16]="value_16",[17]="factory_reset"})}),b.dp_on_off(112,{name="clear_fault",emit=a.clearFaultBreaker(),converter=d.lookup_from_to{on=true,off=false}}),b.dp_on_off(113,{name="factory_reset",emit=a.toqcb2FactoryReset(),converter=d.lookup_from_to{off=false,on=true}}),b.dp_numeric(114,{name="current_threshold",emit=a.currentThresholdToqcb2A63()}),b.dp_numeric(115,{name="over_voltage_threshold",emit=a.toqcb2OverVoltageThreshold()}),b.dp_numeric(116,{name="under_voltage_threshold",emit=a.toqcb2UnderVoltageThreshold()}),b.dp_temperature(118,{name="temperature_threshold",scale=10,emit=a.toqcb2TemperatureThreshold()}),b.dp_numeric(119,{name="over_power_threshold",emit=a.toqcb2OverPowerThreshold()}),b.dp_temperature(131,{name="temperature",scale=10,read_only=true,emit=a.temperature()})}c(E,e.create_fingerprints("TS0601",{"_TZE284_q22avxbv","_TZE204_q22avxbv","_TZE204_mrffaamu","_TZE204_tzreobvu","_TZE284_mrffaamu","_TZE284_tzreobvu","_TZE284_9xstqowh","_TZE284_kv1nvirl","_TZE284_lyqazpe6","_TZE204_lyqazpe6"}))c(E,{e.create_fingerprint("Tongou","TOQCB2-80-2P")})return{id="ef00.din_rail.energy",registrations=ao}
