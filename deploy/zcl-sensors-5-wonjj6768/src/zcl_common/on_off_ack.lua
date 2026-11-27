local d,g={},"__zcl_pending_on_off"
function d.get(b,c)
if type(b.get_field)~="function"then return nil end
local a=b:get_field(g)return a and a[c]or nil
end
function d.clear(b,c)
if c==nil or type(b.get_field)~="function"then return end
local a=b:get_field(g)if a~=nil then
a[c]=nil
b:set_field(g,next(a)and a or nil,{persist=false})end
end
function d.remember(b,j,h,i)
if type(b.get_field)~="function"or type(b.set_field)~="function"then return end
local f=h and h.mapping
if f==nil or f.name~="switch"or f.write_only==true or f.mfg_code~=nil then return end
local e=i.address_header
local c=e and e.dest_endpoint and e.dest_endpoint.value or h.endpoint
if c==nil then return end
local a=b:get_field(g)or{}a[c]={mapping=f,command=j and 1 or 0,profile=e and e.profile and e.profile.value}b:set_field(g,a,{persist=false})
end
return d
