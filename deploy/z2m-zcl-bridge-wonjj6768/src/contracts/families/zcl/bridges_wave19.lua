local zcl=require "protocol.zcl"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local device_management=require "st.zigbee.device_management"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local NAMESPACE="concertmirror08464."
local CLUSTER_ON_OFF=0x0006
local ATTR_ON_OFF=0x0000
local CLUSTER_POWER_CONFIGURATION=0x0001
local CLUSTER_HEIMAN_IR=0xFC82
local HEIMAN_MFG_CODE=0x120B
local function custom(capability_id)
return assert(emit[capability_id],"missing Wave19 bridge emitter: " .. capability_id)()
end
local function emit_main(device,event)
if event ~=nil and type(device.emit_event)=="function" then
device:emit_event(event)
end
end
local kinetic_press_names={
[1]="single",
[2]="double",
[3]="triple",
[4]="quadruple",
[5]="quintuple",
}
local kinetic_action_emitter=custom("candeoRfHubAction")
local function field_get(device,key)
if type(device.get_field)~="function" then return nil end
return device:get_field(key)
end
local function field_set(device,key,value)
if type(device.set_field)=="function" then
device:set_field(key,value,{persist=false})
end
end
local function cancel_timer(device,timer)
if timer==nil then return end
if type(device.thread)=="table" and type(device.thread.cancel_timer)=="function" then
device.thread:cancel_timer(timer)
elseif type(timer)=="table" and type(timer.cancel)=="function" then
timer:cancel()
end
end
local function emit_kinetic_action(device,endpoint,count)
local press=kinetic_press_names[count]
if press==nil then return false end
local event=kinetic_action_emitter(device,string.format("button_%d_%s_pressed",endpoint,press))
if event==nil then return false end
event.state_change=true
emit_main(device,event)
return true
end
local function kinetic_sequence(context)
local header=context and context.zb_rx and context.zb_rx.body and context.zb_rx.body.zcl_header or nil
local seqno=header and header.seqno or nil
local value=type(seqno)=="table" and seqno.value or seqno
return type(value)=="number" and value or nil
end
local function handle_kinetic_press(device,_,context)
local endpoint=tonumber(context and(context.src_endpoint or context.endpoint))
if endpoint==nil or endpoint < 1 or endpoint > 10 or endpoint % 1 ~=0 then return end
local sequence=kinetic_sequence(context)
if sequence ~=nil then
local sequence_field=string.format("__wave19_candeo_rf_sequences_%d",endpoint)
local previous=field_get(device,sequence_field)
if type(previous)~="table" then previous={}end
for _,seen in ipairs(previous)do
if seen==sequence then return end
end
local updated={sequence}
for index=1,math.min(#previous,4)do
updated[#updated + 1]=previous[index]
end
field_set(device,sequence_field,updated)
end
local count_field=string.format("__wave19_candeo_rf_count_%d",endpoint)
local timer_field=string.format("__wave19_candeo_rf_timer_%d",endpoint)
local count=(tonumber(field_get(device,count_field))or 0)+ 1
field_set(device,count_field,count)
local previous_timer=field_get(device,timer_field)
cancel_timer(device,previous_timer)
if type(device.thread)~="table" or type(device.thread.call_with_delay)~="function" then
field_set(device,count_field,0)
field_set(device,timer_field,nil)
emit_kinetic_action(device,endpoint,count)
return
end
local timer=device.thread:call_with_delay(1,function()
local final_count=tonumber(field_get(device,count_field))or 0
field_set(device,count_field,0)
field_set(device,timer_field,nil)
emit_kinetic_action(device,endpoint,final_count)
end,string.format("Candeo RF button %d multi-press",endpoint))
field_set(device,timer_field,timer)
end
local candeo_rf_hub={
profile="bridges-wave19-candeo-rf-hub",
package_group="wave19-bridge",
transport_classification="CUSTOM_ZCL",
z2m_converter_source="fzLocal.kinetic_rf_button_multi_press",
wire_cluster="genOnOff attribute 0x0000 endpoints 1..10",
placeholder_custom_states=false,
zcl_clusters={
zcl.cluster_attribute(CLUSTER_ON_OFF,ATTR_ON_OFF,{
name="candeo_rf_hub_press",
read_only=true,
handler=handle_kinetic_press,
}),
},
}
register_device_definition(candeo_rf_hub,{
device_helpers.create_fingerprint("Candeo","C-RFZB-HUB"),
})
local function body_bytes(zb_rx)
local body=zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
return type(body)=="table" and body.body_bytes or nil
end
local function uint8(value)
local number=tonumber(value)
if number==nil or number % 1 ~=0 or number < 0 or number > 0xFF then return nil end
return number
end
local function parse_pair(value)
if type(value)~="string" then return nil end
local first,second=string.match(value,"^%s*(%d+)%s*[:/,]%s*(%d+)%s*$")
first,second=uint8(first),uint8(second)
if first==nil or second==nil then return nil end
return first,second
end
local function parse_single(value)
if type(value)~="string" and type(value)~="number" then return nil end
if type(value)=="string" then
value=string.match(value,"^%s*(%d+)%s*$")
end
return uint8(value)
end
local function send_heiman_command(device,command_id,payload,context)
return zcl.send_raw_cluster_command(
device,
CLUSTER_HEIMAN_IR,
command_id,
payload,
context and context.endpoint or 1,
nil,
nil,
false
)
end
local function pair_sender(command_id)
return function(device,_,value,context)
local first,second=parse_pair(value)
if first==nil then return false end
return send_heiman_command(device,command_id,string.char(first,second),context)
end
end
local function create_sender(device,_,value,context)
local model_type=parse_single(value)
if model_type==nil then return false end
return send_heiman_command(device,0xF4,string.char(model_type),context)
end
local function list_sender(device,_,_,context)
return send_heiman_command(device,0xF6,"",context)
end
local function command_mapping(name,sender)
return zcl.cluster_attribute(CLUSTER_HEIMAN_IR,nil,{
name=name,
endpoint=1,
write_only=true,
sender=sender,
})
end
local function parse_study_response(zb_rx)
local payload=body_bytes(zb_rx)
if type(payload)~="string" or #payload ~=3 then return nil end
local id,key_code,result=string.byte(payload,1,3)
return{id=id,key_code=key_code,result=result}
end
local function parse_create_response(zb_rx)
local payload=body_bytes(zb_rx)
if type(payload)~="string" or #payload ~=2 then return nil end
local id,model_type=string.byte(payload,1,2)
return{id=id,model_type=model_type}
end
local function compact_devices(records)
local encoded={}
for _,record in ipairs(records)do
local keys={}
for _,key_code in ipairs(record.key_codes)do keys[#keys + 1]=tostring(key_code)end
encoded[#encoded + 1]=string.format("%d:%d:%s",record.id,record.model_type,table.concat(keys,","))
end
local value=table.concat(encoded,";")
if #value > 2048 then return nil end
return value
end
local function parse_list_packet(zb_rx,device,prefix)
local field="__wave19_" .. prefix .. "_ir_list"
local function reject()
field_set(device,field,nil)
return nil
end
local payload=body_bytes(zb_rx)
if type(payload)~="string" or #payload < 3 then return reject()end
local total,packet,length=string.byte(payload,1,3)
if total < 1 or packet < 1 or packet > total or length > 70 or #payload ~=length + 3 then return reject()end
local records={}
local offset=4
local final=#payload
while offset <=final do
if offset + 2 > final then return reject()end
local id,model_type,key_count=string.byte(payload,offset,offset + 2)
if offset + 2 + key_count > final then return reject()end
local key_codes={}
for index=offset + 3,offset + 2 + key_count do
key_codes[#key_codes + 1]=string.byte(payload,index)
end
records[#records + 1]={id=id,model_type=model_type,key_codes=key_codes}
offset=offset + 3 + key_count
end
local state=field_get(device,field)
if packet==1 then
state={total=total,next_packet=1,records={}}
end
if type(state)~="table" or state.total ~=total or state.next_packet ~=packet then
return reject()
end
for _,record in ipairs(records)do state.records[#state.records + 1]=record end
state.next_packet=packet + 1
if packet < total then
field_set(device,field,state)
return nil
end
field_set(device,field,nil)
return compact_devices(state.records)
end
local function emit_value(device,emitter,value,state_change)
if value==nil then return end
local event=emitter(device,value)
if event ~=nil and state_change then event.state_change=true end
emit_main(device,event)
end
local function response_mapping(attribute_id,command_id,extractor,handler)
return zcl.cluster_attribute(CLUSTER_HEIMAN_IR,attribute_id,{
name=string.format("heiman_ir_response_%02x",command_id),
endpoint=1,
read_only=true,
command_id=command_id,
command_extractor=extractor,
handler=handler,
mfg_code=HEIMAN_MFG_CODE,
})
end
local function configure_heiman_ir(driver,device)
device:send(device_management.build_bind_request(
device,
CLUSTER_HEIMAN_IR,
driver.environment_info.hub_zigbee_eui,
1
))
end
local function build_heiman_definition(options)
local capability_prefix=options.capability_prefix
local mapping_prefix=options.mapping_prefix
local action_emit=custom(capability_prefix .. "Action")
local result_emit=custom(capability_prefix .. "ActionResult")
local id_emit=custom(capability_prefix .. "ActionId")
local key_emit=custom(capability_prefix .. "ActionKeyCode")
local model_emit=custom(capability_prefix .. "ActionModelType")
local devices_emit=custom(capability_prefix .. "Devices")
local mappings={}
if options.has_battery then
mappings[#mappings + 1]=zcl.battery({
endpoint=1,
minimum_interval=3600,
maximum_interval=65000,
reportable_change=0,
read_on_configure=true,
})
end
local command_specs={
{"send_key",pair_sender(0xF0)},
{"create_id",create_sender},
{"learn_key",pair_sender(0xF1)},
{"delete_key",pair_sender(0xF3)},
{"request_list",list_sender},
}
for _,spec in ipairs(command_specs)do
mappings[#mappings + 1]=command_mapping(mapping_prefix .. "_" .. spec[1],spec[2])
end
mappings[#mappings + 1]=response_mapping(0xF201,0xF2,parse_study_response,function(device,value)
emit_value(device,action_emit,"learn",true)
emit_value(device,result_emit,value.result==1 and "success" or "error",true)
emit_value(device,key_emit,value.key_code)
if value.result==1 then emit_value(device,id_emit,value.id)end
end)
mappings[#mappings + 1]=response_mapping(0xF501,0xF5,parse_create_response,function(device,value)
emit_value(device,action_emit,"create",true)
emit_value(device,result_emit,value.id==0xFF and "error" or "success",true)
emit_value(device,model_emit,value.model_type)
if value.id ~=0xFF then emit_value(device,id_emit,value.id)end
end)
mappings[#mappings + 1]=response_mapping(0xF701,0xF7,function(zb_rx,device)
return parse_list_packet(zb_rx,device,mapping_prefix)
end,function(device,value)
emit_value(device,devices_emit,value)
end)
local function command(capability_suffix,command_name,argument_name,mapping_suffix,value)
return{
capability_id=NAMESPACE .. capability_prefix .. capability_suffix,
command_name=command_name,
argument_name=argument_name,
mapping_name=mapping_prefix .. "_" .. mapping_suffix,
value=value,
}
end
return{
profile=options.profile,
package_group="wave19-bridge",
transport_classification="CUSTOM_ZCL",
z2m_converter_source="fzLocal/tzLocal.heiman_ir_remote",
wire_cluster="0xFC82 commands F0/F1/F3/F4/F6 responses F2/F5/F7 endpoint 1",
placeholder_custom_states=false,
zcl_clusters=mappings,
configure=configure_heiman_ir,
capability_commands={
command("SendKey","sendKey","key","send_key"),
command("CreateId","createId","modelType","create_id"),
command("LearnKey","learnKey","key","learn_key"),
command("DeleteKey","deleteKey","key","delete_key"),
command("RequestList","requestList",nil,"request_list",true),
},
}
end
local heiman_hs_one=build_heiman_definition({
profile="bridges-wave19-heiman-hs-one-ir",
capability_prefix="heimanHsOneIr",
mapping_prefix="heiman_hs_one_ir",
has_battery=true,
})
local heiman_hs_two=build_heiman_definition({
profile="bridges-wave19-heiman-hs-two-ir",
capability_prefix="heimanHsTwoIr",
mapping_prefix="heiman_hs_two_ir",
has_battery=false,
})
register_device_definition(heiman_hs_one,{
device_helpers.create_fingerprint("HEIMAN","IRControl-EM"),
})
register_device_definition(heiman_hs_two,{
device_helpers.create_fingerprint("HEIMAN","IRControl2-EF-3.0"),
})
return{
id="zcl.bridges.wave19",
registrations=device_definitions,
}
