local capability_support={}
local function profile_components(device)
if type(device)~="table" then
return nil
end
local profile=device.profile
if type(profile)~="table" and type(device.st_store)=="table" then
profile=device.st_store.profile
end
return type(profile)=="table" and profile.components or nil
end
local function component_has_capability(component,capability_id)
local declared=type(component)=="table" and component.capabilities or nil
if type(declared)~="table" then
return false
end
if declared[capability_id]~=nil then
return true
end
for _,capability in pairs(declared)do
if type(capability)=="table" and capability.id==capability_id then
return true
end
end
return false
end
function capability_support.supports(device,capability_id,component_id)
if type(device)~="table" or type(capability_id)~="string" or capability_id=="" then
return false
end
component_id=component_id or "main"
if type(device.supports_capability_by_id)=="function" then
return device:supports_capability_by_id(capability_id,component_id)
end
local components=profile_components(device)
local component=type(components)=="table" and components[component_id]or nil
return component_has_capability(component,capability_id)
end
return capability_support
