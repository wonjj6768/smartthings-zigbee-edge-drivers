local zcl=require"protocol.zcl"
local types=require"st.zigbee.data_types"
local cluster_base=require"st.zigbee.cluster_base"
local M={}
function M.passive(mapping)
mapping.minimum_interval=nil
mapping.maximum_interval=nil
mapping.reportable_change=nil
mapping.read_on_configure=false
return mapping
end
function M.battery(configure)
local options={endpoint=1,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,
from_device=function(value,_,context)
if context.raw_value==255 then return nil end
return value
end,
}
if configure then return zcl.battery(options)end
return M.passive(zcl.battery(options))
end
function M.voltage()
return zcl.battery_voltage({endpoint=1,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,
from_device=function(value,_,context)
if context.raw_value==255 then return nil end
return value
end,
})
end
function M.battery_alarm(emitter)
return zcl.cluster_attribute(0x0001,0x003E,{
name="battery_alarm_state",endpoint=1,data_type=types.Bitmap32,read_only=true,read_on_configure=false,emit=emitter,
from_device=function(value)
if type(value)=="table"then value=value.value end
return bit32.band(value,0x00F03C0F)~=0
end,
})
end
function M.keep_alive(emitter)
return function(device,active,context)
if context.command_id~=0x00 then return end
local key="__ih012_rt01_keep_alive"
local previous=device:get_field(key)
if previous then previous:cancel()end
device:set_field(key,nil)if active then
device:set_field(key,device.thread:call_with_delay(125,function()
device:set_field(key,nil)device:emit_event(emitter(device,false))
end,"IH012 RT01 occupancy keep alive"))
end
end
end
function M.mapping(emitter,name,attribute,values)
local encoded={}
for raw,value in pairs(values)do encoded[value]=raw end
return zcl.cluster_attribute(0x0500,attribute,{
name=name,endpoint=1,data_type=types.Uint8,write_type=types.Uint8,emit=emitter,read_on_configure=false,
from_device=function(raw)return values[raw]end,
to_device=function(value)return encoded[value]end,
})
end
function M.vibration_timeout(emitter)
return function(device,_,context)
if context.command_id~=0x00 then return end
local key="__ts0210_vibration_timeout"
local previous=device:get_field(key)
if previous then previous:cancel()end
device:set_field(key,nil)local timeout=tonumber(device.preferences.vibrationTimeout)or 90
if timeout>0 then
device:set_field(key,device.thread:call_with_delay(timeout,function()
device:set_field(key,nil)device:emit_event(emitter(device,false))
end,"TS0210 vibration timeout"))
end
end
end
function M.sensitivity(emitter,name)
return M.mapping(emitter,name,0x0013,{[0]="low","medium","high"})
end
function M.keep_time(emitter,name)
return M.mapping(emitter,name,0xF001,{[0]="30","60","120"})
end
function M.refresh(device)
local tx=cluster_base.read_attribute(device,types.ClusterId(0x0500),types.AttributeId(0x0013))tx.body.zcl_body.attr_ids={types.AttributeId(0x0013),types.AttributeId(0xF001),types.AttributeId(0x0002)}device:send(tx:to_endpoint(1))
end
function M.magic_packet(device)
local tx=cluster_base.read_attribute(device,types.ClusterId(0x0000),types.AttributeId(0x0004))tx.body.zcl_body.attr_ids={}for _,id in ipairs({0x0004,0x0000,0x0001,0x0005,0x0007,0xFFFE})do
tx.body.zcl_body.attr_ids[#tx.body.zcl_body.attr_ids+1]=types.AttributeId(id)
end
device:send(tx:to_endpoint(1))
end
return M
