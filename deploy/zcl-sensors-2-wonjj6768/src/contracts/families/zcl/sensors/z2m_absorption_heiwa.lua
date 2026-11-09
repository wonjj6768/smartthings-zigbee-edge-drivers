local o,k,f,d=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.data_types"local i,c=f.definition_registry()local l,m=k.battery(),k.voltage()
local function n(a)
if type(a)=="table"then return a.value end
return a
end
local function j(p)
return function(a)
a=tonumber(n(a))if a==nil then return nil end
return a/p
end
end
local function h(_,g)
local e
if g>=6.0 then e=100
elseif g>=5.9 then e=75
elseif g>=5.8 then e=50
elseif g>=5.7 then e=25
else e=0 end
return{l(nil,e),m(nil,g)}
end
local b={profile="sensors-heiwa-hpzerad-v1-core",package_group="z2m-zcl-sensors",zcl_clusters={o.cluster_attribute(513,1056,{name="heiwa_display_temperature",endpoint=25,component="main",data_type=d.Int16,read_only=true,read_on_configure=true,minimum_interval=0,maximum_interval=3600,reportable_change=1,from_device=j(10),emit=k.temperature"C"}),o.cluster_attribute(513,1058,{name="heiwa_humidity",endpoint=25,component="main",data_type=d.Uint8,read_only=true,read_on_configure=true,minimum_interval=10,maximum_interval=3600,reportable_change=1,
from_device=function(a)return tonumber(n(a))end,
emit=k.humidity()}),o.cluster_attribute(513,1060,{name="heiwa_co2",endpoint=25,component="main",data_type=d.Uint16,read_only=true,read_on_configure=true,
from_device=function(a)return tonumber(n(a))end,
emit=k.co2()}),o.cluster_attribute(513,1039,{name="heiwa_battery_voltage",endpoint=25,component="main",data_type=d.Uint16,read_only=true,read_on_configure=true,from_device=j(100),emit=h})}}c(b,{f.create_fingerprint("Eurevia","Thermostat_RF_Model_00000000000")})return{id="zcl.sensors.z2m_absorption_heiwa",registrations=i}
