local t={}
local function n(M,c,A)
c=c or"mapping list"local N={}if type(M)~="table"then
error(string.format("%s must be a table",c))end
local j,m=0,0

for z in pairs(M)do
if type(z)=="number"then
if z<1 or z%1~=0 then
error(string.format("%s has invalid numeric index %s",c,tostring(z)))end
j=math.max(j,z)m=m+1
elseif not A then
error(string.format("%s has unexpected named field %s",c,tostring(z)))end
end
if j~=m then
error(string.format("%s must be a dense list (highest index %d, entries %d)",c,j,m))end
for I=1,j do
N[I]=M[I]end
return N
end
local function s(D,H)
D=D or{}for _,a in ipairs(H)do
D[#D+1]=a
end
return D
end
local function G(J)
if type(J)~="table"then
return false
end
for z in pairs(J)do
if type(z)~="number"then
return true
end
end
return false
end
local function h(H,c)
c=c or"mapping list"local e,d,l={},{},{}for I,a in ipairs(H)do
local Q=type(a)=="table"and a.cluster_id~=nil and(a.attribute_id~=nil or
(a.write_only==true and type(a.sender)=="function")or
(a.read_only==true and a.command_id~=nil and type(a.command_extractor)=="function"))local B=type(a)=="table"and a.dp~=nil and a.datatype~=nil
if Q and B then
error(string.format("%s[%d] mixes datapoint and ZCL fields",c,I))elseif Q then
d[#d+1]=a
elseif B then
e[#e+1]=a
else
l[#l+1]=a
end
end
return e,d,l
end
local function f(c,T,V)
error(string.format("%s contains %d %s mapping(s)",c,T,V))
end
local function o(b)
local a={}for z,J in pairs(b)do
if type(z)~="number"and z~="fingerprints"then
a[z]=J
end
end
local profile=tostring(a.profile)local N=n(b,"family profile "..profile,true)local e,d,l=h(N,"family profile "..profile)if #l>0 then
f("family profile "..profile,#l,"unknown indexed")end
local function i(v,x)
local K=a[v]if K==nil then
return
end
local c=string.format("family profile %s %s",profile,v)local R=n(K,c,false)local F,P,y=h(R,c)if #y>0 then
f(c,#y,"incomplete or nested")end
local u=x=="datapoint"and P or F
if #u>0 then
local O=x=="datapoint"and"ZCL"or"datapoint"f(c,#u,O)end
a[v]=R
end
i("datapoints","datapoint")i("zcl_clusters","zcl")if #e>0 then
a.datapoints=s(a.datapoints,e)end
if #d>0 then
a.zcl_clusters=s(a.zcl_clusters,d)end
return a
end
function t.create_fingerprint(g,w)
return{manufacturer=g,model=w}
end
function t.create_fingerprints(w,C)
local q={}for _,g in ipairs(C)do
local r,model=string.match(g,"^(.-):(.+)$")if r==nil then
r,model=g,w
end
q[#q+1]=t.create_fingerprint(r,model)end
return q
end
function t.definition_registry()
local k={}
local function p(b,E)
local a
if G(b)then
a=o(b)else
local L=n(b,"device definition",true)local e,d,l=h(L,"device definition")if #l>0 then
f("device definition",#l,"incomplete or nested")end
a={}if #e>0 then
a.datapoints=e
end
if #d>0 then
a.zcl_clusters=d
end
end
a.fingerprints=E
k[#k+1]=a
end
return k,p
end
return t
