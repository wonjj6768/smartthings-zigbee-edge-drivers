local function u(A)
local D,q,r,o,k,l,w,v,j=require"st.zigbee.cluster_base",require"st.zigbee.generated.zcl_clusters",{},{},{},{},{},{},{}
local function x(b,G)
return string.format("%04X:%04X",b,G)
end
local function n(b)
local e=r[b]if e~=nil then
return e
end
local a=q.get_cluster_from_id(b)r[b]=a or false
return a
end
local function m(d)
local e=o[d]if e~=nil then
return e
end
local a=q[d]o[d]=a or false
if a~=nil and a~=false and a.ID~=nil then
r[a.ID]=a
end
return a
end
local function C(b,g)
local y=x(b,g)local e=k[y]if e~=nil then
return e
end
local a=n(b)local c
if a~=nil and a~=false then
local B=a.attr_id_map and a.attr_id_map()[g]or nil
if B~=nil and a.server and a.server.attributes then
c=a.server.attributes[B]end
end
k[y]=c or false
return c
end
local function t(d,f)
local y=string.format("%s:%s",tostring(d),tostring(f))local e=l[y]if e~=nil then
return e
end
local c
local a=m(d)if a~=nil and a~=false and a.server and a.server.attributes then
c=a.server.attributes[f]if c~=nil and c~=false and c.ID~=nil then
k[x(a.ID,c.ID)]=c
end
end
l[y]=c or false
return c
end
local function z(b,h,p,F)
local y=x(b,h)local e=F[y]if e~=nil then
return e
end
local a=n(b)local i
if a~=nil and a~=false then
local H=p=="client"and a.client_id_map and a.client_id_map()[h]or p=="server"and a.server_id_map and a.server_id_map()[h]or nil
if H~=nil and a[p]and a[p].commands then
i=a[p].commands[H]end
end
F[y]=i or false
return i
end
function A.get_generated_cluster(b)
local a=n(b)return a~=false and a or nil
end
function A.get_generated_cluster_by_name(d)
local a=m(d)return a~=false and a or nil
end
function A.get_generated_cluster_id(d)
local a=A.get_generated_cluster_by_name(d)return a and a.ID or nil
end
function A.get_generated_attribute(b,g)
local c=C(b,g)return c~=false and c or nil
end
function A.get_generated_attribute_by_name(d,f)
local c=t(d,f)return c~=false and c or nil
end
function A.get_generated_server_command(b,h)
local i=z(b,h,"server",w)return i~=false and i or nil
end
function A.get_generated_client_command(b,h)
local i=z(b,h,"client",v)return i~=false and i or nil
end
function A.build_dynamic_attribute(b,g,s,writable,f,is_complex)
local a=n(b)if a==nil or a==false or type(s)~="table"or s.ID==nil then
return nil
end
local y=table.concat({tostring(b),tostring(g),tostring(s.ID),writable==false and"0"or"1",is_complex==true and"1"or"0",tostring(f or"")},":")local e=j[y]if e~=nil then
return e~=false and e or nil
end
local c=D.build_cluster_attribute(a,g,f or string.format("Attribute%04X",g),s,writable~=false,is_complex==true)j[y]=c or false
return c
end
end
return u
