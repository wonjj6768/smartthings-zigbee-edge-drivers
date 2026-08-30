local zcl=require "protocol.zcl"
local device_helpers=require "contracts.helpers.family"
local capabilities=require "st.capabilities"
local zigbee_constants=require "st.zigbee.constants"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function tuya_pressed(value)
if type(value)=="boolean" then
return value
end
if type(value)=="table" and type(value.is_alarm1_set)=="function" then
return value:is_alarm1_set()
end
if type(value)=="table" and value.value ~=nil then
value=value.value
end
if type(value)~="number" then
return nil
end
return value % 2 ~=0
end
local function heiman_pressed(value)
if type(value)=="table" and value.value ~=nil then
value=value.value
end
return value==0x8000 or value==0x8004
end
local function extract_zone_status(zb_rx)
local zone_status=zb_rx and zb_rx.body and zb_rx.body.zcl_body and zb_rx.body.zcl_body.zone_status or nil
if zone_status==nil then
return nil
end
return{
raw_value=zone_status.value or zone_status,
typed_value=zone_status,
}
end
local function emit_pressed(_,value)
if value==true then
return capabilities.button.button.pushed({state_change=true})
end
end
local function build_doorbell_button(pressed_converter)
return{
profile="buttons-doorbell-battery-tamper-low",
button_actions={"pushed"},
button_count=1,
zcl_clusters={
zcl.ias_zone({
name="doorbell_button",
emit=emit_pressed,
from_device=pressed_converter,
prefer_typed_value=true,
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status,
}),
zcl.tamper(),
zcl.battery_low(),
zcl.battery(),
},
}
end
local tuya_doorbell_button=build_doorbell_button(tuya_pressed)
local heiman_doorbell_button=build_doorbell_button(heiman_pressed)
register_device_definition(tuya_doorbell_button,device_helpers.create_fingerprints("TS0211",{
"_TZ1800_akzvkzqq",
"_TZ1800_ladpngdx",
}))
register_device_definition(heiman_doorbell_button,{
device_helpers.create_fingerprint("HEIMAN","DoorBell-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN","DoorBell-EM"),
})
return{
id="zcl.controls.doorbell",
registrations=device_definitions,
}
