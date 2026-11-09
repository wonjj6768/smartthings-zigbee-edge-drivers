local function s(t)
local v,w=require"st.zigbee.cluster_base",require"st.zigbee.data_types"
local function o(a,q,f,r)
if f~=nil and type(q.to_endpoint)=="function"then
q=q:to_endpoint(f)end
if r~=nil and q.address_header and q.address_header.profile then
q.address_header.profile.value=r
end
a:send(q)return true
end
local function d(a,j,g,u,f,r)
return o(a,v.read_manufacturer_specific_attribute(a,j,g,u),f,r)
end
local function k(a,m,f)
return o(a,m:read(a),f)
end
local function n(a,j,g,f)
return o(a,v.read_attribute(a,w.ClusterId(j),w.AttributeId(g)),f)
end
local function h(a,b,l,y)
if type(l)=="table"and l.mapping==b then
return l
end
return t.build_mapping_context(a,b,l,y)
end
local function i(a,b,l)
local c=t.mapping_meta(b)if c==nil or c.cluster_id==nil or c.attribute_id==nil then
return false
end
local e=h(a,b,l,nil)if c.mfg_code~=nil then
return d(a,c.cluster_id,c.attribute_id,c.mfg_code,e.endpoint,c.profile_id)end
if c.attribute_def~=nil and type(c.attribute_def.read)=="function"then
return k(a,c.attribute_def,e.endpoint)end
return n(a,c.cluster_id,c.attribute_id,e.endpoint)
end
function t.read_attribute(a,j,g,f,u)
if u~=nil then
return d(a,j,g,u,f)end
local m=t.get_generated_attribute and t.get_generated_attribute(j,g)or nil
if m~=nil then
return k(a,m,f)end
return n(a,j,g,f)
end
t.read_mapping=i
function t.read_named_attribute(a,p,A,l)
local b=t.find_mapping_by_name(p,A,a,l)if b==nil then
return false
end
local c=t.mapping_meta(b)if c==nil or c.write_only then
return false
end
return i(a,b,t.build_mapping_context(a,b,l,nil))
end
function t.read_all_attributes(a,p)
if p==nil then
return
end
local x={}for _,b in ipairs(p)do
local c=type(b)=="table"and t.mapping_meta(b)or nil
if c~=nil and not c.write_only and c.name~="tuya_magic_packet"and c.read_on_refresh~=false and c.cluster_id~=nil and c.attribute_id~=nil then
local e=t.build_mapping_context(a,b,nil)local z=string.format("%04X:%04X:%s:%s",c.cluster_id,c.attribute_id,tostring(e.endpoint),tostring(c.mfg_code))if not x[z]then
x[z]=true
i(a,b,e)end
end
end
end
return o,h
end
return s
