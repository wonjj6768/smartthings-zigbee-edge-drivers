local aj,e,H,ax,w,J,az=require"contracts.helpers.family",require"st.capabilities",require"capabilities.events.all",require"st.zigbee.zcl.clusters",require"st.zigbee.data_types",require"st.zigbee.device_management",require"st.json"local D=ax.DoorLock
local ah,aC=aj.definition_registry()local P,B,K,aK,ag,aE,am,aq,aB,ai,W,t="yrd410:",{persist=false},{persist=true},{[0]="keypad",[1]="rf",[2]="manual",[3]="rfid",[4]="fingerprint"},{[0]="available",[1]="enabled",[3]="disabled"},{unrestricted=0,year_day_schedule=1,week_day_schedule=2,master=3,non_access=4},{[0]="silent_mode",[1]="low_volume",[2]="high_volume"},{[0]="unknown","lock","unlock","lock_failure_invalid_pin_or_id","lock_failure_invalid_schedule","unlock_failure_invalid_pin_or_id","unlock_failure_invalid_schedule","one_touch_lock","key_lock","key_unlock","auto_lock","schedule_lock","schedule_unlock","manual_lock","manual_unlock","non_access_user_operational_event"},{[0]="unknown","master_code_changed","pin_code_added","pin_code_deleted","pin_code_changed","rfid_code_added","rfid_code_deleted"},{[0]="open","closed","error_jammed","error_forced_open","error_unspecified",[255]="undefined"},{[0]="not_fully_locked","locked","unlocked"},{relock=H.yrd410RelockTime(),volume=H.yrd410SoundVolume(),action=H.yrd410Action(),user=H.yrd410ActionUser(),source=H.yrd410ActionSource(),source_name=H.yrd410ActionSourceName(),raw_lock=H.yrd410LockState(),door=H.yrd410DoorState(),raw_battery=H.yrd410BatteryPercent()}
local function aF(d,aI,aG)
return type(d)=="number"and d==d and d%1==0 and d>=aI and d<=aG
end
local function k(c,Z,d,aR,T)
if d==nil then return end
local ak={value=d}if aR then ak.unit=aR end
local x=Z(ak)if T then x.state_change=true end
c:emit_event(x)
end
local function h(c,Z,d,T)
if d==nil then return end
local x=Z(c,d)if x==nil then return end
if T then x.state_change=true end
c:emit_event(x)
end
local function z(c,aH)
local ok,X=pcall(c.send,c,aH:to_endpoint(1))return ok and X~=false
end
local function af(c,u,at)
return z(c,J.attr_refresh(c,u,at))
end
local function U(d)return aF(d,0,249)end
local function C(d,an)
if type(d)~="string"or not utf8.len(d)then return nil end
local F,L=0,{}for _,ar in utf8.codes(d)do
if ar>65535 then
local n=ar-65536
F=F+2
if an then L[#L+1]=string.char(((n>>10)+55296)&255,(n+56320)&255)end
else
F=F+1
if an then L[#L+1]=string.char(ar&255)end
end
end
if F>254 then return nil end
local X=w.OctetString(an and table.concat(L)or d)X.byte_length=F
return X
end
local function O(c,d)
if not U(d)then return false end
return z(c,D.server.commands.GetPINCode(c,d))
end
local function I(c,d)
if not U(d)then return false end
return z(c,D.server.commands.GetUserStatus(c,d))
end
local function l(c,f,ae)
local j=c:get_field(P.."pending")or{}if not ae or j[f]==ae then j[f]=nil end
c:set_field(P.."pending",j,B)
end
local function aa(c,f,v,ao,Y,aW)
local E=C(v,false)if not U(f)or not E or aE[ao]==nil or type(Y)~="boolean"then return false end
if not z(c,D.server.commands.SetPINCode(c,f,Y and 1 or 3,aE[ao],E))then return false end
local g,j={code=v,status=Y and 1 or 3,name=aW},c:get_field(P.."pending")or{}j[f]=g;c:set_field(P.."pending",j,B)if not O(c,f)then l(c,f,g);return false end
c.thread:call_with_delay(10,function()l(c,f,g)end,"YRD410 PIN readback expiry")
return true
end
local function ac(c,f)
if not U(f)or not z(c,D.server.commands.ClearPINCode(c,f))then return false end
local g,j={clear=true},c:get_field(P.."pending")or{}j[f]=g;c:set_field(P.."pending",j,B)if not O(c,f)then l(c,f,g);return false end
c.thread:call_with_delay(10,function()l(c,f,g)end,"YRD410 clear readback expiry")
return true
end
local function aU(c,aQ)
for f=0,249 do if not aQ(c,f)then return false end end
return true
end
local function S(c)
k(c,e.lockCodes.lockCodes,az.encode(c:get_field(P.."names")or{}))
end
local function N(c,s,aN)
local f,status=s.user_id.value,s.user_status.value
local key,as=tostring(f),c:get_field(P.."users")or{}as[key]=ag[status]or"not_supported_"..status
c:set_field(P.."users",as,K)k(c,e["concertmirror08464.yrd410UserStatus"].userStatus,az.encode(as))if not aN then return end
local v=s.code.value
if c.preferences.yrd410ExposePin==true and s.code.byte_length~=255 then
local aA=c:get_field(P.."pins")or{}aA[key]=v;c:set_field(P.."pins",aA,B)k(c,e["concertmirror08464.yrd410PinCode"].pinCode,az.encode(aA))end
local j=c:get_field(P.."pending")or{}local g,A=j[f],c:get_field(P.."names")or{}if status==0 then A[key]=nil
elseif status==1 or status==3 then
A[key]=(g and g.code==v and g.status==status and g.name)or A[key]or"Code "..key
end
c:set_field(P.."names",A,K);S(c)k(c,e.lockCodes.codeReport,f)if g and((g.clear and status==0)or(g.code==v and g.status==status))then
local x=e.lockCodes.codeChanged(key..(g.clear and" deleted"or" set"),{state_change=true})if not g.clear and g.name then x.data={codeName=g.name}end
c:emit_event(x);l(c,f,g)end
end
local function aJ(c,rx)
if rx.address_header.src_endpoint.value~=1 then return end
local u,V,s=rx.address_header.cluster.value,rx.body.zcl_header,rx.body.zcl_body

if V.mfg_code~=nil then return end
local i=V.cmd.value
if(V.frame_ctrl.value&3)==1 and u==257 then
if i==6 then N(c,s,true)elseif i==10 then N(c,s,false)elseif i==32 or i==33 then
local M=i==32
local v,av=M and s.operation_event_code.value or s.program_event_code.value,M and s.operation_event_source.value or s.program_event_source.value

h(c,t.action,(M and aq or aB)[v],true)h(c,t.user,s.user_id.value,true)h(c,t.source,av,true)h(c,t.source_name,aK[av],true)end
return
end
if(V.frame_ctrl.value&3)~=0 or(i~=1 and i~=10)or not s.attr_records then return end
local q={}for _,G in ipairs(s.attr_records)do
if(G.status==nil or G.status.value==0)and G.data and type(G.data.value)=="number"then
q[G.attr_id.value]=G.data.value
end
end
if u==257 then
if q[0]~=nil then
k(c,e.lock.lock,q[0]==1 and"locked"or"unlocked")h(c,t.raw_lock,W[q[0]])end
h(c,t.relock,q[35])h(c,t.volume,am[q[36]])h(c,t.door,ai[q[3]])elseif u==1 then
local o=q[33]if o~=nil and o<255 then
h(c,t.raw_battery,o/2)if o<=200 and o%2==0 then k(c,e.battery.battery,o/2,"%")end
end
local ab=q[32]if ab~=nil and ab<255 then k(c,e.voltageMeasurement.voltage,ab/10,"V")end
local aD=q[62]if aD~=nil then k(c,e["concertmirror08464.yrd410BatteryLow"].batteryLow,(aD&15744015)~=0)end
end
end
local function Q(c,ao,v)
local E=C(v,true)if not E then return false end
local i=({LOCK=D.server.commands.LockDoor,UNLOCK=D.server.commands.UnlockDoor,TOGGLE=D.server.commands.Toggle})[ao]if not i or not z(c,i(c,E))then return false end
return af(c,257,0)
end
local function al(c,d,aS)
if aS then
local aP
for f,ap in pairs(am)do if ap==d then aP=f end end
if aP==nil then return false end
if not z(c,D.attributes.SoundVolume:write(c,aP))then return false end
return af(c,257,36)end
if not aF(d,0,3600)or not z(c,D.attributes.AutoRelockTime:write(c,d))then return false end
return af(c,257,35)
end
local function ad(c,_,i)
local y=i.args or{}if not U(y.codeSlot)or type(y.codeName)~="string"then return false end
local A=c:get_field(P.."names")or{}if A[tostring(y.codeSlot)]==nil then return false end
A[tostring(y.codeSlot)]=y.codeName
c:set_field(P.."names",A,K);S(c)c:emit_event(e.lockCodes.codeChanged(y.codeSlot.." renamed",{state_change=true}))return true
end
local aL={
yrd410_lock=function(c)return Q(c,"LOCK","")end,
yrd410_unlock=function(c)return Q(c,"UNLOCK","")end,
yrd410_toggle=function(c)return Q(c,"TOGGLE","")end,
yrd410_operation=function(c,d)
if type(d)~="table"then return false end
for key in pairs(d)do if key~="state"and key~="code"then return false end end
if d.code~=nil and type(d.code)~="string"then return false end
return Q(c,type(d.state)=="string"and d.state:upper(),d.code or"")
end,
yrd410_relock=function(c,d)return al(c,d,false)end,
yrd410_volume=function(c,d)return al(c,d,true)end,
yrd410_standard_pin=function(c,_,i)
local y=i.args or{}if y.codePIN==""then return ad(c,nil,i)end
return aa(c,y.codeSlot,y.codePIN,"unrestricted",true,y.codeName)
end,
yrd410_pin=function(c,d)
if type(d)~="table"then return false end
for key in pairs(d)do if key~="user"and key~="code"and key~="userType"and key~="enabled"then return false end end
if d.enabled~=nil and type(d.enabled)~="boolean"then return false end
return aa(c,d.user,d.code,d.userType or"unrestricted",d.enabled~=false)
end,
yrd410_clear=ac,yrd410_get_pin=O,
yrd410_get_pins=function(c)return aU(c,O)end,
yrd410_get_status=I,
yrd410_get_statuses=function(c)return aU(c,I)end,
yrd410_set_status=function(c,d)
if type(d)~="table"or not U(d.user)then return false end
for key in pairs(d)do if key~="user"and key~="status"then return false end end
local status
for f,ap in pairs(ag)do if ap==d.status then status=f end end
if status==nil or not z(c,D.server.commands.SetUserStatus(c,d.user,status))then return false end
return I(c,d.user)
end,
yrd410_name=ad,
yrd410_update_codes=function(c,d)
if type(d)~="table"then return false end
local R={}for key,v in pairs(d)do
local f=type(key)=="string"and tonumber(key:match"^code(%d+)$")if not U(f)or not C(v,false)then return false end
R[#R+1]={f,v}end
table.sort(R,function(a,b)return a[1]<b[1]end)
for _,p in ipairs(R)do
local ok
if p[2]==""or p[2]=="0"then ok=ac(c,p[1])else ok=aa(c,p[1],p[2],"unrestricted",true)end
if not ok then return false end
end
return true
end
}local ay={{capability_id="lock",command_name="lock",mapping_name="yrd410_lock"},{capability_id="lock",command_name="unlock",mapping_name="yrd410_unlock"},{capability_id="lockCodes",command_name="lock",mapping_name="yrd410_lock"},{capability_id="lockCodes",command_name="unlock",mapping_name="yrd410_unlock"},{capability_id="lockCodes",command_name="setCode",mapping_name="yrd410_standard_pin"},{capability_id="lockCodes",command_name="updateCodes",argument_name="codes",mapping_name="yrd410_update_codes"},{capability_id="lockCodes",command_name="deleteCode",argument_name="codeSlot",mapping_name="yrd410_clear"},{capability_id="lockCodes",command_name="requestCode",argument_name="codeSlot",mapping_name="yrd410_get_pin"},{capability_id="lockCodes",command_name="reloadAllCodes",mapping_name="yrd410_get_pins"},{capability_id="lockCodes",command_name="nameSlot",mapping_name="yrd410_name"},{capability_id="concertmirror08464.yrd410Toggle",command_name="toggle",mapping_name="yrd410_toggle"},{capability_id="concertmirror08464.yrd410PinOperation",command_name="sendOperation",argument_name="operation",mapping_name="yrd410_operation"},{capability_id="concertmirror08464.yrd410RelockTime",command_name="setRelockTime",argument_name="relockTime",mapping_name="yrd410_relock"},{capability_id="concertmirror08464.yrd410SoundVolume",command_name="setSoundVolume",argument_name="soundVolume",mapping_name="yrd410_volume"},{capability_id="concertmirror08464.yrd410PinCode",command_name="setPinCode",argument_name="pinCode",mapping_name="yrd410_pin"},{capability_id="concertmirror08464.yrd410PinCode",command_name="clearPinCode",argument_name="user",mapping_name="yrd410_clear"},{capability_id="concertmirror08464.yrd410PinCode",command_name="getPinCode",argument_name="user",mapping_name="yrd410_get_pin"},{capability_id="concertmirror08464.yrd410PinCode",command_name="getAllPinCodes",mapping_name="yrd410_get_pins"},{capability_id="concertmirror08464.yrd410UserStatus",command_name="setUserStatus",argument_name="userStatus",mapping_name="yrd410_set_status"},{capability_id="concertmirror08464.yrd410UserStatus",command_name="getUserStatus",argument_name="user",mapping_name="yrd410_get_status"},{capability_id="concertmirror08464.yrd410UserStatus",command_name="getAllUserStatuses",mapping_name="yrd410_get_statuses"}}
local function au(aM,c)
for _,u in ipairs{257,1}do
if not z(c,J.build_bind_request(c,u,aM.environment_info.hub_zigbee_eui,1))then return false end
end
for _,p in ipairs{{257,0,w.Enum8,0,3600},{1,33,w.Uint8,3600,65000},{1,62,w.Bitmap32,3600,65000}}do
if not z(c,J.attr_config(c,{cluster=p[1],attribute=p[2],data_type=p[3],minimum_interval=p[4],maximum_interval=p[5],reportable_change=0}))then return false end
if p[1]==1 then af(c,1,p[2])end
end
return true
end
aC({profile="locks-yale-yrd410-pb",zcl_clusters={},capability_commands=ay,protocol_writers=aL,initial_custom_state_query=false,zigbee_message_handler=aJ,configure=au,
runtime_start=function(c)
k(c,e.lock.supportedLockValues,{"locked","unlocked"})k(c,e.lock.supportedLockCommands,{"lock","unlock"})k(c,e.lockCodes.maxCodes,250)return true
end,
parent_refresh=function(c)
for _,p in ipairs{{257,0},{257,35},{257,36},{1,33},{1,62}}do af(c,p[1],p[2])end
return true
end
},{aj.create_fingerprint("Yale:8104:05D1","YRD410-PB")})return{id="zcl.controls.yale_yrd410",registrations=ah}
