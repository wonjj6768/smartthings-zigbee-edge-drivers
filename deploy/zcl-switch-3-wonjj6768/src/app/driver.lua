local aS,y,ba,J,capabilities,bU,bt,aa,S,ah,at,bJ,ap,bn,bj=require"protocol.tuya",require"protocol.zcl",require"core.registry",require"runtime.capability_metadata",require"st.capabilities",require"st.device",require"st.zigbee.data_types",require"st.zigbee.generated.zcl_clusters",require"app.component_mapping",require"app.custom_capability_runtime",require"runtime.battery_refresh",require"runtime.energy_reset",require"app.switch_command_router",require"st.zigbee.defaults.switch_defaults.on",require"st.zigbee.defaults.switch_defaults.off"local f,q,p,Q,ag,L,ak,o,A,O,P,ax,aT,E,T,B,z,as,ae,aw,bi=J.by_emit_name.power_poll_interval,J.by_emit_name.learn_ir_code,J.by_emit_name.ir_code_to_send,"_presetLevel",50,"_tuya_power_poll_interval_seconds",300,5,3600,5,"s",1282,0,3,0,3,300,"statelessSwitchLevelStep","stepLevel",19,setmetatable({},{__mode="k"})















local function aC()
local bq,x=ba.all(),{}for _,bZ in pairs(bq)do
for _,g in pairs(bZ)do
for _,bV in ipairs(g.additional_zcl_profiles or{})do
x[bV]=true
end
if g.zcl_clusters then
y.register_attributes_from_mappings(g.zcl_clusters)y.register_cluster_commands_from_mappings(g.zcl_clusters)y.prepare_mappings(g.zcl_clusters)end
end
end
return x
end
local x=aC()
local function h(a)
local bW=bi[a]if bW then
return bW
end
local bh,cf=a:get_manufacturer(),a:get_model()if not bh or not cf then
return nil
end
local g=ba.find(bh,cf)if not g then
return nil
end
local b=aS.build_base_preset(g)for ci,m in pairs(g)do
if ci~="fingerprints"and b[ci]==nil then
b[ci]=m
end
end
if b.zcl_clusters then
y.prepare_mappings(b.zcl_clusters)end
bi[a]=b
return b
end
local function aQ(_,a)
local b=h(a)if b==nil then
return false
end
return b:apply_announce(a)
end
at.set_requester(function(a)
local bN=h(a).zcl_clusters
if y.find_mapping(bN,1,32)==nil then
local bx=y.find_mapping(bN,1,33)if bx~=nil then
return y.read_mapping(a,bx,{endpoint=a:get_endpoint(1)})end
end
return y.read_attribute(a,1,32,a:get_endpoint(1))
end,function(a)
local b=h(a)return b~=nil and b.zcl_clusters~=nil and
y.has_cluster(b.zcl_clusters,y.CLUSTER_POWER_CONFIGURATION)
end)
local au=require"runtime.capability_support".is_callable
local function an(a,t)
if type(a)~="table"or type(t)~="string"then
return false
end
local bs=a.profile and a.profile.components or nil
local cj=type(bs)=="table"and bs.main or nil
local aL=type(cj)=="table"and cj.capabilities or nil
if type(aL)~="table"then
return false
end
for _,s in ipairs(aL)do
if type(s)=="table"and s.id==t then
return true
end
end
return false
end
local function v(m)
local r=tonumber(m)if r==nil then
return nil
end
r=math.floor(r+0.5)if r<o then
r=o
elseif r>A then
r=A
end
local bF=r%O
if bF~=0 then
r=r-bF
if r<o then
r=o
end
end
return r
end
local function C(a,b)
return type(b)=="table"and b.zcl_clusters==nil
and type(b.datapoints)=="table"and f~=nil
and an(a,f.capability_id)
end
local function G(a,b)
local ce,bB=v(a:get_field(L)),v(b and b.default_power_poll_interval_seconds)return ce or bB or ak
end
local function R(a,b)
if not C(a,b)then
return false
end
local s=capabilities[f.capability_id]local aK=s and s[f.attribute_name]or nil
if not au(aK)and s and type(s.attributes)=="table"then
aK=s.attributes[f.attribute_name]end
if not au(aK)then
return false
end
local Y=s and s[f.range_attribute_name]or nil
if not au(Y)and s and type(s.attributes)=="table"then
Y=s.attributes[f.range_attribute_name]end
if au(Y)then
a:emit_event(Y{value={minimum=o,maximum=A,step=O},unit=P})end
a:emit_event(aK{value=G(a,b),unit=P})return true
end
local function ad(a,b)
if not C(a,b)then
return false
end
b:start_query_timer(a,G(a,b))R(a,b)return true
end
local function aj(e)
return string.format("%s:%s",Q,tostring(e or"main"))
end
local function F(a,e)
e=e or"main"local bY=a:get_latest_state(e,capabilities.windowShadePreset.ID,"position")if type(bY)=="number"then
return bY
end
local bz=a:get_field(aj(e))if type(bz)~="number"then
bz=a:get_field(Q)end
if type(bz)=="number"then
return bz
end
local by=a.preferences and a.preferences.presetPosition or nil
if type(by)=="number"then
return by
end
return ag
end
local function M(a)
for _,e in ipairs(S.sorted_profile_component_ids(a))do
if a:supports_capability_by_id(capabilities.windowShadePreset.ID,e)then
a:emit_component_event({id=e},capabilities.windowShadePreset.position(F(a,e)))end
end
end
local function aZ(a,g)
if type(g)~="table"or type(g.button_actions)~="table"then
return
end
local bp=g.button_actions
for _,e in ipairs(S.sorted_profile_component_ids(a))do
if a:supports_capability_by_id(capabilities.button.ID,e)then
a:emit_component_event({id=e},capabilities.button.supportedButtonValues(bp))a:emit_component_event({id=e},capabilities.button.numberOfButtons{value=1})end
end
end
local function I(_,a,bC)
local b=h(a)if b then
b:apply_message(a,bC)end
end
local function aO()
local i,bc={[aS.EF00_CLUSTER]={[aS.GET_DATA]=I,[aS.SET_DATA_RESPONSE]=I,[aS.REPORT_STATUS]=I,[aS.ACTIVE_STATUS_REPORT]=I,[aS.SET_TIME]=I,[aS.CONNECTION_STATUS]=I,[aS.MCU_VERSION_RESPONSE]=I}},y.build_zigbee_cluster_handlers(h)for aW,bo in pairs(bc)do
i[aW]=i[aW]or{}for bT,cg in pairs(bo)do
i[aW][bT]=cg
end
end
return i
end
local bf={{capabilities.switch.ID,"on","switch",true},{capabilities.switch.ID,"off","switch",false},{capabilities.audioVolume.ID,"setVolume","volume","volume"},{capabilities.doorControl.ID,"open","door_control",true},{capabilities.doorControl.ID,"close","door_control",false},{capabilities.valve.ID,"open","valve","open"},{capabilities.valve.ID,"close","valve","closed"},{capabilities.switchLevel.ID,"setLevel","brightness","level"},{capabilities.windowShade.ID,"open","cover_state","open"},{capabilities.windowShade.ID,"close","cover_state","close"},{capabilities.windowShade.ID,"pause","cover_state","stop"},{capabilities.windowShadeLevel.ID,"setShadeLevel","cover_position","shadeLevel"},{capabilities.windowShadeTiltLevel.ID,"setShadeTiltLevel","cover_tilt","level"},{capabilities.thermostatHeatingSetpoint.ID,"setHeatingSetpoint","current_heating_setpoint","setpoint"},{capabilities.thermostatCoolingSetpoint.ID,"setCoolingSetpoint","current_cooling_setpoint","setpoint"},{capabilities.thermostatMode.ID,"setThermostatMode","system_mode","mode"},{capabilities.thermostatMode.ID,"auto","system_mode","auto"},{capabilities.thermostatMode.ID,"cool","system_mode","cool"},{capabilities.thermostatMode.ID,"emergencyHeat","system_mode","emergency heat"},{capabilities.thermostatMode.ID,"heat","system_mode","heat"},{capabilities.thermostatMode.ID,"off","system_mode","off"},{capabilities.fanMode.ID,"setFanMode","fan_mode","fanMode"},{capabilities.colorTemperature.ID,"setColorTemperature","color_temperature","temperature",true},{capabilities.colorControl.ID,"setHue","color_hue","hue",true},{capabilities.colorControl.ID,"setSaturation","color_saturation","saturation",true},
{capabilities.colorControl.ID,"setColor","color",function(d)
return d.args and d.args.color or nil
end,true}
}local aE={[capabilities.audioVolume.ID ..":"..capabilities.audioVolume.commands.setVolume.NAME]={"volume"},[capabilities.colorTemperature.ID ..":"..capabilities.colorTemperature.commands.setColorTemperature.NAME]={"color_temperature"},[capabilities.colorControl.ID ..":"..capabilities.colorControl.commands.setHue.NAME]={"color_hue"},[capabilities.colorControl.ID ..":"..capabilities.colorControl.commands.setSaturation.NAME]={"color_saturation"},[capabilities.colorControl.ID ..":"..capabilities.colorControl.commands.setColor.NAME]={"color_hue","color_saturation"}}
local function bw(a)
return type(a)=="table"and(a.network_type==bU.NETWORK_TYPE_CHILD or
type(a.parent_assigned_child_key)=="string")
end
local function ai(n,a)
if type(n)~="table"or type(a)~="table"or type(n.try_delete_device)~="function"then
return
end
if a.thread~=nil and type(a.thread.call_with_delay)=="function"then
a.thread:call_with_delay(1,function()
n:try_delete_device(a.id)
end,string.format("delete unexpected child %s",tostring(a.id)))
return
end
n:try_delete_device(a.id)
end
local function aI(a,d,bO,m)
local b=h(a)if b==nil then
return false
end
local j=false
if b.datapoints then
j=b:send_named_mapping(a,bO,m,{component_id=d.component})or j
end
if b.zcl_clusters then
j=y.send_named_command(a,b.zcl_clusters,bO,m,{component_id=d.component,zcl_clusters=b.zcl_clusters,transition_time=bO=="brightness"and d.args and d.args.rate or nil})or j
end
if not j and b.protocol_writers and b.protocol_writers[bO]then
j=b.protocol_writers[bO](a,m,d)==true
end
return j
end
local function ac(a)
return ba.find(a:get_manufacturer(),a:get_model())
end
local function aN(a)
local b=h(a)return b~=nil and b.zcl_clusters~=nil and y.has_cluster(b.zcl_clusters,y.CLUSTER_ON_OFF)
end
local function az(a,e)
if type(a)~="table"or type(a.get_endpoint_for_component_id)~="function"then
return 1
end
local am=a:get_endpoint_for_component_id(e or"main")if type(am)=="table"then
am=am[1]end
if type(am)~="number"then
return 1
end
return am
end
local function av(a)
local b=h(a)return b~=nil and b.zcl_clusters~=nil and y.has_cluster(b.zcl_clusters,ax)
end
local function V(a,e,m)
local l=e or"main"if type(a)~="table"or not a:supports_capability_by_id(capabilities.alarm.ID,l)then
return
end
a:emit_component_event({id=l},capabilities.alarm.alarm[m]())
end
local function N(a,d,ck)
local b,m=h(a),ck~="off"if b~=nil and b.alarm_command_modes==true then
m=ck
end
return aI(a,d,"alarm",m)
end
local function w(a,e,bP,aV,bQ,cc)
if not av(a)then
return false
end
local K=aa.IASWD.types.SirenConfiguration(0)K:set_warning_mode(bP)K:set_strobe(aV and 1 or 0)K:set_siren_level(bQ)local am,d=az(a,e),aa.IASWD.server.commands.StartWarning(a,K,bt.Uint16(cc or 0),bt.Uint8(0),aa.IASWD.types.IaswdLevel(aV and B or T))a:send(d:to_endpoint(am))return true
end
local k=ah.create{get_preset=h,send=aI,resolve_definition=ac}
local function al(n,a,b)
if b==nil then
return
end
if type(b.configure)=="function"then
b.configure(n,a)end
b:start_configuration(a,n)if b.zcl_clusters and b.zcl_configure~=false then
y.start_configuration(a,b.zcl_clusters)end
if type(b.zcl_initial_writes)=="table"then
for _,ch in ipairs(b.zcl_initial_writes)do
y.send_named_command(a,b.zcl_clusters,ch.name,ch.value)end
end
end
local function bb(a,b)
if b and b.zcl_clusters then
y.start_runtime(a,b.zcl_clusters)y.emit_power_polling_state(a,b.zcl_clusters)if y.emit_ir_state~=nil then
y.emit_ir_state(a,b)end
if a.thread~=nil and type(a.thread.call_with_delay)=="function"then
a.thread:call_with_delay(2,function()
y.emit_power_polling_state(a,b.zcl_clusters)if y.emit_ir_state~=nil then
y.emit_ir_state(a,b)end
end,"zcl initial power polling state")
end
else
ad(a,b)end
if b~=nil and b.configure_options~=nil and
b.configure_options.query_interval_seconds~=nil then
b:start_query_timer(a)end
if b~=nil and type(b.runtime_start)=="function"then
b.runtime_start(a,b)end
end
local function ab(a,g,bl)
k.refresh_definitions(a)if bl then
k.diagnose_bindings(a)end
aZ(a,g)k.emit_numeric_metadata(a,g)k.emit_enum_metadata(a,g)
end
local function aH(a,e,ay,bA)
if type(ay)~="table"or ay[1]==nil or a.thread==nil or type(a.thread.call_with_delay)~="function"then
return
end
local b=h(a)if b==nil or b.zcl_clusters==nil then
return
end
a.thread:call_with_delay(bA or 2,function()
for _,bM in ipairs(ay)do
y.read_named_attribute(a,b.zcl_clusters,bM,{component_id=e})end
end,string.format("zcl delayed read %s",tostring(e or"main")))
end
local function aP(a,e,m)
local l=e or"main"if type(a)~="table"or not a:supports_capability_by_id(capabilities.switch.ID,l)then
return
end
local cl=m and capabilities.switch.switch.on()or capabilities.switch.switch.off()a:emit_component_event({id=l},cl)
end
local function U(a,bA,cm)
if type(a)~="table"or a.thread==nil or type(a.thread.call_with_delay)~="function"then
return
end
a.thread:call_with_delay(bA,function()
local b=h(a)if b~=nil and b.datapoints~=nil then
b:send_state_request(a)end
end,cm or"ef00 delayed state request")
end
local function u(a,d,m)
local e,b=d and d.component or"main",h(a)if b==nil or b.datapoints==nil then
return
end
local bH=b and b.named_mappings_by_name
if bH==nil and b and b.datapoints then
bH=aS.build_named_map(b.datapoints,"name")end
local bR=bH and bH.switch
if bR==nil or bR.suppress_optimistic_state~=true then
aP(a,e,m)end
if b.post_switch_state_query~=false then
U(a,1,"ef00 switch state read 1s")U(a,3,"ef00 switch state read 3s")end
end
local function Z(m)
local r=tonumber(m)if r==nil then
return nil
end
r=math.floor(r+0.5)if r<0 then
return 0
end
if r>100 then
return 100
end
return r
end
local function aX(a,e)
if type(a)~="table"or type(a.get_latest_state)~="function"then
return 0
end
local aB=a:get_latest_state(e or"main",capabilities.switchLevel.ID,"level")return Z(aB)or 0
end
local function ar(a,e)
local l=e or"main"if type(a)~="table"then
return 0
end
local b=h(a)local aF=J.by_emit_name[
b and b.minimum_brightness_capability or"ef00Ts0601MinimumBrightness"]if type(aF)~="table"or not a:supports_capability_by_id(aF.capability_id,l)then
return 0
end
local bm=a:get_latest_state(l,aF.capability_id,aF.attribute_name)local aR=tonumber(bm)if aR==nil or aR<=0 then
return 0
end
return Z(math.ceil(aR*100/aF.default_range.maximum))or 0
end
local function aJ(a,e,aB)
local l=e or"main"if type(a)~="table"or not a:supports_capability_by_id(capabilities.switchLevel.ID,l)then
return
end
a:emit_component_event({id=l},capabilities.switchLevel.level(aB))
end
local function af(a,d)
local e,H=d and d.component or"main",d and d.args and d.args.stepSize or nil
H=tonumber(H)if H==nil then
return
end
H=math.floor(H+0.5)if H<-100 then
H=-100
elseif H>100 then
H=100
end
local D=Z(aX(a,e)+H)if D==nil then
return
end
local bd=ar(a,e)if D<bd then
D=bd
end
if D>0 then
aI(a,d,"switch",true)end
local j=aI(a,d,"brightness",D)if D==0 then
j=aI(a,d,"switch",false)or j
end
if j then
aJ(a,e,D)if D==0 then
u(a,d,false)else
u(a,d,true)end
end
end
local function aA()
local i={}for _,bX in ipairs(bf)do
local br,cmd_name,cd,ao,bG=bX[1],bX[2],bX[3],bX[4],bX[5]if i[br]==nil then
i[br]={}end
i[br][cmd_name]=function(_,a,d)
local m=ao
if type(ao)=="function"then
m=ao(d)elseif type(ao)=="string"and d.args and d.args[ao]~=nil then
m=d.args[ao]end
local b=h(a)if bG and(b==nil or b.auto_on_before_light_command~=false)then
aI(a,d,"switch",true)end
local j=aI(a,d,cd,m)if j then
local bE=aE[br ..":"..cmd_name]if bE~=nil then
aH(a,d.component,bE,2)end
end
end
end
k.register_handlers(i)local W={}for _,aY in pairs(ba.all())do
for _,g in pairs(aY)do
for _,aU in ipairs(g.capability_commands or{})do
local t,command_name=aU.capability_id,aU.command_name

