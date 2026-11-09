local u,C,o,J,W,l=require"protocol.zcl",require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.cluster_base",require"st.utils",require"contracts.helpers.family"local w,ab=l.definition_registry()local n,F,g,am,O,D={persist=true},{persist=false},"emizb132:",{[512]="norwegian_han",[513]="norwegian_han_extra_load",[514]="aidon_meter",[515]="kaifa_and_kamstrup"},{norwegian_han=512,norwegian_han_extra_load=513,aidon_meter=514,kaifa_and_kamstrup=515},{[1536]="voltage_multiplier",[1537]="voltage_divisor",[1538]="current_multiplier",[1539]="current_divisor"}
local function r(c)
local H
for _,i in pairs(c.zigbee_endpoints)do
if c:supports_server_cluster(0,i.id)and(not H or i.id<H)then H=i.id end
end
return H
end
local function U(c,z)
if z==nil then return false end
local al,h=require"cosock.socket".gettime(),c:get_field(g.."transactions")or{}for _,ad in ipairs(h)do
if ad.sequence==z and ad.expiry>al then return true end
end
for I=#h,1,-1 do if h[I].expiry<=al then table.remove(h,I)end end
if #h>4 then table.remove(h,1)end
h[#h+1]={sequence=z,expiry=al+10}c:set_field(g.."transactions",h,F)return false
end
local function G(c,rx)
local A=rx.body and rx.body.zcl_header
if not A or A.frame_ctrl:is_cluster_specific_set()then return end
local P=A.cmd.value
if P~=1 and P~=10 then return end
if rx.address_header.src_endpoint.value~=2 then return end
local p=rx.address_header.cluster.value
if p~=1794 and p~=2820 then return end
local q={}for _,t in ipairs(rx.body.zcl_body.attr_records or{})do
if t.data and(not t.status or t.status.value==0)then
local af=t.data
local value=af.value
local kind=t.data_type.value
if kind==57 or kind==58 then
local ae=string.reverse(W.bit_list_to_byte_str(af.raw_bits))value=string.unpack(kind==57 and"<f"or"<d",ae)end
local b,y=t.attr_id.value,true
if p==2820 then
if b==772 or b==773 then
y=type(value)=="number"and not(value<-8388607 or value>8388607)elseif D[b]then
y=type(value)=="number"and not(value<1)end
local X=math.floor(b/256)local ap=(X==5 or X==9 or X==10)and(b%256==5 or b%256==8)if(D[b]or ap)and value==65535 then value=0/0 end
end
if y then q[b]=value end
end
end
local k={values=q,used={},duplicate=U(c,A.seqno.value)}rx.__emizb132=k
if p==1794 then
k.reject_energy=q[0]==0 or q[0]==0xFFFFFFFFFFFF or q[0]~=q[0]else
for b,name in pairs(D)do
local value=q[b]if type(value)=="number"then
c:set_field(g..name,value==value and value or false,n)if b==1539 then
c:set_field(g.."current_divisor_invalid_live",value~=value and true or nil,F)end
end
end
end
end
local function x(s,d)
local k,b=s.zb_rx.__emizb132,d.attribute_id

local an=d.cluster_id==2820 and(b==772 or b==773)if not k or k.duplicate and not an or k.used[b]then return nil end
k.used[b]=true
local value=k.values[b]if type(value)~="number"or value~=value or math.abs(value)==math.huge then return nil end
return value,k
end
local function K(_,_,s,d)
local value,k=x(s,d)if value~=nil and not k.reject_energy then return value/1000 end
end
local function f(_,c,s,d)
local value=x(s,d)if value==nil then return end
if d.attribute_id==772 or d.attribute_id==773 then return value end
local Q=d.attribute_id%256==8
local kind=Q and"current"or"voltage"local j,m=c:get_field(g..kind .."_multiplier"),c:get_field(g..kind .."_divisor")if j==nil then j=1 end
if m==nil then m=10 end
local V=j and m and j~=0 and m~=0 and j/m or 1
if Q then
if m==false then
return not c:get_field(g.."current_divisor_invalid_live")and 0 or nil
end
local L=c:get_field(g.."interface_mode")=="kaifa_and_kamstrup"and 1000 or 10
return value*V*m/L
end
return value*V
end
local function M(value,c)
local aa=am[value]if aa then c:set_field(g.."interface_mode",aa,n)end
return aa
end
local function T(c,_,value)
if type(value)~="string"then return false end
local ae=O[value]if ae==nil then return false end
local ag=J.write_manufacturer_specific_attribute(c,1794,770,4117,o.Enum16,ae):to_endpoint(2)if not pcall(c.send,c,ag)then return false end
pcall(u.read_attribute,c,1794,770,2,4117)return true
end
local function B(value,c,_,d)
if type(value)~="string"then return end
local ac,N={value:byte(1,#value)},d.attribute_id==32768
local R=N and table.concat(ac,".")or tonumber(table.concat(ac))c:set_field(g..(N and"software_version"or"hardware_version"),R,n)return R
end
local e={u.cluster_attribute(2820,772,{name="power",endpoint=2,component="main",read_only=true,data_type=o.Int32,emit=C.power(),from_device=f,read_on_configure=true,reporting_defaults={minimum_interval=5,maximum_interval=3600,reportable_change=1}}),u.cluster_attribute(2820,773,{name="emizb132_reactive_power",endpoint=2,component="main",read_only=true,data_type=o.Int32,emit=C.emizb132ReactivePower"VAr",from_device=f,read_on_configure=true,reporting_defaults={minimum_interval=5,maximum_interval=3600,reportable_change=1}}),u.cluster_attribute(1794,770,{name="emizb132_interface_mode",endpoint=2,component="main",mfg_code=4117,data_type=o.Enum16,write_type=o.Enum16,sender=T,suppress_optimistic_state=true,emit=C.emizb132InterfaceMode(),from_device=M,read_on_configure=true})}for I,component in ipairs{"phaseA","phaseB","phaseC"}do
local aj=({1280,2304,2560})[I]e[#e+1]=u.cluster_attribute(2820,aj+5,{name="voltage_"..component,endpoint=2,component=component,read_only=true,data_type=o.Uint16,emit=C.voltage(),from_device=f,read_on_configure=true,reporting_defaults={minimum_interval=10,maximum_interval=65000,reportable_change=50}})e[#e+1]=u.cluster_attribute(2820,aj+8,{name="current_"..component,endpoint=2,component=component,read_only=true,data_type=o.Uint16,emit=C.current(),from_device=f,read_on_configure=true,reporting_defaults={minimum_interval=10,maximum_interval=65000,reportable_change=0}})end
for _,Z in ipairs{{0,"main"},{1,"production"}}do
e[#e+1]=u.cluster_attribute(1794,Z[1],{name=Z[1]==0 and"energy"or"produced_energy",endpoint=2,component=Z[2],read_only=true,data_type=o.Uint48,emit=C.energy(),from_device=K,read_on_configure=true,reporting_defaults={minimum_interval=10,maximum_interval=65000,reportable_change=100}})end
for _,b in ipairs{32768,32800}do
e[#e+1]=u.cluster_attribute(0,b,{name=b==32768 and"emizb132_software_version"or"emizb132_hardware_version",endpoint=r,mfg_code=4117,data_type=o.OctetString,from_device=B,read_only=true,read_on_configure=false,read_on_refresh=false})end
local Y={profile="meters-emizb132",zcl_clusters=e,zigbee_message_handler=G,
configure=function(ak,c)
for name,value in pairs{voltage_multiplier=1,voltage_divisor=10,current_multiplier=1,current_divisor=10}do
c:set_field(g..name,value,n)end
local i=r(c)if i then
u.read_attribute(c,0,32768,i,4117)u.read_attribute(c,0,32800,i,4117)end
for _,p in ipairs{2820,1794}do
u.bind_cluster(c,p,ak.environment_info.hub_zigbee_eui,2)end
for _,d in ipairs(e)do
local v=d.reporting_defaults
if v then
u.configure_reporting(c,{cluster=d.cluster_id,attribute=d.attribute_id,data_type=d.data_type,minimum_interval=v.minimum_interval,maximum_interval=v.maximum_interval,reportable_change=v.reportable_change},2)end
end
end
}ab(Y,{l.create_fingerprint("Develco Products A/S","EMIZB-132"),l.create_fingerprint("frient A/S","EMIZB-132")})u.attach_reporting_capabilities(w,{{1,"rpt-eft"}})return{id="zcl.switches.emizb132",registrations=w}
