local remotes=require "contracts.families.zcl.controls.remotes"
local advanced=require "contracts.families.zcl.controls.advanced"
local scene=require "contracts.families.zcl.controls.scene"
local excellux=require "contracts.families.zcl.controls.excellux"
local security=require "contracts.families.zcl.controls.security"
local doorbell=require "contracts.families.zcl.controls.doorbell"
local dimming=require "contracts.families.zcl.controls.dimming"
local scene_switches=require "contracts.families.zcl.controls.scene_switches"
local ir=require "contracts.families.zcl.controls.ir"
local catalogs={
remotes,
advanced,
scene,
excellux,
security,
doorbell,
dimming,
scene_switches,
ir,
}
local registrations={}
for _,catalog in ipairs(catalogs)do
for _,registration in ipairs(catalog.registrations)do
registrations[#registrations + 1]=registration
end
end
return{
id="zcl.controls",
registrations=registrations,
}
