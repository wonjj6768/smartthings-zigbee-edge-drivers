local pir=require "contracts.families.ef00.motion.pir"
local lincukoo_szlm04u=require "contracts.families.ef00.lincukoo_szlm04u"
local aoyan_ay_204z=require "contracts.families.ef00.aoyan_ay_204z"
local registrations={}
for _,registration in ipairs(pir.registrations)do
registrations[#registrations + 1]=registration
end
registrations[#registrations + 1]=lincukoo_szlm04u.definition
registrations[#registrations + 1]=aoyan_ay_204z.definition
return{
id="ef00.motion_pir",
registrations=registrations,
}
