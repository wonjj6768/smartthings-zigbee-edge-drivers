local e,f,b,x,z=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"st.capabilities",require"runtime.capability_support".is_callable
local m=e.converter
local y,a=b.definition_registry()
local function h(i)
if i==1 then
return"main"end
return"button"..tostring(i)
end
local function j(_,w)
local E=x.button and x.button.button or nil
local C=E and E[w]or nil
if not z(C)then
return nil
end
return C{state_change=true}
end
local function l(w)
return m.from_only(m.constant(w))
end
local function t(G)
return m.lookup_from_to(G)
end
local s={profile="controls-wave19-box-erc2201-z",button_actions={"pushed"},named_datapoints=true,magic_packet=true,query_on_configure=false,time_start="off",datapoints={e.dp_on_off(19,{name="switch",component="main",transaction=1,emit=f.switch()}),e.dp_enum(102,{name="box_erc_record_rf",transaction=1,converter=t{record=0},emit=f.boxErcRecordRf()}),e.dp_enum(102,{name="box_erc_clear_rf",transaction=1,converter=t{clear=1},emit=f.boxErcClearRf()}),e.dp_enum(103,{name="box_erc_rf_status",transaction=1,read_only=true,converter=t{ok=0,error=1},emit=f.boxErcRfStatus()}),e.dp_enum(104,{name="box_erc_record_scene",transaction=1,converter=t{scene_1=0,scene_2=1,scene_3=2,scene_4=3,scene_5=4,scene_6=5,scene_7=6,scene_8=7,scene_9=8,scene_10=9},emit=f.boxErcRecordScene()}),e.dp_enum(104,{name="box_erc_clear_scene",transaction=1,converter=t{scene_1=10,scene_2=11,scene_3=12,scene_4=13,scene_5=14,scene_6=15,scene_7=16,scene_8=17,scene_9=18,scene_10=19},emit=f.boxErcClearScene()}),e.dp_enum(105,{name="box_erc_rf_scene_status",transaction=1,read_only=true,converter=t{ok=0,error=1},emit=f.boxErcRfSceneStatus()})}}for i=1,10 do
s.datapoints[#s.datapoints+1]=e.dp_enum(i,{name="box_erc_scene_"..tostring(i),component=h(i),transaction=1,read_only=true,converter=l"pushed",emit=j})end
a(s,{b.create_fingerprint("_TZE200_lhpnrfmy","TS0601")})
local function g(q)
local c={}for i,H in ipairs(q.switch_dps)do
c[#c+1]=e.dp_on_off(H,{name="switch",component=h(i),transaction=1,emit=f.switch()})end
for i,H in ipairs(q.scene_dps)do
c[#c+1]=e.dp_enum(H,{name=q.prefix.."_scene_"..tostring(i),component=h(i),transaction=1,read_only=true,converter=l"pushed",emit=j})end
c[#c+1]=e.dp_numeric(101,{name=q.prefix.."_backlight_brightness",component="main",transaction=1,emit=q.backlight_emitter})return{profile=q.profile,button_actions={"pushed"},named_datapoints=true,magic_packet=true,query_on_configure=false,time_start="off",datapoints=c}
end
local D=g{profile="controls-wave19-qa-qat44z6",prefix="qa_qat_six",switch_dps={24,25,26,27,28,29},scene_dps={7,8,9,10,11,12},backlight_emitter=f.qaQatSixBacklight()}a(D,{b.create_fingerprint("_TZE284_ms97nkyy","TS0601")})local A=g{profile="controls-wave19-qa-qat42z2b",prefix="qa_qat_two",switch_dps={24,25},scene_dps={5,6},backlight_emitter=f.qaQatTwoBacklight()}a(A,{b.create_fingerprint("_TZE284_1aqlsquf","TS0601")})local B=g{profile="controls-wave19-qa-qat42z3b",prefix="qa_qat_three",switch_dps={24,25,26},scene_dps={5,6,7},backlight_emitter=f.qaQatThreeBacklight()}a(B,{b.create_fingerprint("_TZE284_pgxndxp4","TS0601")})local v={profile="controls-wave19-tuya-presence-switch",named_datapoints=true,magic_packet=true,query_on_configure=false,time_start="off",datapoints={e.dp_on_off(1,{name="switch",component="main",transaction=1,emit=f.switch()}),e.dp_numeric(7,{name="tuya_ps_1_countdown",transaction=1,emit=f.tuyaPsOneCountdown()}),e.dp_enum(14,{name="tuya_ps_1_relay_status",transaction=1,converter=t{off=0,on=1,memory=2},emit=f.tuyaPsOneRelayStatus()}),e.dp_enum(15,{name="tuya_ps_1_light_mode",transaction=1,converter=t{relay=0,none=1,pos=2},emit=f.tuyaPsOneLightMode()}),e.dp_presence(101,{datatype=e.DP_TYPE_ENUM,transaction=1,converter=m.true_false1(),emit=f.presence(),read_only=true}),e.dp_numeric(102,{name="tuya_ps_1_delays_time",transaction=1,emit=f.tuyaPsOneDelaysTime()}),e.dp_enum(103,{name="tuya_ps_1_turn_on_light_for_person",transaction=1,converter=t{none=0,all=1},emit=f.tuyaPsOneTurnOnPerson()}),e.dp_numeric(104,{name="tuya_ps_1_sensitivity",transaction=1,emit=f.tuyaPsOneSensitivity()}),e.dp_enum(105,{name="tuya_ps_1_turn_off_light_for_person",transaction=1,converter=t{none=0,all=1},emit=f.tuyaPsOneTurnOffPerson()})}}a(v,{b.create_fingerprint("_TZE28C1000000_jlbsptkl","TS0601")})local r={[0]="pushed",[1]="double",[2]="held"}
local function k(u,p)
local F=type(p)=="table"and p.frame or nil
local c=type(F)=="table"and F.datapoints or nil
return type(c)~="table"or c[1]==u
end
local o=m.from_only(function(w,_,u,p)
if not k(u,p)then
return nil
end
return r[w]
end)
local n=m.from_only(function(w,_,u,p)
if not k(u,p)then
return nil
end
return w
end)
local d={profile="controls-wave19-zemismart-zm-rm02",button_actions={"pushed","double","held"},magic_packet=true,query_on_configure=false,time_start="off",datapoints={}}for i=1,6 do
d.datapoints[#d.datapoints+1]=e.dp_enum(i,{name="zemismart_zm_rm02_button_"..tostring(i),component=h(i),transaction=1,read_only=true,converter=o,emit=j})end
d.datapoints[#d.datapoints+1]=e.dp_numeric(10,{name="battery",transaction=1,read_only=true,converter=n,emit=f.battery()})a(d,{b.create_fingerprint("_TZE200_zqtiam4u","TS0601")})return{id="ef00.controls.wave19.remotes",registrations=y}
