local helpers = require "contracts.helpers.family"
local capabilities = require "st.capabilities"
local emit = require "capabilities.events.all"
local clusters = require "st.zigbee.zcl.clusters"
local data_types = require "st.zigbee.data_types"
local management = require "st.zigbee.device_management"
local json = require "st.json"
local lock = clusters.DoorLock
local definitions, register = helpers.definition_registry()
local P = "yrd410:"
local transient = {persist=false}
local persistent = {persist=true}
local sources = {[0]="keypad",[1]="rf",[2]="manual",[3]="rfid",[4]="fingerprint"}
local statuses = {[0]="available",[1]="enabled",[3]="disabled"}
local types = {unrestricted=0,year_day_schedule=1,week_day_schedule=2,master=3,non_access=4}
local volumes = {[0]="silent_mode",[1]="low_volume",[2]="high_volume"}
local operations = {[0]="unknown","lock","unlock","lock_failure_invalid_pin_or_id","lock_failure_invalid_schedule",
  "unlock_failure_invalid_pin_or_id","unlock_failure_invalid_schedule","one_touch_lock","key_lock","key_unlock",
  "auto_lock","schedule_lock","schedule_unlock","manual_lock","manual_unlock","non_access_user_operational_event"}
local programs = {[0]="unknown","master_code_changed","pin_code_added","pin_code_deleted","pin_code_changed","rfid_code_added","rfid_code_deleted"}
local door_states = {[0]="open","closed","error_jammed","error_forced_open","error_unspecified",[255]="undefined"}
local raw_lock_states = {[0]="not_fully_locked","locked","unlocked"}
local fields = {
  relock=emit.yrd410RelockTime(),
  volume=emit.yrd410SoundVolume(),
  action=emit.yrd410Action(),
  user=emit.yrd410ActionUser(),
  source=emit.yrd410ActionSource(),
  source_name=emit.yrd410ActionSourceName(),
  raw_lock=emit.yrd410LockState(),
  door=emit.yrd410DoorState(),
  raw_battery=emit.yrd410BatteryPercent(),
}
local function valid(value, minimum, maximum)
  return type(value)=="number" and value==value and value%1==0 and value>=minimum and value<=maximum
end
local function publish(device, factory, value, unit, repeated)
  if value==nil then return end
  local payload={value=value}
  if unit then payload.unit=unit end
  local event=factory(payload)
  if repeated then event.state_change=true end
  device:emit_event(event)
end
local function publish_scalar(device, factory, value, repeated)
  if value==nil then return end
  local event=factory(device,value)
  if event==nil then return end
  if repeated then event.state_change=true end
  device:emit_event(event)
end
local function send(device, message)
  local ok, result=pcall(device.send,device,message:to_endpoint(1))
  return ok and result~=false
end
local function read(device, cluster, attribute)
  return send(device,management.attr_refresh(device,cluster,attribute))
