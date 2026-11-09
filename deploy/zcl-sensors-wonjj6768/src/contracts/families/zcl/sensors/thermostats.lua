local h,p=require"protocol.zcl",require"contracts.helpers.family"local i,r=p.create_fingerprint,require"st.capabilities"
local k,f=p.definition_registry()
local function d(x,e)
e=e or{}
local function c()
return{endpoint=e.endpoint,component=e.component}
end
local b={e.temperature_measurement==true and h.temperature(c())or h.local_temperature(c()),h.heating_setpoint(c()),h.thermostat_operating_state(c())}if e.system_mode~=false then
b[#b+1]=h.system_mode(c())end
if e.cooling==true then
b[#b+1]=h.cooling_setpoint(c())end
if e.fan==true then
b[#b+1]=h.fan_mode(c())end
if e.battery==true then
b[#b+1]=h.battery{endpoint=e.endpoint,component=e.component,scale=e.battery_scale}end
if e.battery_voltage==true then
b[#b+1]=h.battery_voltage(c())end
if e.humidity==true then
b[#b+1]=h.humidity(c())end
if e.power==true then
b[#b+1]=h.power()end
if e.energy==true then
b[#b+1]=h.energy()end
if e.current==true then
b[#b+1]=h.current()end
return{profile=x,zcl_clusters=b}
end
local t,l,o,m,a=d"thermostats-thermostat",d("thermostats-thermostat-battery",{battery=true}),d("thermostats-centralite-thermostat",{battery=true,cooling=true,fan=true}),d("thermostats-schneider-room-thermostat-pending",{battery=true,battery_scale=1,battery_voltage=true,humidity=true,system_mode=false,temperature_measurement=true}),d("thermostats-ecozy-thermostat",{battery=true,endpoint=3})a.thermostat_supported_modes={"off","auto","heat"}a.heating_setpoint_range={minimum=7,maximum=30,step=1,unit="C"}
a.runtime_start=function(v)
v:emit_component_event({id="main"},r.thermostatMode.supportedThermostatModes(a.thermostat_supported_modes,{visibility={displayed=false}}))v:emit_component_event({id="main"},r.thermostatHeatingSetpoint.heatingSetpointRange{value={minimum=a.heating_setpoint_range.minimum,maximum=a.heating_setpoint_range.maximum,step=a.heating_setpoint_range.step},unit=a.heating_setpoint_range.unit})
end
a.zcl_clusters[#a.zcl_clusters+1]=h.local_temperature_calibration{endpoint=3}a.zcl_clusters[#a.zcl_clusters+1]=h.pi_heating_demand{endpoint=3}local n,j,q,g=d("thermostats-thermostat-humidity-power-energy-current",{humidity=true,power=true,energy=true,current=true}),{profile="thermostats-schneider-heating-power-energy-pending",zcl_clusters={h.local_temperature{endpoint=1},h.heating_setpoint{endpoint=1},h.thermostat_operating_state{endpoint=1},h.system_mode{endpoint=1},h.power{endpoint=2},h.energy{endpoint=2}}},d("thermostats-fcu-thermostat",{endpoint=9,component="main",fan=true}),{profile="thermostats-hive-dual-thermostat-pending",zcl_clusters={}}for _,s in ipairs{5,6}do
local u=s==5 and"main"or"water"for _,w in ipairs(d("unused",{endpoint=s,component=u}).zcl_clusters)do
g.zcl_clusters[#g.zcl_clusters+1]=w
end
end
f(l,{i("Eurotronic","SPZB0001")})f(l,{i("Danfoss","0x0042"),i("Danfoss","0x0200"),i("Danfoss","0x0210"),i("Danfoss","0x0211"),i("Danfoss","0x8020"),i("Danfoss","0x8021"),i("Danfoss","0x8030"),i("Danfoss","0x8031"),i("Danfoss","0x8034"),i("Danfoss","0x8035"),i("Danfoss","0x8040"),i("Danfoss","0x8041")})f(o,{i("Centralite","3157100"),i("Centralite","3157100-E")})f(t,{i("Danfoss","devi_f"),i("Sinopé","TH1320ZB-04"),i("computime","PUMM01102")})f(m,{i("Schneider Electric","Thermostat")})f(a,{i("eCozy","Thermostat")})f(j,{i("Schneider Electric","CCTFR6700"),i("Schneider Electric","CCTFR6710")})f(n,{i("Namron","4566702"),i("Namron","4566703"),i("Namron","4512783"),i("Namron","4512784")})f(g,{i("Hive","SLR2d")})f(q,{i("Salus Controls","FC600NH")})h.attach_reporting_capabilities(k,{{1,"rpt-sxb"},{2,"rpt-sxb"},{3,"rpt-zjo"},{4,"rpt-dsh"},{5,"rpt-tza"},{6,"rpt-tpd"},{7,"rpt-cfc"},{8,"rpt-zdh"},{9,"rpt-suw",{zr020100005="LocalTemp",zr020100006="LocalTempTwo",zr020100125="HeatSet",zr020100126="HeatSetTwo",zr0201001c5="Mode",zr0201001c6="ModeTwo",zr020100295="State",zr020100296="StateTwo"}},{10,"rpt-fsr"}})return{id="zcl.sensors.thermostats",registrations=k}
