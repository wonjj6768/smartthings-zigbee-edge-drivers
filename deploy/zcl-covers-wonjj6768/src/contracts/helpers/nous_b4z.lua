local x,t,q,M,m,h=require"protocol.zcl",require"st.zigbee.data_types",require"st.zigbee.cluster_base",{},"__nous_b4z_moves","__nous_b4z_position"
local function l(a)
return a:get_manufacturer()=="_TZ3000_yruungrl"and a:get_model()=="TS130F"
end
function M.apply(n)
for _,c in ipairs(n.zcl_clusters)do
if c.name=="cover_position"or c.name=="window_shade_state"then
local s=c.from_device or(c.converter and c.converter.from)
c.from_device=function(j,a,g,p)
local i=l(a)and a:get_field(h)if i and i.endpoint==g.endpoint then j=i.value end
if s then return s(j,a,g,p)end
return j
end
end
if c.name=="cover_position"then
local v=c.sender or x.get_sender(c.cluster_id,c.attribute_id)
c.sender=function(a,p,j,g)
if l(a)and type(j)=="number"then
local b=a:get_latest_state("main","windowShadeLevel","shadeLevel")if type(b)=="number"then
local f=a:get_field(m)or{}f[g.endpoint]={start=b,target=j}a:set_field(m,f,{persist=false})end
end
return v(a,p,j,g)
end
end
end
n.zigbee_message_handler=function(a,w)
if not l(a)then return end
a:set_field(h,nil,{persist=false})local o=w.body.zcl_header
if w.address_header.cluster.value~=258 or not o
or(o.cmd.value~=10 and o.cmd.value~=1)or o.frame_ctrl:is_cluster_specific_set()then return end
local d,r
for _,k in ipairs(w.body.zcl_body.attr_records or{})do
if k.data then
if k.attr_id.value==8 then d=k.data.value end
if k.attr_id.value==61440 then r=k.data.value end
end
end
if type(d)~="number"or d<0 or d>100 or r==nil then return end
local e,f=w.address_header.src_endpoint.value,a:get_field(m)or{}
local b=f[e]if r~=1 then
if not b or b.target==nil or d==b.target then
f[e]={start=b and b.start or a:get_latest_state("main","windowShadeLevel","shadeLevel"),target=b and b.target,position=d}end
else
f[e]=nil
if b and type(b.position)=="number"and d==b.start and d~=b.position then
a:set_field(h,{endpoint=e,value=b.position},{persist=false})local u=q.write_attribute(a,t.ClusterId(258),t.AttributeId(8),t.Uint8(b.position))pcall(a.send,a,u:to_endpoint(e))end
end
a:set_field(m,f,{persist=false})
end
end
return M
