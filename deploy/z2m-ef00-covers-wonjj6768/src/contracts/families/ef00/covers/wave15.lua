local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function custom(name)
return assert(emit[name],"missing Wave15 cover emitter: " .. name)()
end
local function reverse_enabled(device)
return type(device)=="table"
and type(device.preferences)=="table"
and device.preferences.reverse==true
end
local function cover_position_converter()
return converter.from_to(
function(value,device)
local numeric=tonumber(value)
if numeric==nil then return nil end
return reverse_enabled(device)and 100 - numeric or numeric
end,
function(value,device)
local numeric=tonumber(value)
if numeric==nil then return nil end
return reverse_enabled(device)and 100 - numeric or numeric
end
)
end
local function cover_action_converter()
return converter.from_to(
function(value)
return({[0]="open",[1]="paused",[2]="closed"})[tonumber(value)]
end,
function(value)
return({open=0,stop=1,pause=1,close=2})[value]
end
)
end
local shade_level_event=emit.shade_level()
local shade_state_event=emit.shade_state()
local function emit_cover_position(device,value,dp_info,context)
local events={}
local level=shade_level_event(device,value,dp_info,context)
if level ~=nil then events[#events + 1]=level end
local state_value=value <=0 and "closed" or(value >=100 and "open" or "partially open")
local state=shade_state_event(device,state_value,dp_info,context)
if state ~=nil then events[#events + 1]=state end
return #events > 0 and events or nil
end
local erc_six={
profile="covers-wave15-box-erc2206z",
package_group="rf-roller-shutter",
transport_classification="EF00_DP",
z2m_converter_source="modernExtend.dp*",
wire_cluster="manuSpecificTuya",
magic_packet=true,
query_on_configure=false,
time_start="off",
datapoints={
tuya.dp_enum(0x01,{
name="cover_state",transaction=1,
converter=cover_action_converter(),emit=emit.shade_state(),
}),
tuya.dp_enum(0x05,{
name="erc_six_direction",transaction=1,
converter=converter.lookup_from_to({forward=0,back=1}),
emit=custom("ercSixDirection"),
}),
tuya.dp_binary(0x65,{
name="erc_six_record_rf",transaction=1,
converter=converter.lookup_from_to({record=true,stop=false}),
emit=custom("ercSixRecordRf"),
}),
tuya.dp_binary(0x66,{
name="erc_six_clear_rf",transaction=1,
converter=converter.lookup_from_to({clear=true,stop=false}),
emit=custom("ercSixClearRf"),
}),
},
}
register_device_definition(erc_six,device_helpers.create_fingerprints("TS0601",{
"_TZE200_ra6wrlgv",
}))
local semicom={
profile="covers-wave15-tuya-semicom-three",
package_group="cover-panel",
transport_classification="EF00_DP",
z2m_converter_source="meta.tuyaDatapoints",
wire_cluster="manuSpecificTuya",
magic_packet=true,
query_on_configure=false,
time_start="off",
datapoints={},
}
for _,row in ipairs({
{1,2,"main"},
{4,5,"cover2"},
{101,102,"cover3"},
})do
semicom.datapoints[#semicom.datapoints + 1]=tuya.dp_enum(row[1],{
name="cover_state",component=row[3],transaction=1,
converter=cover_action_converter(),emit=emit.shade_state(),
})
semicom.datapoints[#semicom.datapoints + 1]=tuya.dp_numeric(row[2],{
name="cover_position",component=row[3],transaction=1,
converter=cover_position_converter(),emit=emit_cover_position,
})
end
register_device_definition(semicom,device_helpers.create_fingerprints("TS0601",{
"_TZE204_7lb6j8wg",
}))
return{
id="ef00.covers.wave15",
registrations=device_definitions,
}
