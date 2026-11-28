local w,n,f,x,u=require"protocol.zcl",require"capabilities.events.all",require"st.zigbee.data_types",require"st.buf",{}
local function j(g)
if type(g)=="table"then g=g.value end
if type(g)~="string"then return nil end
local l,a=x.Reader(g),{}while l:remain()>1 do
local v,t=l:read_u8(),l:read_u8()local z,q=pcall(f.parse_data_type,t,l)if not z then return nil end
if v>=149 and v<=152 and type(q.value)=="number"then
a[v]=q.value
end
end
return a
end
local function r(c)
return function(d,a)
local h={}
local function i(k)
if type(k)=="table"and k[1]~=nil then
for _,q in ipairs(k)do h[#h+1]=q end
elseif k~=nil then
h[#h+1]=k
end
end
if a[149]~=nil then i(n.energy()(d,a[149]))end
if a[150]~=nil then i(n.voltage()(d,a[150]/10))end
if c and a[151]~=nil then i(n.current()(d,a[151]/1000))end
if a[152]~=nil then i(n.power()(d,a[152]))end
return h
end
end
function u.adapt(o,c,s)
local e,b={},{}for y,g in pairs(o)do e[y]=g end
for _,p in ipairs(o.zcl_clusters)do
if p.metering_kind==nil then b[#b+1]=p end
end
b[#b+1]=w.cluster_attribute(12,85,{name="power",data_type=f.SinglePrecisionFloat,component="main",emit=n.power(),read_only=true,
endpoint=function(d)return d:get_endpoint(12)end,
read_on_configure=true,poll_interval=300,metering_kind="power",ignore_reported_scaler=true})for _,m in ipairs{{0,65281},{64704,247}}do
b[#b+1]=w.cluster_attribute(m[1],m[2],{name="lumi_metering",data_type=f.OctetString,endpoint=1,component="main",read_only=true,read_on_configure=false,read_on_refresh=false,from_device=j,emit=r(c),
handler=function(d,a)
if a[152]~=nil then
w.handle_metering_value(d,nil,a[152],{metering_kind="power"})end
end
})end
e.profile=s
e.zcl_clusters=b
return e
end
return u
