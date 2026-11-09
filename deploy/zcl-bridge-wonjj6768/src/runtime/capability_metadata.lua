local a,H={},{"create","learn","success","error","heimanHsOneIrActionId","actionId","heimanHsOneIrActionKeyCode","actionKeyCode","heimanHsOneIrActionModelType","actionModelType","heimanHsTwoIrActionId","heimanHsTwoIrActionKeyCode","heimanHsTwoIrActionModelType","tiRouterTransmitPower","candeoRfHubAction","button_1_single_pressed","button_1_double_pressed","button_1_triple_pressed","button_1_quadruple_pressed","button_1_quintuple_pressed","button_2_single_pressed","button_2_double_pressed","button_2_triple_pressed","button_2_quadruple_pressed","button_2_quintuple_pressed","button_3_single_pressed","button_3_double_pressed","button_3_triple_pressed","button_3_quadruple_pressed","button_3_quintuple_pressed","button_4_single_pressed","button_4_double_pressed","button_4_triple_pressed","button_4_quadruple_pressed","button_4_quintuple_pressed","button_5_single_pressed","button_5_double_pressed","button_5_triple_pressed","button_5_quadruple_pressed","button_5_quintuple_pressed","button_6_single_pressed","button_6_double_pressed","button_6_triple_pressed","button_6_quadruple_pressed","button_6_quintuple_pressed","button_7_single_pressed","button_7_double_pressed","button_7_triple_pressed","button_7_quadruple_pressed","button_7_quintuple_pressed","button_8_single_pressed","button_8_double_pressed","button_8_triple_pressed","button_8_quadruple_pressed","button_8_quintuple_pressed","button_9_single_pressed","button_9_double_pressed","button_9_triple_pressed","button_9_quadruple_pressed","button_9_quintuple_pressed","button_10_single_pressed","button_10_double_pressed","button_10_triple_pressed","button_10_quadruple_pressed","button_10_quintuple_pressed","heimanHsOneIrAction","irAction","heimanHsOneIrActionResult","actionResult","heimanHsTwoIrAction","heimanHsTwoIrActionResult","lastPowerResponseTime","heimanHsOneIrDevices","devices","heimanHsTwoIrDevices"}
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
a.numeric=z({{5,nil,5,6,nil,0,0,"heiman_hs_one_ir_action_id","Heiman Hs One Ir Action Id",{0,255,1,nil,nil,1}},{7,nil,7,8,nil,0,0,"heiman_hs_one_ir_action_key_code","Heiman Hs One Ir Action Key Code",{0,255,1,nil,nil,2}},{9,nil,9,10,nil,0,0,"heiman_hs_one_ir_action_model_type","Heiman Hs One Ir Action Model Type",{0,255,1,nil,nil,3}},{11,nil,11,6,nil,0,0,"heiman_hs_two_ir_action_id","Heiman Hs Two Ir Action Id",{0,255,1,nil,nil,4}},{12,nil,12,8,nil,0,0,"heiman_hs_two_ir_action_key_code","Heiman Hs Two Ir Action Key Code",{0,255,1,nil,nil,5}},{13,nil,13,10,nil,0,0,"heiman_hs_two_ir_action_model_type","Heiman Hs Two Ir Action Model Type",{0,255,1,nil,nil,6}},{14,nil,14,"transmitPower",nil,nil,nil,"ti_router_transmit_power","Ti Router Transmit Power",{-20,20,1,"dBm",nil,7},nil,nil,"dBm"}},G)a.enum=z({{15,nil,15,"rfAction",nil,0,0,"candeo_rf_hub_press","Candeo Rf Hub Action",{16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65},{16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65},8,9,8},{66,nil,66,67,nil,0,0,"heiman_hs_one_ir_action","Heiman Hs One Ir Action",{1,2},{1,2},10,11,10},{68,nil,68,69,nil,0,0,"heiman_hs_one_ir_action_result","Heiman Hs One Ir Action Result",{3,4},{3,4},12,13,12},{70,nil,70,67,nil,0,0,"heiman_hs_two_ir_action","Heiman Hs Two Ir Action",{1,2},{1,2},14,15,14},{71,nil,71,69,nil,0,0,"heiman_hs_two_ir_action_result","Heiman Hs Two Ir Action Result",{3,4},{3,4},16,17,16}},K)a.text=z({{"last_power_response_time",72,72,0,0,nil,"Last power response time",64},{73,73,74,0,0,"heiman_hs_one_ir_devices","Heiman Hs One Ir Devices",2048},{75,75,74,0,0,"heiman_hs_two_ir_devices","Heiman Hs Two Ir Devices",2048}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
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
