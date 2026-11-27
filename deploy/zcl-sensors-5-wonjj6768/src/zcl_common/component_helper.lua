local function k(w)
local function r(x)
local t={}if type(x)~="table"then
return t
end
for C,A in pairs(x)do
t[C]=A
end
return t
end
local function m(a)
if type(a)=="number"and a%1==0 and a>0 then
local f={}for c=1,a do
f[#f+1]=c
end
return f
end
if type(a)=="table"then
local f={}for _,c in ipairs(a)do
if type(c)=="number"and c%1==0 and c>0 then
f[#f+1]=c
end
end
return f
end
return{1}
end
function w.build_component_by_endpoint(o,e)
return function(_,_,i)
local c=i and(i.endpoint or i.src_endpoint)or nil
if type(o)~="table"or c==nil then
return e
end
local n=o[c]if type(n)=="string"and n~=""then
return n
end
return e
end
end
function w.build_component_suffix(v,d)
d=d or{}local p,l,s,e,u=type(v)=="string"and v~=""and v or"switch",type(d.main_endpoint)=="number"and d.main_endpoint or 1,type(d.main_component)=="string"and d.main_component~=""and d.main_component or"main",d.default_component,type(d.index_offset)=="number"and d.index_offset or 0


return function(_,_,i)
local c=i and(i.endpoint or i.src_endpoint)or nil
if type(c)~="number"then
return e
end
if c==l then
return s
end
local y=c-l+u
if y<1 then
return e
end
return p..tostring(y)
end
end
local function j(z,a,d)
local f,b=m(a),r(d)local g=b.component
if g==nil then
g=w.build_component_suffix(b.component_prefix or"switch",b)end
b.component_prefix=nil
b.main_component=nil
b.main_endpoint=nil
b.default_component=nil
b.index_offset=nil
b.component=nil
local q={}for _,c in ipairs(f)do
local h=r(b)h.endpoint=c
h.component=g
q[#q+1]=z(h)end
return q
end
function w.multi_switch(a,d)
return j(w.switch,a,d)
end
function w.multi_level(a,d)
return j(w.level,a,d)
end
end
return k
