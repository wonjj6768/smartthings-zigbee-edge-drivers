local J,n,D,A,f,e,Q=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.zcl",require"st.capabilities",require"st.zigbee.data_types",require"st.zigbee.cluster_base"local q,M=D.definition_registry()
local function s(c,j,t)
return type(c)=="number"and c==c and c>=j and c<=t
end
local function z(c)
local C=c*2
local u,R=math.floor(C),string.unpack("<I8",string.pack("<d",C))local K,L=((R>>52)&2047)-1022,(R&0xFFFFFFFFFFFFF)|0x10000000000000

if L*20>=(u*20+9)*(1<<(53-K))then u=u+1 end
return u*50
end
local function x(c,_,h,a)
local rx=h.zb_rx
for _,o in ipairs(rx.body.zcl_body.attr_records or{})do
if o.attr_id.value==a.attribute_id and o.data==h.typed_value then
if(o.status and o.status.value~=0)or o.data_type.value~=a.data_type.ID then return end
c=type(c)=="table"and c.value or c
if type(c)=="number"and c%1==0 then return c end
end
end
end
local function k(B,j,t)
return function(c,b,h,a)
c=x(c,b,h,a)if c~=nil and s(c/B,j,t)then return c/B end
end
end
local function v(X)
return function(c,b,h,a)return X[x(c,b,h,a)]end
end
local function p(b,a,c)
if c==nil then return false end
local g=Q.write_attribute(b,e.ClusterId(a.cluster_id),e.AttributeId(a.attribute_id),a.data_type(c)):to_endpoint(b:get_endpoint(a.cluster_id))if a.mfg_code then
g.body.zcl_header.frame_ctrl:set_mfg_specific()g.body.zcl_header.mfg_code=e.Uint16(a.mfg_code)end
g.body.zcl_header.frame_ctrl:set_disable_default_response()return pcall(b.send,b,g)
end
local function y(b,a,c)
local j=a.attribute_id==18 and 16 or 18
return p(b,a,s(c,j,30)and z(c)or nil)
end
local O,P,U,V,F,G,i={[0]="off",[1]="auto",[3]="cool",[4]="heat",[5]="emergency heat",[6]="precooling",[7]="fanonly",[8]="dryair",[9]="asleep"},{off=0,auto=1,cool=3,heat=4,fanonly=7,dryair=8},{[0]="off",[1]="low",[2]="medium",[3]="high",[4]="on",[5]="auto",[6]="smart"},{off=0,low=1,medium=2,high=3,auto=5},{[0]="fully_closed",[1]="fully_closed",[2]="fully_open",[3]="quarter_open",[4]="half_open",[5]="three_quarters_open"},{fully_closed=1,fully_open=2,quarter_open=3,half_open=4,three_quarters_open=5},{}
local function d(N,id,ac,ab,aa,Y,H,I,w)
i[#i+1]=J.cluster_attribute(N,id,{name=ac,data_type=ab,from_device=aa,emit=Y,sender=I,mfg_code=w,read_only=I==nil,read_on_configure=false,read_on_refresh=true,suppress_optimistic_state=true,reporting_defaults=H})
end
d(1029,0,"nodon_irb_humidity",e.Uint16,k(100,0,100),n.humidity(),{minimum_interval=10,maximum_interval=3600,reportable_change=100})d(513,0,"nodon_irb_temperature",e.Int16,k(100,-273.15,327.67),n.temperature"C",{minimum_interval=0,maximum_interval=3600,reportable_change=10})d(513,16,"nodon_irb_local_calibration",e.Int8,k(10,-12.8,12.7),n.nodonIrbLocalCalibration(),nil,
function(b,a,c)return p(b,a,s(c,-2.5,2.5)and math.floor(c*10+0.5)or nil)end)
d(513,18,"current_heating_setpoint",e.Int16,k(100,-273.15,327.67),n.heating_setpoint"C",{minimum_interval=0,maximum_interval=3600,reportable_change=10},y)d(513,17,"current_cooling_setpoint",e.Int16,k(100,-327.68,327.67),n.cooling_setpoint"C",{minimum_interval=0,maximum_interval=3600,reportable_change=10},y)d(513,28,"system_mode",e.Enum8,v(O),n.thermostat_mode(),{minimum_interval=0,maximum_interval=3600},
function(b,a,c)return p(b,a,P[c])end)
d(514,0,"nodon_irb_fan",e.Enum8,v(U),n.value(f.airConditionerFanMode.fanMode),{minimum_interval=0,maximum_interval=3600},
function(b,a,c)return p(b,a,type(c)=="string"and V[c:lower()]or nil)end)
d(513,69,"nodon_irb_louver",e.Enum8,v(F),n.nodonIrbLouver(),{minimum_interval=0,maximum_interval=3600},
function(b,a,c)return p(b,a,G[c])end)
d(64642,32769,"nodon_irb_holder_calibration",e.Int16,k(10,-3276.8,3276.7),n.nodonIrbHolderCalibration(),nil,
function(b,a,c)return p(b,a,s(c,-10,10)and math.floor(c*10+0.5)or nil)end,4747)
local function W(b,a)
local g=Q.read_attribute(b,e.ClusterId(a.cluster_id),e.AttributeId(a.attribute_id),a.mfg_code):to_endpoint(b:get_endpoint(a.cluster_id))if a.mfg_code then
g.body.zcl_header.frame_ctrl:set_mfg_specific()g.body.zcl_header.mfg_code=e.Uint16(a.mfg_code)end
g.body.zcl_header.frame_ctrl:set_disable_default_response()return pcall(b.send,b,g)
end
local T={profile="thermostats-nodon-irb",magic_packet=false,initial_custom_state_query=false,zcl_clusters=i,thermostat_supported_modes={"off","heat","cool","auto","dryair","fanonly"},
component_to_endpoint=function(b)return b:get_endpoint(513)end,
protocol_writers={nodon_irb_identify=A.identify},capability_commands={{capability_id="airConditionerFanMode",command_name="setFanMode",mapping_name="nodon_irb_fan",argument_name="fanMode"},{capability_id="concertmirror08464.nodonIrbIdentify",command_name="identify",mapping_name="nodon_irb_identify",value=3},{capability_id="concertmirror08464.nodonIrbIdentify",command_name="setIdentifyTime",mapping_name="nodon_irb_identify",argument_name="identifyTime"}},
runtime_start=function(b)
b:emit_event(f.thermostatMode.supportedThermostatModes({"off","heat","cool","auto","dryair","fanonly"},{visibility={displayed=false}}))b:emit_event(f.thermostatHeatingSetpoint.heatingSetpointRange{value={minimum=16,maximum=30,step=0.5},unit="C"})b:emit_event(f.thermostatCoolingSetpoint.coolingSetpointRange{value={minimum=18,maximum=30,step=0.5},unit="C"})b:emit_event(f.airConditionerFanMode.supportedAcFanModes({"off","low","medium","high","auto"},{visibility={displayed=false}}))
end,
parent_refresh=function(b,m)
if m.zcl_refresh_before_read_all then m.zcl_refresh_before_read_all(b,m)end
for _,a in ipairs(i)do W(b,a)end
end,
configure=function(S,b)
local Z=S.environment_info.hub_zigbee_eui
for E=1,8 do
local a=i[E]local r=b:get_endpoint(a.cluster_id)if E==2 or E==7 then J.bind_cluster(b,a.cluster_id,Z,r)end
local l=a.reporting_defaults
if l then
J.bind_cluster(b,a.cluster_id,Z,r)J.configure_reporting(b,{cluster=a.cluster_id,attribute=a.attribute_id,data_type=a.data_type,minimum_interval=l.minimum_interval,maximum_interval=l.maximum_interval,reportable_change=l.reportable_change},r,{defer_on_override=true,disable_default_response=true})end
W(b,a)end
end
}M(T,{D.create_fingerprint("NodOn","IRB-4-1-00")})J.attach_reporting_capabilities(q,{{1,"rpt-iyj"}})return{id="zcl.thermostats.nodon_irb",registrations=q}
