local lights=require "contracts.families.zcl.lights.lights"
local dimmers=require "contracts.families.zcl.lights.dimmers"
local miboxer=require "contracts.families.zcl.lights.miboxer"
local fans=require "contracts.families.zcl.lights.fans"
local retail=require "contracts.families.zcl.lights.retail"
local ikea=require "contracts.families.zcl.lights.ikea"
local schneider=require "contracts.families.zcl.lights.schneider"
local catalogs={
lights,
dimmers,
miboxer,
fans,
retail,
ikea,
schneider,
}
local registrations={}
for _,catalog in ipairs(catalogs)do
for _,registration in ipairs(catalog.registrations)do
registrations[#registrations + 1]=registration
end
end
return{
id="zcl.lights",
registrations=registrations,
}
