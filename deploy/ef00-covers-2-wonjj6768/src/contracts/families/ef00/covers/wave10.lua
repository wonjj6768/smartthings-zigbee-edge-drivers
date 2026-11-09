local m,Y,k,O,W,G=require"protocol.tuya",require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.cluster_base",require"st.zigbee.data_types"local e=m.converter
local I,f=O.definition_registry()
local function t(q)
return type(q)=="table"and type(q.preferences)=="table"and q.preferences.reverse==true
end
local function U(i,q,X,T,V)
local j=tonumber(i)if j==nil then return nil end
if T and j>100 then
j=j>150 and 0 or 100
end
if X then j=100-j end
if V and t(q)then j=100-j end
return j
end
local function y(l)
l=l or{}return e.from_to(
function(i,q)
return U(i,q,l.invert_wire==true,l.overflow_guard==true,l.reverse_from~=false)
end,
function(i,q)
local j=tonumber(i)if j==nil then return nil end
if l.invert_wire==true then j=100-j end
if l.reverse_to~=false and t(q)then j=100-j end
return j
end
)
end
local function z(l)
local Z=y(l)
return e.from_only(function(i,q)
local S=Z.from(i,q)if S==nil then return nil end
if S<=0 then return"closed"end
if S>=100 then return"open"end
return"partially open"
end)
end
local function N()
return e.from_to(
function(i)
return({[0]="open",[1]="paused",[2]="closed",[3]="partially open"})[tonumber(i)]
end,
function(i)
return({open=0,stop=1,close=2})[i]
end
)
end
local function H(J,E)
return e.from_to(
function(i,q)
local D,j=t(q)and E or J,tonumber(i)
if j==D.open then return"open"end
if j==D.stop then return"paused"end
if j==D.close then return"closed"end
return nil
end,
function(i,q)
local D=t(q)and E or J
return({open=D.open,stop=D.stop,close=D.close})[i]
end
)
end
local function F(J,E)
return e.from_only(function(i,q)
local D,j=t(q)and E or J,tonumber(i)
if j==D.opening then return"opening"end
if j==D.closing then return"closing"end
if D.stopped~=nil and j==D.stopped then return"stopped"end
return nil
end)
end
local function v(J,E)
local Z=e.lookup_from_to{[J]=0,[E]=1}return e.from_to(
function(i)
if type(i)=="string"then return i=="back"and E or J end
return Z.from(i)
end,
Z.to)
end
local function g(r,dp,l)
l=l or{}r.datapoints[#r.datapoints+1]=m.dp_numeric(dp,{name=l.name or"cover_position",read_only=l.read_only==true,write_only=l.write_only==true,command_id=l.command_id,converter=y(l),emit=k.shade_level()})r.datapoints[#r.datapoints+1]=m.dp_numeric(dp,{name=(l.name or"cover_position").."_shade_state",read_only=true,converter=z(l),emit=k.shade_state()})
end
local function p(r,dp,l)
l=l or{}r.datapoints[#r.datapoints+1]=m.dp_enum(dp,{name=l.name or"cover_state",read_only=l.read_only==true,write_only=l.write_only==true,command_id=l.command_id,converter=N(),emit=l.emit==false and nil or k.shade_state()})
end
local function u(r,dp)
r.datapoints[#r.datapoints+1]=m.dp_battery(dp,{read_only=true,emit=k.battery()})
end
local function n(ad)
return{profile=ad,package_group="cover",magic_packet=true,datapoints={}}
end
local C,o=O.create_fingerprints,n"covers-wave10-moes-adcbzi01"
o.magic_packet=false
o.query_on_configure=true
o.zcl_clusters={Y.tuya_magic_packet(),Y.cover_position{read_only=false,converter=y{invert_wire=true}},Y.window_shade_state{read_only=true,
converter=e.from_only(function(i)
local j=tonumber(i)if j==nil then return nil end
if j<=0 then return"open"end
if j>=100 then return"closed"end
return"partially open"
end)
},Y.cover_state{read_only=false},Y.cluster_attribute(258,61442,{name="adcbzi_calibration",read_only=false,attribute_name="tuyaMotorReversal",data_type=G.Enum8,write_type=G.Enum8,read_on_configure=true,converter=e.lookup_from_to{stop=0,calibrate=1,calibrate_reverse=2},emit=k.adcbziCalibration(),
sender=function(q,A,i,Q)
local ae=A.converter.to(i,q,Q)if ae==nil then return false end
local R=W.write_attribute(q,G.ClusterId(258),G.AttributeId(61442),G.Enum8(ae))if Q~=nil and Q.endpoint~=nil
and R.address_header~=nil and R.address_header.dest_endpoint~=nil then
R.address_header.dest_endpoint.value=Q.endpoint
end
q:send(R)return true
end
})}o.datapoints[#o.datapoints+1]=m.dp_numeric(1,{name="adcbzi_cover_state_report",read_only=true,converter=H({open=0,stop=1,close=2},{open=0,stop=1,close=2}),emit=k.shade_state()})g(o,2,{name="adcbzi_position_control_report",read_only=true})g(o,3,{name="adcbzi_position_report",read_only=true,invert_wire=true})o.datapoints[#o.datapoints+1]=m.dp_numeric(7,{name="adcbzi_work_state",read_only=true,
converter=e.from_only(function(i)
return({[0]="standby",[1]="opening",[2]="closing"})[tonumber(i)]
end),
emit=k.adcbziWorkState()})o.datapoints[#o.datapoints+1]=m.dp_numeric(10,{name="adcbzi_total_time",read_only=true,emit=k.adcbziTotalTime()})o.datapoints[#o.datapoints+1]=m.dp_numeric(11,{name="adcbzi_situation_set",converter=e.lookup_from_to{fully_open=0,fully_close=1},emit=k.adcbziSituationSet()})o.datapoints[#o.datapoints+1]=m.dp_numeric(12,{name="adcbzi_fault",read_only=true,
converter=e.from_only(function(i)return tonumber(i)==0 and"none"or nil end),
emit=k.adcbziFault()})u(o,13)o.datapoints[#o.datapoints+1]=m.dp_numeric(101,{name="adcbzi_charging_status",read_only=true,
converter=e.from_only(function(i)
return({[0]="none",[1]="uncharged",[2]="charging",[3]="charged"})[tonumber(i)]
end),
emit=k.adcbziChargingStatus()})for aa,af in ipairs{"adcbzi_custom_week_prog_one","adcbzi_custom_week_prog_two","adcbzi_custom_week_prog_three","adcbzi_custom_week_prog_four"}do
local ac=({k.adcbziCustomWeekProgOne,k.adcbziCustomWeekProgTwo,k.adcbziCustomWeekProgThree,k.adcbziCustomWeekProgFour})[aa]o.datapoints[#o.datapoints+1]=m.dp_string(102+aa,{name=af,emit=ac()})end
o.datapoints[#o.datapoints+1]=m.dp_illuminance(107,{read_only=true,emit=k.illuminance()})for _,A in ipairs{{108,"adcbzi_open_threshold",k.adcbziOpenThreshold},{109,"adcbzi_close_threshold",k.adcbziCloseThreshold},{110,"adcbzi_curtain_status",k.adcbziCurtainStatus},{111,"adcbzi_factory_test",k.adcbziFactoryTest,true},{112,"adcbzi_total_distance",k.adcbziTotalDistance,true}}do
o.datapoints[#o.datapoints+1]=m.dp_numeric(A[1],{name=A[2],read_only=A[4],emit=A[3]()})end
f(o,C("TS030F",{"_TZ3210_sxtfesc6","_TZ3210_rundhkxp"}))local M=n"covers-wave10-manhot-bl82-tyz1"M.respond_to_mcu_version_response=true
p(M,1)g(M,2)g(M,3,{name="position_report",read_only=true})M.datapoints[#M.datapoints+1]=m.dp_enum(5,{name="bl_tyz_motor_direction",converter=e.lookup_from_to{normal=0,reversed=1},emit=k.blTyzMotorDirection()})u(M,13)M.datapoints[#M.datapoints+1]=m.dp_binary(6,{name="bl_tyz_auto_power",converter=e.lookup_from_to{ON=true,OFF=false},emit=k.blTyzAutoPower()})f(M,C("TS0601",{"_TZE284_7qc2wlqr","_TZE2841000000_7qc2wlqr"}))local P=n"covers-wave10-moes-zs-sr-euc"p(P,1)g(P,2,{overflow_guard=true,reverse_from=false})P.datapoints[#P.datapoints+1]=m.dp_enum(3,{name="zs_sr_calibration",converter=e.lookup_from_to{START=0,END=1},emit=k.zsSrCalibration()})P.datapoints[#P.datapoints+1]=m.dp_enum(8,{name="zs_sr_motor_steering",converter=e.lookup_from_to{FORWARD=0,BACKWARD=1},emit=k.zsSrMotorSteering()})f(P,C("TS0601",{"_TZE204_srmahpwl"}))local B=n"covers-wave10-moes-zc-lp01"B.datapoints[#B.datapoints+1]=m.dp_numeric(102,{name="cover_state",command_id=m.SEND_DATA,converter=H({open=0,stop=2,close=1},{open=1,stop=2,close=0}),emit=k.shade_state()})g(B,104,{command_id=m.SEND_DATA})u(B,4)B.datapoints[#B.datapoints+1]=m.dp_numeric(105,{name="zc_lp_charging",read_only=true,
converter=e.from_only(function(i)
return tonumber(i)==1 and"charging"or"not_charging"
end),
emit=k.zcLpCharging()})B.datapoints[#B.datapoints+1]=m.dp_numeric(106,{name="zc_lp_automatic_mode",command_id=m.SEND_DATA,converter=e.lookup_from_to{ON=1,OFF=0},emit=k.zcLpAutomaticMode()})B.datapoints[#B.datapoints+1]=m.dp_enum(110,{name="zc_lp_slow_mode",command_id=m.SEND_DATA,converter=e.lookup_from_to{ON=1,OFF=0},emit=k.zcLpSlowMode()})B.datapoints[#B.datapoints+1]=m.dp_numeric(112,{name="zc_lp_button_position",command_id=m.SEND_DATA,converter=e.lookup_from_to{UP=1,DOWN=0},emit=k.zcLpButtonPosition()})f(B,C("TS0601",{"_TZ3210_5rta89nj"}))local x=n"covers-wave10-moes-fwjzceh18a001"x.mcu_version_request_on_configure=true
x.query_on_configure=false
x.query_on_announce=false
x.refresh_state=false
x.refresh_state_query=false
x.time_start="off"p(x,1)
x.datapoints[1].from_device=function(i)
return({[0]="open",[1]="partially open",[2]="closed",[3]="partially open"})[i]
end
g(x,9)g(x,8,{name="position_report",read_only=true})x.datapoints[#x.datapoints+1]=m.dp_enum(11,{name="fwjz_motor_direction",converter=e.lookup_from_to{normal=0,reversed=1},receive_datatypes={4,3},
from_device=function(i)
if type(i)=="string"then return i=="back"and"reversed"or"normal"end
return({[0]="normal",[1]="reversed"})[i]
end,
emit=k.fwjzMotorDirection()})x.datapoints[#x.datapoints+1]=m.dp_raw(13,{name="battery",read_only=true,
converter=e.from_only(function(i)
if type(i)~="string"or #i<4 then return nil end
local a,b,c,d=string.byte(i,1,4)return(((a*256)+b)*256+c)*256+d
end),
emit=k.battery()})x.datapoints[#x.datapoints+1]=m.dp_enum(16,{name="fwjz_cover_limit",converter=e.lookup_from_to{set_up=0,set_down=1,delete_up=2,delete_down=3,delete_both=4},emit=k.fwjzCoverLimit()})f(x,C("TS0601",{"_TZE284_qoi1aqxg"}))local h=n"covers-wave10-tuya-ts0301-cover-two"p(h,1)h.datapoints[#h.datapoints+1]=m.dp_enum(3,{name="ts_cover_two_motor_state",read_only=true,converter=F({opening=0,closing=1,stopped=2},{opening=0,closing=1,stopped=2}),emit=k.tsCoverTwoMotorState()})h.datapoints[#h.datapoints+1]=m.dp_enum(7,{name="ts_cover_two_slow_mode",converter=e.lookup_from_to{ON=1,OFF=0},emit=k.tsCoverTwoSlowMode()})g(h,9)g(h,8,{name="position_report",read_only=true})h.datapoints[#h.datapoints+1]=m.dp_enum(11,{name="ts_cover_two_motor_direction",converter=e.lookup_from_to{normal=0,reversed=1},emit=k.tsCoverTwoMotorDirection()})u(h,13)h.datapoints[#h.datapoints+1]=m.dp_enum(15,{name="ts_cover_two_cover_type",converter=e.lookup_from_to{roman_pole=0,roller_blind=1,canopy_curtain=2,roman_blind=3,honeycomb_curtain=4},emit=k.tsCoverTwoCoverType()})h.datapoints[#h.datapoints+1]=m.dp_enum(16,{name="ts_cover_two_cover_limit",converter=e.lookup_from_to{set_up=0,set_down=1,delete_up=2,delete_down=3,delete_both=4},emit=k.tsCoverTwoCoverLimit()})h.datapoints[#h.datapoints+1]=m.dp_numeric(19,{name="ts_cover_two_favorite_position",emit=k.tsCoverTwoFavoritePosition()})h.datapoints[#h.datapoints+1]=m.dp_enum(20,{name="ts_cover_two_click_control",converter=e.lookup_from_to{up=0,down=1},emit=k.tsCoverTwoClickControl()})f(h,C("TS0301",{"_TZE210_xgzzuerd"}))local L=n"covers-wave10-xenon-x7726"p(L,1)g(L,2)g(L,3,{name="position_report",read_only=true})L.datapoints[#L.datapoints+1]=m.dp_enum(102,{name="x_seven_calibration",converter=e.lookup_from_to{start=0,finish=1},emit=k.xSevenCalibration()})L.datapoints[#L.datapoints+1]=m.dp_numeric(103,{name="temperature",read_only=true,emit=k.temperature"C"})f(L,C("TS0601",{"_TZE284_hbjwgkdh"}))local K=n"covers-wave10-zemismart-zn-usc1u-ht"p(K,1)g(K,2)K.datapoints[#K.datapoints+1]=m.dp_enum(8,{name="zn_usc_motor_steering",converter=v("FORWARD","BACKWARD"),emit=k.znUscMotorSteering()})K.datapoints[#K.datapoints+1]=m.dp_numeric(10,{name="zn_usc_calibration_time",emit=k.znUscCalibrationTime()})f(K,C("TS0601",{"_TZE204_mpg22jc1"}))local w=n"covers-wave10-zemismart-zmp1"w.datapoints[#w.datapoints+1]=m.dp_enum(1,{name="cover_state",converter=H({open=0,stop=1,close=2},{open=2,stop=1,close=0}),emit=k.shade_state()})g(w,2)g(w,3,{name="position_report",read_only=true})w.datapoints[#w.datapoints+1]=m.dp_enum(5,{name="zmp_one_motor_direction",converter=e.lookup_from_to{normal=0,reversed=1},emit=k.zmpOneMotorDirection()})w.datapoints[#w.datapoints+1]=m.dp_enum(7,{name="zmp_one_motor_state",read_only=true,converter=F({opening=0,closing=1},{opening=1,closing=0}),emit=k.zmpOneMotorState()})u(w,13)f(w,C("TS0601",{"_TZE284_6hrnp30w"}))local s=n"covers-zemismart-zn2s-usc1u"s.initial_custom_state_query=false
s.time_start="off"s.mcu_version_request_on_configure=true
p(s,1)g(s,2)s.datapoints[#s.datapoints+1]=m.dp_enum(8,{name="zn2s_motor_direction",emit=k.zn2sMotorDirection(),converter=v("normal","reversed")})s.datapoints[#s.datapoints+1]=m.dp_numeric(10,{name="zn2s_calibration_time",emit=k.zn2sCalibrationTime()})for _,A in ipairs(s.datapoints)do
if not A.read_only then A.transaction=1 end
end
f(s,C("TS0601",{"_TZE28C1000000_19jwhi8c"}))Y.attach_reporting_capabilities(I,{{1,"rpt-thj"}})return{id="ef00.covers.wave10",registrations=I}
