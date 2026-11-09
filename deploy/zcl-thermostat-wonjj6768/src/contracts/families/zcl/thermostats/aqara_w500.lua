local f,e,o,r,c,t=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.capabilities",require"st.zigbee.data_types",require"st.zigbee.cluster_base"local j,l=o.definition_registry()local d=4447
local function k(beta)
local x,closest_high
for E=16256,18431 do
local n=string.unpack(">f",string.pack(">I2I2",E,beta))if n~=math.floor(n)and
(x==nil or math.abs(n-beta)<math.abs(x-beta))then
x,closest_high=n,E
end
end
local A,B=math.floor(closest_high/128)-127,((closest_high%128)*65536+beta)/8388608

return c.SinglePrecisionFloat(0,A,B)
end
local function i(a)
if a==math.floor(a)then return a end
return string.unpack(">I2",string.pack(">f",a),3)
end
local function g(b,m)
if m then
for _,p in ipairs(m.zb_rx.body.zcl_body.attr_records or{})do
if p.data and p.attr_id.value==789 then
local a=p.data.value
b:set_field("aqw500_ntc_r25",a>=1000 and a/1000 or a,{persist=true})elseif p.data and p.attr_id.value==790 then
b:set_field("aqw500_ntc_beta",i(p.data.value),{persist=true})end
end
end
local y,beta=b:get_field"aqw500_ntc_r25",b:get_field"aqw500_ntc_beta"if beta==nil or beta==3950 then
return({[10]="ntc_10k",[50]="ntc_50k",[100]="ntc_100k"})[y]or"custom"end
return"custom"
end
local function q(a,b)
local w=a>=1000 and a/1000 or a
b:set_field("aqw500_ntc_r25",w,{persist=true})return w
end
local function v(a,b)
local beta=i(a)b:set_field("aqw500_ntc_beta",beta,{persist=true})return beta
end
local function u(b,F,a)
local y,beta=({ntc_10k=10,ntc_50k=50,ntc_100k=100})[a],3950
if a=="custom"then
y,beta=b:get_field"aqw500_ntc_r25",b:get_field"aqw500_ntc_beta"if y==nil or beta==nil then return false end
end
b:send(t.write_manufacturer_specific_attribute(b,64704,789,d,c.Uint32,y):to_endpoint(1))b:send(t.write_manufacturer_specific_attribute(b,64704,790,d,c.SinglePrecisionFloat,k(beta)):to_endpoint(1))b:set_field("aqw500_ntc_r25",y,{persist=true})b:set_field("aqw500_ntc_beta",beta,{persist=true})b:emit_component_event({id="main"},e.aqW500NtcR25()(b,y))b:emit_component_event({id="main"},e.aqW500NtcBeta()(b,beta))b:emit_component_event({id="main"},e.aqW500NtcSensorType()(b,a))return true
end
local z={profile="thermostats-aqara-w500",thermostat_supported_modes={"off","heat"},heating_setpoint_range={minimum=5,maximum=40,step=0.5,unit="C"},
runtime_start=function(b)
b:emit_component_event({id="main"},r.thermostatMode.supportedThermostatModes{"off","heat"})b:emit_component_event({id="main"},r.thermostatHeatingSetpoint.heatingSetpointRange{value={minimum=5,maximum=40,step=0.5},unit="C"})
end,
zcl_clusters={f.local_temperature{endpoint=1,read_only=true,minimum_interval=0,maximum_interval=3600,reportable_change=10},f.thermostat_heating_setpoint{name="current_heating_setpoint",endpoint=1,scale=100,emit=e.heating_setpoint"C",read_on_configure=false,
to_device=function(a)return math.max(5,math.min(40,math.floor(a*2+0.5)/2))end
},f.system_mode{endpoint=1,minimum_interval=0,maximum_interval=3600,
from_device=function(a)
a=type(a)=="table"and a.value or a
return({[0]="off",[4]="heat"})[a]
end,
to_device=function(a)return({off=0,heat=4})[a]end
},f.thermostat_operating_state{endpoint=1,read_only=true,minimum_interval=0,maximum_interval=3600},f.relative_humidity{endpoint=1,read_only=true,scale=100,emit=e.humidity(),read_on_configure=true},f.cluster_attribute(2820,1291,{name="power",endpoint=1,data_type=c.Int16,scale=1,emit=e.power(),read_only=true,read_on_configure=true,minimum_interval=10,maximum_interval=65000,reportable_change=5}),f.cluster_attribute(1794,0,{name="energy",endpoint=1,data_type=c.Uint48,scale=1000,emit=e.energy(),read_only=true,read_on_configure=true,minimum_interval=10,maximum_interval=65000,reportable_change=100}),f.cluster_attribute(513,16,{name="aqw500_temperature_calibration",endpoint=1,data_type=c.Int8,emit=e.aqW500TemperatureCalibration(),read_on_configure=true,
from_device=function(a)return a/10 end,
to_device=function(a)return math.floor(a*10+0.5)end
}),f.cluster_attribute(513,35,{name="aqw500_setpoint_hold",endpoint=1,data_type=c.Enum8,emit=e.aqW500SetpointHold(),read_on_configure=false,
from_device=function(a)
a=type(a)=="table"and a.value or a
return({[0]="disabled",[1]="enabled"})[a]
end,
to_device=function(a)return({disabled=0,enabled=1})[a]end
}),f.cluster_attribute(513,36,{name="aqw500_hold_duration",endpoint=1,data_type=c.Uint16,emit=e.aqW500HoldDuration(),read_on_configure=true}),f.cluster_attribute(513,21,{name="aqw500_min_heat_setpoint",endpoint=1,data_type=c.Int16,emit=e.aqW500MinHeatSetpoint(),read_on_configure=true,
from_device=function(a)return a/100 end,
to_device=function(a)return math.floor(a*100+0.5)end
}),f.cluster_attribute(513,22,{name="aqw500_max_heat_setpoint",endpoint=1,data_type=c.Int16,emit=e.aqW500MaxHeatSetpoint(),read_on_configure=true,
from_device=function(a)return a/100 end,
to_device=function(a)return math.floor(a*100+0.5)end
}),f.cluster_attribute(64704,785,{name="aqw500_preset",endpoint=1,mfg_code=d,data_type=c.Uint8,emit=e.aqW500Preset(),read_on_configure=true,
from_device=function(a)return({[1]="home",[2]="away",[3]="sleep",[5]="vacation",[6]="evening",[8]="manual"})[a]end,
to_device=function(a)return({home=1,away=2,sleep=3,vacation=5,evening=6,manual=8})[a]end
}),f.cluster_attribute(64704,784,{name="aqw500_work_state",endpoint=1,mfg_code=d,data_type=c.Uint8,emit=e.aqW500WorkState(),read_only=true,read_on_configure=true,
from_device=function(a)return({[0]="working",[2]="idle"})[a]end
}),f.cluster_attribute(64704,640,{name="aqw500_sensor_source",endpoint=1,mfg_code=d,data_type=c.Uint8,emit=e.aqW500SensorSource(),read_on_configure=true,
from_device=function(a)return({[0]="internal",[1]="external",[2]="ntc"})[a]end,
to_device=function(a)return({internal=0,external=1,ntc=2})[a]end
}),f.cluster_attribute(64704,789,{name="aqw500_ntc_sensor_type",endpoint=1,mfg_code=d,data_type=c.Uint32,write_only=true,suppress_optimistic_state=true,sender=u}),f.cluster_attribute(64704,789,{name="aqw500_ntc_r25",endpoint=1,mfg_code=d,data_type=c.Uint32,from_device=q,
to_device=function(a,b)
b:set_field("aqw500_ntc_r25",a,{persist=true})b:emit_component_event({id="main"},e.aqW500NtcSensorType()(b,g(b)))return a
end,
emit=function(b,a,m)
return{e.aqW500NtcR25()(b,a),e.aqW500NtcSensorType()(b,g(b,m))}
end
}),f.cluster_attribute(64704,790,{name="aqw500_ntc_beta",endpoint=1,mfg_code=d,data_type=c.SinglePrecisionFloat,from_device=v,
to_device=function(a,b)
b:set_field("aqw500_ntc_beta",a,{persist=true})b:emit_component_event({id="main"},e.aqW500NtcSensorType()(b,g(b)))return k(a)
end,
emit=function(b,a,m)
return{e.aqW500NtcBeta()(b,a),e.aqW500NtcSensorType()(b,g(b,m))}
end
}),f.cluster_attribute(64704,627,{name="aqw500_window_detection",endpoint=1,mfg_code=d,data_type=c.Uint8,emit=e.aqW500WindowDetection(),read_on_configure=true,
from_device=function(a)return({[0]="OFF",[1]="ON"})[a]end,
to_device=function(a)return({OFF=0,ON=1})[a]end
}),f.cluster_attribute(64704,513,{name="aqw500_power_outage_memory",endpoint=1,mfg_code=d,data_type=c.Boolean,emit=e.aqW500PowerOutageMemory(),read_on_configure=true,
from_device=function(a)return a and"enabled"or"disabled"end,
to_device=function(a)return a=="enabled"end
}),f.cluster_attribute(64704,631,{name="aqw500_child_lock",endpoint=1,mfg_code=d,data_type=c.Uint8,emit=e.aqW500ChildLock(),read_on_configure=true,
from_device=function(a)return({[0]="UNLOCK",[1]="LOCK"})[a]end,
to_device=function(a)return({UNLOCK=0,LOCK=1})[a]end
}),f.cluster_attribute(64704,780,{name="aqw500_hysteresis",endpoint=1,mfg_code=d,data_type=c.Uint8,emit=e.aqW500Hysteresis(),read_on_configure=true,
from_device=function(a)return a/10 end,
to_device=function(a)return math.floor(a*10+0.5)end
}),f.cluster_attribute(3,65535,{name="aqw500_identify",endpoint=1,write_only=true,suppress_optimistic_state=true,
tx_command_id=0,to_device=function()return string.char(3,0)end
})},
configure=function(D,b)
for _,C in ipairs{513,2820,1794}do
f.bind_cluster(b,C,D.environment_info.hub_zigbee_eui,1)end
end
}l(z,{o.create_fingerprint("Aqara","lumi.airrtc.aeu001")})f.attach_reporting_capabilities(j,{{1,"rpt-lbw"}})return{id="zcl.thermostats.aqara_w500",registrations=j}
