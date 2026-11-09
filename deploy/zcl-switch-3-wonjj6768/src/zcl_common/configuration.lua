local function z(j)
local D,t,L,x,q,H,m=require"st.zigbee.constants",require"st.zigbee.device_management",require"st.zigbee.cluster_base",require"st.zigbee.data_types",require"zcl_common.reporting",0,{4,0,1,5,7,65534}

function j.attach_reporting_capabilities(J,Q)
return q.attach(j,J,Q)
end
function j.discard_unsupported_reporting(b)
return q.discard_unsupported(j,b)
end
function j.bind_cluster(b,O,T,k)
b:send(t.build_bind_request(b,O,T,k))return true
end
function j.configure_reporting(b,o,k,u)
u=u or{}local e={cluster_id=o.cluster,attribute_id=o.attribute,data_type=o.data_type,endpoint=k,mfg_code=o.mfg_code,reporting_defaults={minimum_interval=o.minimum_interval,maximum_interval=o.maximum_interval,reportable_change=o.reportable_change,key=u.key}}if u.auto_endpoint then e.endpoint=nil end
local S,P=q.configuration(j,b,e)if u.defer_on_override and P then return false end
local l=t.attr_config(b,S or o):to_endpoint(k)if u.disable_default_response then l.body.zcl_header.frame_ctrl:set_disable_default_response()end
b:send(l)return true
end
local B=require"runtime.capability_support".is_callable
local function p(i,c)
if c==nil or(type(i)=="table"and i.is_discrete)then
return nil
end
if type(c)=="function"then
return c
end
if type(i)=="table"and type(c)=="table"and
c.ID==i.ID then
return c
end
if B(i)then
if i.ID==57 then
local U=require"st.buf".Reader
return i.deserialize(U(string.pack("<f",c)))end
return i(c)end
return c
end
local function r(d)
if d.physical_reportable_change~=nil then
return nil
end
local I=d.minimum_interval~=nil or
d.maximum_interval~=nil or
d.reportable_change~=nil
if not I or d.write_only then
return nil
end
if d.cluster_id==nil or d.attribute_id==nil or d.data_type==nil then
return nil
end
return{cluster=d.cluster_id,attribute=d.attribute_id,minimum_interval=d.minimum_interval or 0,maximum_interval=d.maximum_interval or 300,data_type=d.data_type,reportable_change=p(d.data_type,d.reportable_change),mfg_code=d.mfg_code}
end
function j.build_configured_attributes(a)
if type(a)~="table"then
return{}end
local f,A={},{}for _,e in ipairs(a)do
if type(e)=="table"then
local d=j.mapping_meta(e)local s=d and r(d)or nil
if s~=nil then
local G=string.format("%04X:%04X",s.cluster,s.attribute)local n=A[G]if n==nil then
A[G]=#f+1
f[#f+1]=s
elseif f[n].mfg_code==nil and s.mfg_code~=nil then
f[n]=s
end
end
end
end
return f
end
function j.read_configured_attributes(b,a)
if type(a)~="table"then
return false
end
local M,A=false,{}
for _,e in ipairs(a)do
if type(e)=="table"then
local d=j.mapping_meta(e)if d~=nil and d.read_on_configure and not d.write_only and d.name~="tuya_magic_packet"then
local h=j.build_mapping_context(b,e,nil)local G=string.format("%04X:%04X:%s:%s",d.cluster_id,d.attribute_id,tostring(h.endpoint),tostring(d.mfg_code))if not A[G]then
A[G]=true
j.read_mapping(b,e,h)M=true
end
end
end
end
return M
end
local function v(b,a)
if type(a)~="table"then
return false
end
local M,A=false,{}
for _,e in ipairs(a)do
local d=type(e)=="table"and j.mapping_meta(e)or nil
if d~=nil and d.name=="tuya_magic_packet"then
local h=j.build_mapping_context(b,e,nil)local k=h and h.endpoint or nil
local G=tostring(k or"main")if not A[G]then
A[G]=true
local l=L.read_attribute(b,x.ClusterId(H),x.AttributeId(m[1]))l.body.zcl_body.attr_ids={}for _,K in ipairs(m)do
l.body.zcl_body.attr_ids[#l.body.zcl_body.attr_ids+1]=x.AttributeId(K)end
if k~=nil then l=l:to_endpoint(k)end
b:send(l)M=true
end
end
end
return M
end
function j.start_configuration(b,a)
if type(a)~="table"then
return false
end
local g
for _,e in ipairs(a)do
if type(e)=="table"then
local d=j.mapping_meta(e)if d~=nil and d.cluster_id==j.CLUSTER_IAS_ZONE then
g=d.ias_configure_method or D.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE
break
end
end
end
if g~=nil and type(b.set_ias_zone_config_method)=="function"then
b:set_ias_zone_config_method(g)end
local y,f=q.groups(j,b,a),j.build_configured_attributes(a)if #f>0 and type(b.add_configured_attribute)=="function"then
for _,s in ipairs(f)do
if y[string.format("%04x:%04x",s.cluster,s.attribute)]then
b:remove_configured_attribute(s.cluster,s.attribute)else
b:add_configured_attribute(s)end
end
end
local F,E,C,w=v(b,a),j.read_metering_scalers and j.read_metering_scalers(b,a)or false,#f>0 or g~=nil,false


if C and type(b.configure)=="function"then
b:configure()w=true
end
q.send(j,b,a,y,true)local R,N=j.read_configured_attributes(b,a),j.start_runtime and j.start_runtime(b,a)or false
return w or F or E or R or N
end
end
return z
