local I,O,u,N,m,E=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.cluster_base",require"st.zigbee.data_types",require"st.zigbee.device_management"local p,q=u.definition_registry()local j,d,f,G,n,r,g,H,M,x,L=4648,64716,6,0,16387,31,110,assert(O.terncyWs07Action,"missing Terncy WS07 action emitter")(),assert(O.terncyWs07ActionDuration,"missing Terncy WS07 duration emitter")(),{assert(O.terncyWs07PowerOnBehaviorOne,"missing Terncy WS07 power behavior emitter 1")(),assert(O.terncyWs07PowerOnBehaviorTwo,"missing Terncy WS07 power behavior emitter 2")(),assert(O.terncyWs07PowerOnBehaviorThree,"missing Terncy WS07 power behavior emitter 3")()},{[1]="single",[2]="double",[3]="triple",[4]="quadruple",[5]="5_click",[6]="6_click",[7]="7_click"}







local function C(c,W)
if W~=nil then
c:emit_component_event({id="main"},W)end
end
local function s(b)
return b and b.address_header and b.address_header.src_endpoint and
b.address_header.src_endpoint.value or nil
end
local function F(b)
local w=b and b.body and b.body.zcl_header or nil
local ac=w and w.mfg_code and w.mfg_code.value or nil
return ac
end
local function k(b)
local w=b and b.body and b.body.zcl_header or nil
local K=w and w.frame_ctrl or nil
return K~=nil and K.value==13 and
F(b)==j
end
local function J(b)
local Y=b and b.body and b.body.zcl_body or nil
return Y and Y.body_bytes or nil
end
local function z(endpoint)
return({[1]="l1",[2]="l2",[3]="l3"})[endpoint]
end
I.register_cluster_command_handler(d,0,function(c,P,b)
if P.terncy_ws07~=true or not k(b)then
return false
end
local endpoint,i=z(s(b)),J(b)if endpoint==nil or type(i)~="string"or #i<2 then return false end
local B=L[string.byte(i,2)]if B==nil then return false end
C(c,H(c,B.."_"..endpoint))return true
end)
I.register_cluster_command_handler(d,41,function(c,P,b)
if P.terncy_ws07~=true or not k(b)then
return false
end
local endpoint,i=z(s(b)),J(b)if endpoint==nil or type(i)~="string"or #i<4 then return false end
local S=string.byte(i,1)local B=({[2]="hold",[8]="release"})[S]if B==nil then return false end
local V=string.byte(i,3)+string.byte(i,4)*256
C(c,H(c,B.."_"..endpoint))C(c,M(c,V))return true
end)
local function t(R,aa)
return function(c,_,y,D)
local v=aa[y]if v==nil then return false end
return I.send_raw_cluster_command(c,d,R,string.char(v),D.endpoint,nil,j,false)
end
end
local function A(c,_,y,D)
local v=({positive=0,negative=1})[y]if v==nil then return false end
local l=N.write_manufacturer_specific_attribute(c,d,r,j,m.Uint8,v)if D.endpoint~=nil and type(l.to_endpoint)=="function"then
l=l:to_endpoint(D.endpoint)end
if type(l.from_endpoint)=="function"then
l=l:from_endpoint(g)else
l.address_header.src_endpoint=m.Uint8(g)end
c:send(l)return true
end
local function o(ad,endpoint,h,ab)
local X=I.cluster_attribute(d,nil,{name=ad,endpoint=endpoint,component=h,read_only=false,write_only=true,sender=ab})return X
end
local e={}for endpoint=1,3 do
local T,h=({"One","Two","Three"})[endpoint],endpoint==1 and"main"or("switch"..tostring(endpoint))e[#e+1]=I.switch{endpoint=endpoint,component=h,read_only=false,configure_reporting=false,read_on_configure=false,reporting_defaults={minimum_interval=0,maximum_interval=65000}}e[#e+1]=I.cluster_attribute(f,n,{name="terncy_ws07_power_on_behavior_"..string.lower(T),endpoint=endpoint,component=h,read_only=false,data_type=m.Enum8,write_type=m.Enum8,emit=x[endpoint],
from_device=function(y)
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[y]
end,
to_device=function(y)
return({off=0,on=1,toggle=2,previous=255})[y]
end
})e[#e+1]=o("terncy_ws07_operation_mode_"..string.lower(T),endpoint,h,t(29,{control_relay=0,wireless=1}))e[#e+1]=o("terncy_ws07_wireless_led_status_"..string.lower(T),endpoint,h,t(31,{off=0,on=1}))e[#e+1]=o("terncy_ws07_led_feedback_mode_"..string.lower(T),endpoint,h,A)end
local function U(Z,c)
for endpoint=1,3 do
c:send(E.build_bind_request(c,f,Z.environment_info.hub_zigbee_eui,endpoint))I.configure_reporting(c,{cluster=f,attribute=G,data_type=m.Boolean,minimum_interval=0,maximum_interval=65000},endpoint)I.read_attribute(c,f,G,endpoint)I.read_attribute(c,f,n,endpoint)end
end
local Q={profile="switches-wave14-terncy-ws07-d3",package_group="wave14-switch",terncy_ws07=true,zcl_clusters=e,component_to_endpoint_map={main=1,switch2=2,switch3=3},endpoint_to_component_map={[1]="main",[2]="switch2",[3]="switch3"},configure=U}q(Q,{u.create_fingerprint("Xiaoyan","TERNCY-WS07-D3")})I.attach_reporting_capabilities(p,{{1,"rpt-tbh",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}}})return{id="wave14.terncy.zcl_switch",registrations=p}