end
local function user(value) return valid(value,0,249) end
-- Primary lock uses Buffer.from(text,"ascii"); SetPINCode uses text.length
-- then Buffer.from(text) (UTF8). Keep those two encoders distinct. The latter's
-- non-ASCII prefix mismatch is a primary limitation, not a physical PIN policy.
local function encoded_pin(value, ascii)
  if type(value)~="string" or not utf8.len(value) then return nil end
  local length,octets=0,{}
  for _,point in utf8.codes(value) do
    if point>0xffff then
      local n=point-0x10000
      length=length+2
      if ascii then octets[#octets+1]=string.char(((n>>10)+0xd800)&255,(n+0xdc00)&255) end
    else
      length=length+1
      if ascii then octets[#octets+1]=string.char(point&255) end
    end
  end
  if length>254 then return nil end -- FF is the ZCL non-value, not a PIN length.
  local result=data_types.OctetString(ascii and table.concat(octets) or value)
  result.byte_length=length
  return result
end
local function get_pin(device, value)
  if not user(value) then return false end
  return send(device,lock.server.commands.GetPINCode(device,value))
end
local function get_status(device,value)
  if not user(value) then return false end
  return send(device,lock.server.commands.GetUserStatus(device,value))
end
local function clear_pending(device,index,identity)
  local pending=device:get_field(P.."pending") or {}
  if not identity or pending[index]==identity then pending[index]=nil end
  device:set_field(P.."pending",pending,transient)
end
local function set_pin(device,index,code,kind,enabled,name)
  local encoded=encoded_pin(code,false)
  if not user(index) or not encoded or types[kind]==nil or type(enabled)~="boolean" then return false end
  if not send(device,lock.server.commands.SetPINCode(device,index,enabled and 1 or 3,types[kind],encoded)) then return false end
  local request={code=code,status=enabled and 1 or 3,name=name}
  local pending=device:get_field(P.."pending") or {}
  pending[index]=request;device:set_field(P.."pending",pending,transient)
  if not get_pin(device,index) then clear_pending(device,index,request);return false end
  device.thread:call_with_delay(10,function()clear_pending(device,index,request)end,"YRD410 PIN readback expiry")
  return true
end
local function clear_pin(device,index)
  if not user(index) or not send(device,lock.server.commands.ClearPINCode(device,index)) then return false end
  local request={clear=true}
  local pending=device:get_field(P.."pending") or {}
  pending[index]=request;device:set_field(P.."pending",pending,transient)
  if not get_pin(device,index) then clear_pending(device,index,request);return false end
  device.thread:call_with_delay(10,function()clear_pending(device,index,request)end,"YRD410 clear readback expiry")
  return true
end
local function all(device, reader)
  for index=0,249 do if not reader(device,index) then return false end end
  return true
end
local function names_event(device)
  publish(device,capabilities.lockCodes.lockCodes,json.encode(device:get_field(P.."names") or {}))
end
local function receive_user(device,body,is_pin)
  local index,status=body.user_id.value,body.user_status.value
  local key=tostring(index)
  local users=device:get_field(P.."users") or {}
  users[key]=statuses[status] or "not_supported_"..status
  device:set_field(P.."users",users,persistent)
  publish(device,capabilities["concertmirror08464.yrd410UserStatus"].userStatus,json.encode(users))
  if not is_pin then return end
  local code=body.code.value
  if device.preferences.yrd410ExposePin==true and body.code.byte_length~=255 then
    local pins=device:get_field(P.."pins") or {}
    pins[key]=code;device:set_field(P.."pins",pins,transient)
    publish(device,capabilities["concertmirror08464.yrd410PinCode"].pinCode,json.encode(pins))
  end
  local pending=device:get_field(P.."pending") or {}
  local request=pending[index]
  local names=device:get_field(P.."names") or {}
  if status==0 then names[key]=nil
  elseif status==1 or status==3 then
    names[key]=(request and request.code==code and request.status==status and request.name) or names[key] or "Code "..key
  end
  device:set_field(P.."names",names,persistent);names_event(device)
  publish(device,capabilities.lockCodes.codeReport,index)
  if request and ((request.clear and status==0) or (request.code==code and request.status==status)) then
    local event=capabilities.lockCodes.codeChanged(key..(request.clear and " deleted" or " set"),{state_change=true})
    if not request.clear and request.name then event.data={codeName=request.name} end
    device:emit_event(event);clear_pending(device,index,request)
  end
end
local function receive(device,rx)
  if rx.address_header.src_endpoint.value~=1 then return end
  local cluster=rx.address_header.cluster.value
  local header,body=rx.body.zcl_header,rx.body.zcl_body
  if header.mfg_code~=nil then return end
  local command=header.cmd.value
  if (header.frame_ctrl.value&3)==1 and cluster==0x0101 then
    if command==6 then receive_user(device,body,true)
    elseif command==0x0a then receive_user(device,body,false)
    elseif command==0x20 or command==0x21 then
      local operation=command==0x20
      local code=operation and body.operation_event_code.value or body.program_event_code.value
      local source=operation and body.operation_event_source.value or body.program_event_source.value
      publish_scalar(device,fields.action,(operation and operations or programs)[code],true)
      publish_scalar(device,fields.user,body.user_id.value,true)
      publish_scalar(device,fields.source,source,true)
      publish_scalar(device,fields.source_name,sources[source],true)
    end
    return -- Short ACKs cannot confirm a user or overwrite measured state.
  end
  if (header.frame_ctrl.value&3)~=0 or (command~=1 and command~=10) or not body.attr_records then return end
  local values={}
  for _,record in ipairs(body.attr_records) do
    if (record.status==nil or record.status.value==0) and record.data and type(record.data.value)=="number" then
      values[record.attr_id.value]=record.data.value
    end
  end
  if cluster==0x0101 then
    if values[0]~=nil then
      publish(device,capabilities.lock.lock,values[0]==1 and "locked" or "unlocked")
      publish_scalar(device,fields.raw_lock,raw_lock_states[values[0]])
    end
    publish_scalar(device,fields.relock,values[0x23])
    publish_scalar(device,fields.volume,volumes[values[0x24]])
    publish_scalar(device,fields.door,door_states[values[3]])
  elseif cluster==1 then
    local percentage=values[0x21]
    if percentage~=nil and percentage<255 then
      publish_scalar(device,fields.raw_battery,percentage/2)
      if percentage<=200 then publish(device,capabilities.battery.battery,math.floor(percentage/2+0.5),"%") end
    end
    local voltage=values[0x20]
    if voltage~=nil and voltage<255 then publish(device,capabilities.voltageMeasurement.voltage,voltage/10,"V") end
    local alarm=values[0x3e]
    if alarm~=nil then publish(device,capabilities["concertmirror08464.yrd410BatteryLow"].batteryLow,(alarm&0x00f03c0f)~=0) end
  end
end
local function operate(device,kind,code)
  local encoded=encoded_pin(code,true)
  if not encoded then return false end
  local command=({LOCK=lock.server.commands.LockDoor,UNLOCK=lock.server.commands.UnlockDoor,TOGGLE=lock.server.commands.Toggle})[kind]
  if not command or not send(device,command(device,encoded)) then return false end
  return read(device,0x0101,0)
end
local function setting(device,value,volume)
  if volume then
    local raw
    for index,label in pairs(volumes) do if label==value then raw=index end end
    if raw==nil then return false end
    if not send(device,lock.attributes.SoundVolume:write(device,raw)) then return false end
    return read(device,0x0101,0x24)
  end
  if not valid(value,0,3600) or not send(device,lock.attributes.AutoRelockTime:write(device,value)) then return false end
  return read(device,0x0101,0x23)
end
local function name_slot(device,_,command)
  local args=command.args or {}
  if not user(args.codeSlot) or type(args.codeName)~="string" then return false end
  local names=device:get_field(P.."names") or {}
  if names[tostring(args.codeSlot)]==nil then return false end
  names[tostring(args.codeSlot)]=args.codeName
  device:set_field(P.."names",names,persistent);names_event(device)
  device:emit_event(capabilities.lockCodes.codeChanged(args.codeSlot.." renamed",{state_change=true}))
  return true
end
local writers={
  yrd410_lock=function(device)return operate(device,"LOCK","")end,
  yrd410_unlock=function(device)return operate(device,"UNLOCK","")end,
  yrd410_toggle=function(device)return operate(device,"TOGGLE","")end,
  yrd410_operation=function(device,value)
    if type(value)~="table" then return false end
    for key in pairs(value) do if key~="state" and key~="code" then return false end end
    if value.code~=nil and type(value.code)~="string" then return false end
    return operate(device,type(value.state)=="string" and value.state:upper(),value.code or "")
  end,
  yrd410_relock=function(device,value)return setting(device,value,false)end,
  yrd410_volume=function(device,value)return setting(device,value,true)end,
  yrd410_standard_pin=function(device,_,command)
    local args=command.args or {}
    if args.codePIN=="" then return name_slot(device,nil,command) end
    return set_pin(device,args.codeSlot,args.codePIN,"unrestricted",true,args.codeName)
  end,
  yrd410_pin=function(device,value)
    if type(value)~="table" then return false end
    for key in pairs(value) do if key~="user" and key~="code" and key~="userType" and key~="enabled" then return false end end
    if value.enabled~=nil and type(value.enabled)~="boolean" then return false end
    return set_pin(device,value.user,value.code,value.userType or "unrestricted",value.enabled~=false)
  end,
  yrd410_clear=clear_pin, yrd410_get_pin=get_pin,
  yrd410_get_pins=function(device)return all(device,get_pin)end,
  yrd410_get_status=get_status,
  yrd410_get_statuses=function(device)return all(device,get_status)end,
  yrd410_set_status=function(device,value)
    if type(value)~="table" or not user(value.user) then return false end
    for key in pairs(value) do if key~="user" and key~="status" then return false end end
    local status
    for index,label in pairs(statuses) do if label==value.status then status=index end end
    if status==nil or not send(device,lock.server.commands.SetUserStatus(device,value.user,status)) then return false end
    return get_status(device,value.user)
  end,
  yrd410_name=name_slot,
  yrd410_update_codes=function(device,value)
    if type(value)~="table" then return false end
    local updates={}
    for key,code in pairs(value) do
      local index=type(key)=="string" and tonumber(key:match("^code(%d+)$"))
      if not user(index) or not encoded_pin(code,false) then return false end
      updates[#updates+1]={index,code}
    end
    table.sort(updates,function(a,b)return a[1]<b[1]end)
    for _,item in ipairs(updates) do
      local ok
      if item[2]=="" or item[2]=="0" then ok=clear_pin(device,item[1])
      else ok=set_pin(device,item[1],item[2],"unrestricted",true) end
      if not ok then return false end
    end
    return true
  end,
}
local commands={
  {capability_id="lock",command_name="lock",mapping_name="yrd410_lock"},
  {capability_id="lock",command_name="unlock",mapping_name="yrd410_unlock"},
  {capability_id="lockCodes",command_name="lock",mapping_name="yrd410_lock"},
  {capability_id="lockCodes",command_name="unlock",mapping_name="yrd410_unlock"},
  {capability_id="lockCodes",command_name="setCode",mapping_name="yrd410_standard_pin"},
  {capability_id="lockCodes",command_name="updateCodes",argument_name="codes",mapping_name="yrd410_update_codes"},
  {capability_id="lockCodes",command_name="deleteCode",argument_name="codeSlot",mapping_name="yrd410_clear"},
  {capability_id="lockCodes",command_name="requestCode",argument_name="codeSlot",mapping_name="yrd410_get_pin"},
  {capability_id="lockCodes",command_name="reloadAllCodes",mapping_name="yrd410_get_pins"},
  {capability_id="lockCodes",command_name="nameSlot",mapping_name="yrd410_name"},
  {capability_id="concertmirror08464.yrd410Toggle",command_name="toggle",mapping_name="yrd410_toggle"},
  {capability_id="concertmirror08464.yrd410PinOperation",command_name="sendOperation",argument_name="operation",mapping_name="yrd410_operation"},
  {capability_id="concertmirror08464.yrd410RelockTime",command_name="setRelockTime",argument_name="relockTime",mapping_name="yrd410_relock"},
  {capability_id="concertmirror08464.yrd410SoundVolume",command_name="setSoundVolume",argument_name="soundVolume",mapping_name="yrd410_volume"},
  {capability_id="concertmirror08464.yrd410PinCode",command_name="setPinCode",argument_name="pinCode",mapping_name="yrd410_pin"},
  {capability_id="concertmirror08464.yrd410PinCode",command_name="clearPinCode",argument_name="user",mapping_name="yrd410_clear"},
  {capability_id="concertmirror08464.yrd410PinCode",command_name="getPinCode",argument_name="user",mapping_name="yrd410_get_pin"},
  {capability_id="concertmirror08464.yrd410PinCode",command_name="getAllPinCodes",mapping_name="yrd410_get_pins"},
  {capability_id="concertmirror08464.yrd410UserStatus",command_name="setUserStatus",argument_name="userStatus",mapping_name="yrd410_set_status"},
  {capability_id="concertmirror08464.yrd410UserStatus",command_name="getUserStatus",argument_name="user",mapping_name="yrd410_get_status"},
  {capability_id="concertmirror08464.yrd410UserStatus",command_name="getAllUserStatuses",mapping_name="yrd410_get_statuses"},
}
local function configure(driver,device)
  for _,cluster in ipairs({0x0101,1}) do
    if not send(device,management.build_bind_request(device,cluster,driver.environment_info.hub_zigbee_eui,1)) then return false end
  end
  for _,item in ipairs({{0x0101,0,data_types.Enum8,0,3600},{1,0x21,data_types.Uint8,3600,65000},{1,0x3e,data_types.Bitmap32,3600,65000}}) do
    if not send(device,management.attr_config(device,{cluster=item[1],attribute=item[2],data_type=item[3],
      minimum_interval=item[4],maximum_interval=item[5],reportable_change=0})) then return false end
    if item[1]==1 then read(device,1,item[2]) end
  end
  return true
end
register({profile="locks-yale-yrd410-pb",zcl_clusters={},capability_commands=commands,protocol_writers=writers,
  initial_custom_state_query=false,zigbee_message_handler=receive,
  configure=configure,
  runtime_start=function(device)
    publish(device,capabilities.lock.supportedLockValues,{"locked","unlocked"})
    publish(device,capabilities.lock.supportedLockCommands,{"lock","unlock"})
    publish(device,capabilities.lockCodes.maxCodes,250)
    return true
  end,
  parent_refresh=function(device)
    for _,item in ipairs({{0x0101,0},{0x0101,0x23},{0x0101,0x24},{1,0x21},{1,0x3e}}) do read(device,item[1],item[2]) end
    return true
  end,
},{helpers.create_fingerprint("Yale:8104:05D1","YRD410-PB")})
return {id="zcl.controls.yale_yrd410",registrations=definitions,}
