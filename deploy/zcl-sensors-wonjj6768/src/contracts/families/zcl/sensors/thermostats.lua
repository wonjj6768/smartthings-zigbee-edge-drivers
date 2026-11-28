local i,q=require"protocol.zcl",require"contracts.helpers.family"local k,j=q.create_fingerprint,require"st.capabilities"
local m,g=q.definition_registry()
local function d(x,e)
e=e or{}
local function c()
return{endpoint=e.endpoint,component=e.component}
end
local b={e.temperature_measurement==true and i.temperature(c())or i.local_temperature(c()),i.heating_setpoint(c()),i.thermostat_operating_state(c())}if e.system_mode~=false then
b[#b+1]=i.system_mode(c())end
if e.cooling==true then
b[#b+1]=i.cooling_setpoint(c())end
if e.fan==true then
b[#b+1]=i.fan_mode(c())end
if e.battery==true then
b[#b+1]=i.battery{endpoint=e.endpoint,component=e.component,scale=e.battery_scale}end
if e.battery_voltage==true then
b[#b+1]=i.battery_voltage(c())end
if e.humidity==true then
b[#b+1]=i.humidity(c())end
if e.power==true then
b[#b+1]=i.power()end
if e.energy==true then
b[#b+1]=i.energy()end
if e.current==true then
b[#b+1]=i.current()end
return{profile=x,zcl_clusters=b}
end
local v,n,f=d"thermostats-thermostat",d("thermostats-thermostat-battery",{battery=true}),d("thermostats-centralite-thermostat",{battery=true,cooling=true,fan=true})for _,s in ipairs(f.zcl_clusters)do
if s.name=="fan_mode"then
s.emit=function(_,y)
return j.airConditionerFanMode.fanMode(y)
end
end
end
f.capability_commands={{capability_id="airConditionerFanMode",command_name="setFanMode",mapping_name="fan_mode",argument_name="fanMode"}}
f.runtime_start=function(t)
t:emit_component_event({id="main"},j.airConditionerFanMode.supportedAcFanModes({"auto","on"},{visibility={displayed=false}}))
end local o=d("thermostats-schneider-room-thermostat-pending",{
battery=true,battery_scale=1,battery_voltage=true,humidity=true,system_mode=false,temperature_measurement=true})local a=d("thermostats-ecozy-thermostat",{battery=true,endpoint=3})a.thermostat_supported_modes={"off","auto","heat"}a.heating_setpoint_range={minimum=7,maximum=30,step=1,unit="C"}
a.runtime_start=function(t)
t:emit_component_event({id="main"},j.thermostatMode.supportedThermostatModes(a.thermostat_supported_modes,{visibility={displayed=false}}))t:emit_component_event({id="main"},j.thermostatHeatingSetpoint.heatingSetpointRange{value={minimum=a.heating_setpoint_range.minimum,maximum=a.heating_setpoint_range.maximum,step=a.heating_setpoint_range.step},unit=a.heating_setpoint_range.unit})
end
a.zcl_clusters[#a.zcl_clusters+1]=i.local_temperature_calibration{endpoint=3}a.zcl_clusters[#a.zcl_clusters+1]=i.pi_heating_demand{endpoint=3}local p,l,r,h=d("thermostats-thermostat-humidity-power-energy-current",{humidity=true,power=true,energy=true,current=true}),{profile="thermostats-schneider-heating-power-energy-pending",zcl_clusters={i.local_temperature{endpoint=1},i.heating_setpoint{endpoint=1},i.thermostat_operating_state{endpoint=1},i.system_mode{endpoint=1},i.power{endpoint=2},i.energy{endpoint=2}}},d("thermostats-fcu-thermostat",{endpoint=9,component="main",fan=true}),{profile="thermostats-hive-dual-thermostat-pending",zcl_clusters={}}for _,u in ipairs{5,6}do
local w=u==5 and"main"or"water"for _,s in ipairs(d("unused",{endpoint=u,component=w}).zcl_clusters)do
h.zcl_clusters[#h.zcl_clusters+1]=s
end
end
g(n,{k("Eurotronic","SPZB0001")})g(n,{k("Danfoss","0x0042"),k("Danfoss","0x0200"),k("Danfoss","0x0210"),k("Danfoss","0x0211"),k("Danfoss","0x8020"),k("Danfoss","0x8021"),k("Danfoss","0x8030"),k("Danfoss","0x8031"),k("Danfoss","0x8034"),k("Danfoss","0x8035"),k("Danfoss","0x8040"),k("Danfoss","0x8041")})g(f,{k("Centralite","3157100"),k("Centralite","3157100-E")})g(v,{k("Danfoss","devi_f"),k("devi","devi_f"),k("Sinopé","TH1320ZB-04"),k("computime","PUMM01102")})g(o,{k("Schneider Electric","Thermostat")})g(a,{k("eCozy","Thermostat")})g(l,{k("Schneider Electric","CCTFR6700"),k("Schneider Electric","CCTFR6710")})g(p,{k("Namron","4566702"),k("Namron","4566703"),k("Namron","4512783"),k("Namron","4512784")})g(h,{k("Hive","SLR2d")})g(r,{k("Salus Controls","FC600NH")})i.attach_reporting_capabilities(m,{{1,"rpt-sxb"},{2,"rpt-sxb"},{3,"rpt-zjoj"},{4,"rpt-dsh"},{5,"rpt-tza"},{6,"rpt-tpd"},{7,"rpt-cfc"},{8,"rpt-zdh"},{9,"rpt-suw",{zr020100005="LocalTemp",zr020100006="LocalTempTwo",zr020100125="HeatSet",zr020100126="HeatSetTwo",zr0201001c5="Mode",zr0201001c6="ModeTwo",zr020100295="State",zr020100296="StateTwo"}},{10,"rpt-fsr"}})return{id="zcl.sensors.thermostats",registrations=m}
