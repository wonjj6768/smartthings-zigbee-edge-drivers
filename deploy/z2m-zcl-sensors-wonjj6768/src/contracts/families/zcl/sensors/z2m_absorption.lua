local ewelink_7037=require "contracts.families.zcl.sensors.z2m_absorption_ewelink_7037"
local water=require "contracts.families.zcl.sensors.z2m_absorption_water"
local linknlink=require "contracts.families.zcl.sensors.linknlink"
local shelly_presence=require "contracts.families.zcl.sensors.shelly_presence"
local catalogs={ewelink_7037,water,linknlink,shelly_presence}
local registrations={}
for _,catalog in ipairs(catalogs)do
for _,registration in ipairs(catalog.registrations)do
registrations[#registrations + 1]=registration
end
end
return{
id="zcl.sensors.z2m_absorption",
registrations=registrations,
}