local aG=t ..":"..command_name
if not W[aG]then
W[aG]=true
i[t]=i[t]or{}local bK=i[t][command_name]
i[t][command_name]=function(n,a,d)
local b=h(a)for _,X in ipairs(b and b.capability_commands or{})do
if X.capability_id==t and X.command_name==command_name then
local m=X.value
if X.argument_name~=nil then
m=d.args and d.args[X.argument_name]or nil
end
return aI(a,d,X.mapping_name,m)end
end
if bK~=nil then return bK(n,a,d)end
end
end
end
end
end
i[capabilities.switch.ID]=i[capabilities.switch.ID]or{}
i[capabilities.switch.ID][capabilities.switch.commands.on.NAME]=function(n,a,d)
ap.route{driver=n,device=a,command=d,value=true,uses_zcl_on_off=aN,send_named=aI,
begin_power_poll_burst=function(be)
local b=h(be)if b~=nil and b.zcl_clusters~=nil and y.begin_power_poll_burst~=nil then
y.begin_power_poll_burst(be,b.zcl_clusters)end
end,
after_ef00_switch_command=u,default_handler=bn}
end
i[capabilities.switch.ID][capabilities.switch.commands.off.NAME]=function(n,a,d)
ap.route{driver=n,device=a,command=d,value=false,uses_zcl_on_off=aN,send_named=aI,after_ef00_switch_command=u,default_handler=bj}
end
i[as]={
[ae]=function(_,a,d)
af(a,d)
end
}i[capabilities.alarm.ID]={
[capabilities.alarm.commands.off.NAME]=function(_,a,d)
local j=w(a,d.component,aT,false,T,0)if not j then
j=N(a,d,"off")end
if j then
V(a,d.component,"off")end
end,
[capabilities.alarm.commands.siren.NAME]=function(_,a,d)
local j=w(a,d.component,E,false,B,z)if not j then
j=N(a,d,"siren")end
if j then
V(a,d.component,"siren")end
end,
[capabilities.alarm.commands.strobe.NAME]=function(_,a,d)
local j=w(a,d.component,E,true,T,z)if not j then
j=N(a,d,"strobe")end
if j then
V(a,d.component,"strobe")end
end,
[capabilities.alarm.commands.both.NAME]=function(_,a,d)
local j=w(a,d.component,E,true,B,z)if not j then
j=N(a,d,"both")end
if j then
V(a,d.component,"both")end
end
}i[capabilities.windowShadePreset.ID]={
[capabilities.windowShadePreset.commands.setPresetPosition.NAME]=function(_,a,d)
local aB=d.args and d.args.position or nil
if type(aB)~="number"then
return
end
a:set_field(aj(d.component),aB,{persist=true})a:emit_component_event({id=d.component},capabilities.windowShadePreset.position(aB))
end,
[capabilities.windowShadePreset.commands.presetPosition.NAME]=function(_,a,d)
local aB=F(a,d.component)aI(a,d,"cover_position",aB)
end
}i[capabilities.energyMeter.ID]=i[capabilities.energyMeter.ID]or{}i[capabilities.energyMeter.ID][capabilities.energyMeter.commands.resetEnergyMeter.NAME]=
bJ.handle_reset
i[capabilities.refresh.ID]={
[capabilities.refresh.commands.refresh.NAME]=function(n,a)
local b=h(a)if b==nil then
return
end
if type(b.parent_refresh)=="function"then
b.parent_refresh(a,b,n)return
end
if b.datapoints and b.refresh_state_query~=false then
b:send_state_request(a)end
if b.zcl_clusters then
if type(b.zcl_refresh_before_read_all)=="function"then
b.zcl_refresh_before_read_all(a,b)end
y.read_all_attributes(a,b.zcl_clusters)end
end
}if f~=nil then
i[f.capability_id]=i[f.capability_id]or{}
i[f.capability_id][f.command_name]=function(_,a,d)
local b=h(a)if b==nil then
return
end
local m=d.args and d.args[f.argument_name]or nil
if b.zcl_clusters~=nil then
y.set_power_poll_interval(a,b.zcl_clusters,m)return
end
if not C(a,b)then
return
end
local bL=v(m)if bL==nil then
return
end
a:set_field(L,bL,{persist=true})ad(a,b)
end
end
if q~=nil then
i[q.capability_id]=i[q.capability_id]or{}
i[q.capability_id][q.command_name]=function(_,a,d)
local b=h(a)if b==nil or b.ir_controller~=true then
return
end
local m=d.args and d.args[q.argument_name]or nil
if m=="start"then
y.start_ir_learning(a,b)elseif m=="stop"then
y.stop_ir_learning(a,b)end
end
end
if p~=nil then
i[p.capability_id]=i[p.capability_id]or{}
i[p.capability_id][p.command_name]=function(_,a,d)
local b=h(a)if b==nil or b.ir_controller~=true then
return
end
local bg=d.args or{}local m=bg[p.argument_name]if type(m)~="string"and type(bg.value)=="string"then
m=bg.value
end
if type(m)~="string"or m==""then
return
end
y.send_ir_code(a,b,m)
end
end
return i
end
local bv={supported_capabilities={},additional_zcl_profiles=x,zigbee_handlers={cluster=aO(),global=y.build_zigbee_global_handlers(h),attr=y.build_zigbee_attr_handlers(h),zdo={[aw]=aQ}},lifecycle_handlers={
init=function(n,a)
if bw(a)then
ai(n,a)return
end
local g=ac(a)local aq=g and g.valid_parent_profiles
if g and g.profile and a.profile.id~=g.profile and
not(type(g.parent_profile_matches)=="function"and g.parent_profile_matches(a))and
(type(aq)~="table"or aq[a.profile.id]~=true)then
a:try_update_metadata{profile=g.profile}end
S.apply(a,g)ab(a,g,true)k.emit_driver_message(a,"Custom motion controls initialized.")local b=h(a)bb(a,b)at.start_daily(a)M(a)k.maybe_request_initial_custom_state(a,b)
end,
doConfigure=function(n,a)
al(n,a,h(a))
end,
driverSwitched=function(n,a)
local b=h(a)if b==nil then
return
end
al(n,a,b)a:try_update_metadata{provisioning_state="PROVISIONED"}
end,
infoChanged=function(n,a,_,bg)
if not bg.old_st_store then
return
end
local g,aM=ac(a),a.profile.id~=bg.old_st_store.profile.id
if aM then
S.apply(a,g)al(n,a,h(a))end
local b=h(a)if g~=nil and type(g.preferences_changed)=="function"then
g.preferences_changed(a,bg.old_st_store.preferences)end
if b then
b:apply_preferences_changed(a,bg.old_st_store.preferences)if b.zcl_clusters then
y.emit_power_polling_state(a,b.zcl_clusters)else
R(a,b)end
end
at.start_daily(a)M(a)ab(a,g,aM)
end
},capability_handlers=aA(),health_check=false}local bI=require"st.zigbee"local n=bI("tuya-universal",bv)local bu=n.zigbee_message_dispatcher
local cb=bu.dispatch
function bu:dispatch(n,a,bk,...)
if y.retry_reporting_on_rx then y.retry_reporting_on_rx(a,bk)end
local b=h(a)if b and b.zigbee_message_handler then
b.zigbee_message_handler(a,bk)end
if a:supports_capability_by_id(capabilities.signalStrength.ID,"main")then
local bS={visibility={displayed=false}}a:emit_event(capabilities.signalStrength.lqi(bk.lqi.value,bS))if bk.rssi.value<=0 then
a:emit_event(capabilities.signalStrength.rssi({value=bk.rssi.value,unit="dBm"},bS))end
end
return cb(self,n,a,bk,...)
end
n:run()
