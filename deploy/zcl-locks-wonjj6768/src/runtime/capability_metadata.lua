local a,H={},{"unlock","lock","yrd410RelockTime","yrd410ActionUser","yrd410ActionSource","yrd410BatteryPercent","javisSlkAction","action","javisSlkState","LOCK","yrd410SoundVolume","silent_mode","low_volume","high_volume","yrd410Action","unknown","lock_failure_invalid_pin_or_id","lock_failure_invalid_schedule","unlock_failure_invalid_pin_or_id","unlock_failure_invalid_schedule","one_touch_lock","key_lock","key_unlock","auto_lock","schedule_lock","schedule_unlock","manual_lock","manual_unlock","non_access_user_operational_event","master_code_changed","pin_code_added","pin_code_deleted","pin_code_changed","rfid_code_added","rfid_code_deleted","yrd410ActionSourceName","keypad","manual","rfid","fingerprint","yrd410LockState","not_fully_locked","locked","unlocked","yrd410DoorState","open","closed","error_jammed","error_forced_open","error_unspecified","undefined","lastPowerResponseTime"}
local function b(g)
if type(g)=="number"then return H[g]end
return g
end
local function p(g)local suffix=b(g);if suffix==nil then return nil end;return"concertmirror08464."..suffix end
local t={}
local function q(k)
if type(k)~="number"then return{}end
local x=t[k]if x~=nil then return x end
local n={}t[k]=n
return n
end
local function s(D,k)
if type(D)~="table"then return nil end
local n=q(k)for A,g in ipairs(D)do n[A]=b(g)end
return n
end
local function i(g,E)
if g==nil then return E end
if g==0 then return nil end
return b(g)
end
local function m(attribute_name)
if type(attribute_name)~="string"or attribute_name==""then return nil end
return"set"..attribute_name:sub(1,1):upper()..attribute_name:sub(2)
end
local function J(g)
if type(g)~="table"then return nil end
local n=q(g[6])n.minimum=g[1]n.maximum=g[2]n.step=g[3]n.unit=b(g[4])n.allowed_values=s(g[5],g[7])return n
end
local function w(j,k)
if j==nil and k==nil then return nil end
local n=q(k)n.allowed_values=j
return n
end
local function G(f)
local attribute_name=b(f[4])return{kind="numeric",emit_name=b(f[1]),range_key=b(f[2]),capability_id=p(f[3]),attribute_name=attribute_name,range_attribute_name=b(f[5]),command_name=i(f[6],m(attribute_name)),argument_name=i(f[7],attribute_name),mapping_name=b(f[8]),label=b(f[9]),default_range=J(f[10]),event_minimum=f[11],event_maximum=f[12],event_unit=b(f[13])}
end
local function K(f)
local attribute_name,u,r=b(f[4]),s(f[10],f[12]),s(f[11],f[14])local d=w(r,f[13])return{kind="enum",emit_name=b(f[1]),range_key=b(f[2]),capability_id=p(f[3]),attribute_name=attribute_name,supported_attribute_name=b(f[5]),command_name=i(f[6],m(attribute_name)),argument_name=i(f[7],attribute_name),mapping_name=b(f[8]),label=b(f[9]),supported_values=u,default_range=d}
end
local function M(f)
local attribute_name=b(f[3])return{kind="text",emit_name=b(f[1]),capability_id=p(f[2]),attribute_name=attribute_name,command_name=i(f[4],m(attribute_name)),argument_name=i(f[5],attribute_name),mapping_name=b(f[6]),label=b(f[7]),maximum_length=f[8]}
end
local function z(L,F)
local n={}for _,f in ipairs(L)do n[#n+1]=F(f)end
return n
end
a.numeric=z({{3,nil,3,"relockTime",nil,nil,nil,"yrd410_relock","Yrd410Relock Time",{nil,nil,nil,"s",nil,1},nil,nil,"s"},{4,nil,4,"actionUser",nil,0,0,"yrd410_action_user","Yrd410Action User",{0,65535,1,nil,nil,2}},{5,nil,5,"actionSource",nil,0,0,"yrd410_action_source","Yrd410Action Source",{0,255,1,nil,nil,3}},{6,nil,6,"batteryPercent",nil,0,0,"yrd410_battery_percent","Yrd410Battery Percent",{0,127,0.5,"%",nil,4},nil,nil,"%"}},G)a.enum=z({{7,nil,7,8,nil,0,0,"javis_unlock_report","Javis Slk Action",{1,2},{1,2},5,6,5},{9,nil,9,"state",nil,0,0,"javis_lock_state","Javis Slk State",{10},{10},7,8,7},{11,nil,11,"soundVolume",nil,nil,nil,"yrd410_volume","Yrd410Sound Volume",{12,13,14},{12,13,14},9,10,9},{15,nil,15,8,nil,0,0,"yrd410_action","Yrd410Action",{16,2,1,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35},{16,2,1,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35},11,12,11},{36,nil,36,"actionSourceName",nil,0,0,"yrd410_action_source_name","Yrd410Action Source Name",{37,"rf",38,39,40},{37,"rf",38,39,40},13,14,13},{41,nil,41,"lockState",nil,0,0,"yrd410_lock_state","Yrd410Lock State",{42,43,44},{42,43,44},15,16,15},{45,nil,45,"doorState",nil,0,0,"yrd410_door_state","Yrd410Door State",{46,47,48,49,50,51},{46,47,48,49,50,51},17,18,17}},K)a.text=z({{"last_power_response_time",52,52,0,0,nil,"Last power response time",64}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
local function o(y)
for _,e in ipairs(y)do
a.by_emit_name[e.emit_name]=e
if type(e.capability_id)=="string"and e.capability_id~=""then a.by_capability_id[e.capability_id]=e end
if type(e.range_key)=="string"and e.range_key~=""then a.by_range_key[e.range_key]=e end
end
end
o(a.numeric)o(a.enum)o(a.text)a.by_emit_name[a.driver_message.emit_name]=a.driver_message
a.by_capability_id[a.driver_message.capability_id]=a.driver_message
local function l(j)
if type(j)~="table"then return nil end
local B={}for A,g in ipairs(j)do B[A]=g end
return B
end
function a.resolve_range(v,e)
if type(e)~="table"then return nil end
local d,C=type(e.default_range)=="table"and e.default_range or nil,type(v)=="table"and v.presence_capability_ranges or nil

local h=type(C)=="table"and C[e.range_key]or nil
if type(h)~="table"then h=d end
if type(h)~="table"then return nil end
return{minimum=type(h.minimum)=="number"and h.minimum or(d and d.minimum or nil),maximum=type(h.maximum)=="number"and h.maximum or(d and d.maximum or nil),step=type(h.step)=="number"and h.step or(d and d.step or nil),unit=type(h.unit)=="string"and h.unit or(d and d.unit or nil),allowed_values=type(h.allowed_values)=="table"and l(h.allowed_values)or l(d and d.allowed_values or nil)}
end
return a
