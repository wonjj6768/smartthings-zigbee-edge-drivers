local a,H={},{"Learn","Delete","Saved","Transmit","off","on","code","transmit","security_remote_action","foriaSceneBacklight","foriaSceneIlluminationDetection","foriaSceneApproachDetection","foriaSceneVibration","securityRemoteAction","disarm","arm_day_zones","arm_night_zones","arm_all_zones","exit_delay","emergency","zrf01LearningMode","zrf01PacketMode","zrf01Code1","zrf01Transmit1","zrf01Code2","zrf01Transmit2","zrf01Code3","zrf01Transmit3","zrf01Code4","zrf01Transmit4","zrf01Code5","zrf01Transmit5","zrf01Code6","zrf01Transmit6","zrf01Code7","zrf01Transmit7","zrf01Code8","zrf01Transmit8","lastPowerResponseTime"}
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
a.numeric=z({},G)a.enum=z({{9,9,14,14,"supportedSecurityRemoteActions",0,0,9,"Security remote action",{15,16,17,18,19,20},{15,16,17,18,19,20},1,2,1},{10,nil,10,10,nil,nil,nil,"foria_scene_backlight","Foria Scene Backlight",{5,6},{5,6},3,4,3},{11,nil,11,11,nil,nil,nil,"foria_scene_illumination_detection","Foria Scene Illumination Detection",{5,6},{5,6},5,6,5},{12,nil,12,12,nil,nil,nil,"foria_scene_approach_detection","Foria Scene Approach Detection",{5,6},{5,6},7,8,7},{13,nil,13,13,nil,nil,nil,"foria_scene_vibration","Foria Scene Vibration",{5,6},{5,6},9,10,9},{21,nil,21,"learningMode",nil,nil,nil,"zrf01_learning_mode","Zrf01Learning Mode",{6,5},{6,5},11,12,11},{22,nil,22,"packetMode",nil,nil,nil,"zrf01_packet_mode","Zrf01Packet Mode",{6,5},{6,5},13,14,13},{23,nil,23,7,nil,nil,nil,"zrf01_code_1","Zrf01Code1",{1,2,3},{1,2,3},15,16,15},{24,nil,24,8,nil,nil,nil,"zrf01_transmit_1","Zrf01Transmit1",{4},{4},17,18,17},{25,nil,25,7,nil,nil,nil,"zrf01_code_2","Zrf01Code2",{1,2,3},{1,2,3},19,20,19},{26,nil,26,8,nil,nil,nil,"zrf01_transmit_2","Zrf01Transmit2",{4},{4},21,22,21},{27,nil,27,7,nil,nil,nil,"zrf01_code_3","Zrf01Code3",{1,2,3},{1,2,3},23,24,23},{28,nil,28,8,nil,nil,nil,"zrf01_transmit_3","Zrf01Transmit3",{4},{4},25,26,25},{29,nil,29,7,nil,nil,nil,"zrf01_code_4","Zrf01Code4",{1,2,3},{1,2,3},27,28,27},{30,nil,30,8,nil,nil,nil,"zrf01_transmit_4","Zrf01Transmit4",{4},{4},29,30,29},{31,nil,31,7,nil,nil,nil,"zrf01_code_5","Zrf01Code5",{1,2,3},{1,2,3},31,32,31},{32,nil,32,8,nil,nil,nil,"zrf01_transmit_5","Zrf01Transmit5",{4},{4},33,34,33},{33,nil,33,7,nil,nil,nil,"zrf01_code_6","Zrf01Code6",{1,2,3},{1,2,3},35,36,35},{34,nil,34,8,nil,nil,nil,"zrf01_transmit_6","Zrf01Transmit6",{4},{4},37,38,37},{35,nil,35,7,nil,nil,nil,"zrf01_code_7","Zrf01Code7",{1,2,3},{1,2,3},39,40,39},{36,nil,36,8,nil,nil,nil,"zrf01_transmit_7","Zrf01Transmit7",{4},{4},41,42,41},{37,nil,37,7,nil,nil,nil,"zrf01_code_8","Zrf01Code8",{1,2,3},{1,2,3},43,44,43},{38,nil,38,8,nil,nil,nil,"zrf01_transmit_8","Zrf01Transmit8",{4},{4},45,46,45}},K)a.text=z({{"last_power_response_time",39,39,0,0,nil,"Last power response time",64}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
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
