local aK,r,ac,aY,aQ,bz,bx,d,B,S,C=require"st.capabilities",require"runtime.capability_metadata",require"runtime.capability_support",require"runtime.utf8_text",require"log",require"protocol.tuya",require"protocol.zcl","main","__initialCustomStateQueryRequested","__unknown_profile__",{}local H,Q,as,l=r.numeric,r.enum,r.text,r.driver_message



local au,aW={{kind="numeric",definitions=H},{kind="enum",definitions=Q},{kind="text",definitions=as}},{{kind="numeric",definitions=H},{kind="enum",definitions=Q},{kind="text",definitions=as}}
local function u(b)
if type(b)~="table"then
return"device"end
return b.label or b.id or"device"
end
local function aZ(b)
if type(b)~="table"then
return S
end
local bh=b.profile
local aG=type(bh)=="table"and bh.id or nil
if type(aG)=="string"and aG~=""then
return aG
end
return S
end
local function al(b)
local bo=aZ(b)local bb=C[bo]if bb==nil then
bb={}C[bo]=bb
end
return bb
end
local aP=ac.is_callable
local function aa(j,J)
local D=aK[j]local f=D and D[J]or nil
if not aP(f)and D and type(D.attributes)=="table"then
f=D.attributes[J]end
return D,f
end
local function o(b,c,j)
return ac.supports(b,j,c)
end
local function N(q,bj,aD)
local a=r.by_range_key[bj]if a==nil and type(aD)=="table"then
a={range_key=bj,default_range=aD}end
return r.resolve_range(q,a)
end
local function Y(q,a)
local p=N(q,a.range_key,{allowed_values=a.supported_values})return type(p)=="table"and p.allowed_values or a.supported_values
end
local function ba(i,w,aS)
if type(aS)~="number"or aS<=0 then
return i
end
local bs=type(w)=="number"and w or 0
local br=math.floor(((i-bs)/aS)+0.5)local an,bc=bs+(br*aS),tostring(aS):match"%.(%d+)"if bc~=nil then
an=tonumber(string.format("%."..tostring(#bc).."f",an))end
return an
end
local function ay(i,e)
if type(e)~="table"or #e==0 then
return i
end
local bk
local aI
for _,ab in ipairs(e)do
if type(ab)=="number"then
local bd=math.abs(ab-i)if bk==nil or bd<aI then
bk=ab
aI=bd
end
end
end
return bk or i
end
local function W(k,w,A,aS,e)
if type(k)~="number"then
return nil,false
end
local i=k
if type(w)=="number"and i<w then
i=w
end
if type(A)=="number"and i>A then
i=A
end
i=ba(i,w,aS)i=ay(i,e)return i,i~=k
end
local function ae(k,e)
if type(k)~="string"or k==""then
return nil
end
if type(e)~="table"or e[1]==nil then
return k
end
for _,ab in ipairs(e)do
if k==ab then
return k
end
end
return nil
end
local function aj(a,p)
if type(p)=="table"and type(p.unit)=="string"and p.unit~=""then
return p.unit
end
if type(a)=="table"then
if type(a.event_unit)=="string"and a.event_unit~=""then
return a.event_unit
end
local O=a.default_range
if type(O)=="table"and type(O.unit)=="string"and O.unit~=""then
return O.unit
end
end
return nil
end
local function K(b,c,bn)
c=c or d
if c==d then
b:emit_event(bn)else
b:emit_component_event({id=c},bn)end
end
local function I(Z)
for _,aF in ipairs(au)do
Z(aF.definitions,aF.kind)end
end
local function E(b,x,c,Z)
c=c or d
for _,a in ipairs(x)do
if o(b,c,a.capability_id)then
Z(a,c)end
end
end
local function X(a,w,A)
if type(a)~="table"then
return w,A
end
if type(a.event_minimum)=="number"and(type(w)~="number"or w<a.event_minimum)then
w=a.event_minimum
end
if type(a.event_maximum)=="number"and(type(A)~="number"or A>a.event_maximum)then
A=a.event_maximum
end
if type(w)=="number"and type(A)=="number"and w>A then
w=A
end
return w,A
end
local function aH(b,bq,bw,Z)
if type(Z)~="function"then
return false
end
if b~=nil and b.thread~=nil and type(b.thread.call_with_delay)=="function"then
b.thread:call_with_delay(bq,Z,bw)return true
end
return false
end
local function bt(am)
local aE,bm,ag=assert(am and am.get_preset,"custom capability runtime requires get_preset"),assert(am and am.send,"custom capability runtime requires send"),assert(am and am.resolve_definition,"custom capability runtime requires resolve_definition")
local function G(b,a,aU)
if type(b)~="table"or type(a)~="table"then
return
end
local bj=string.format("__custom_driver_missing__:%s:%s",a.capability_id or"unknown",aU or"unknown")if b.get_field~=nil and b.set_field~=nil and b:get_field(bj)then
return
end
if b.set_field~=nil then
b:set_field(bj,true,{persist=false})end
aQ.error(string.format("[%s] Custom capability driver binding missing (%s): %s.%s",u(b),aU or"unknown",a.capability_id or"unknown",a.attribute_name or"unknown"))
end
local function g(b,a,J,bg)
local D,f=aa(a.capability_id,J)if aP(f)then
return f
end
if bg then
if D==nil then
G(b,a,"capability")else
G(b,a,"attribute")end
end
return nil
end
local function U(b,q,a,c,aD)
local aJ
local n=aE(b)if n~=nil and type(n.zcl_clusters)=="table"and type(a.mapping_name)=="string"and a.mapping_name~=""then
local m=bx.find_mapping_by_name(n.zcl_clusters,a.mapping_name,b,{component_id=c or d})if type(m)=="table"and type(m.numeric_range)=="table"then
aJ=m.numeric_range
end
end
local p=N(q,a.range_key,aD or aJ or a.default_range)if type(p)~="table"then
return nil
end
p.minimum,p.maximum=X(a,p.minimum,p.maximum)return p
end
local function ap(b,c,v)
local n=aE(b)local be=n
and(n.named_mappings_by_name or n.named_mappings or n.datapoints)local m=be and be[v]if m==nil and n and n.datapoints then
m=bz.build_named_map(n.datapoints,"name")[v]end
if m==nil and n and n.zcl_clusters then
m=bx.find_mapping_by_name(n.zcl_clusters,v,b,{component_id=c or d})end
if m==nil and n and n.protocol_writers then
m=n.protocol_writers[v]end
return m
end
local function F(b,c,v)
local m=ap(b,c,v)return type(m)=="table"and m.suppress_optimistic_state==true
end
local function at(b,c,a)
return not F(b,c,a.mapping_name)and b:get_latest_state(c,a.capability_id,a.attribute_name)==nil
end
local function h(b,aX)
if type(aX)~="string"or aX==""then
return
end
if not o(b,d,l.capability_id)then
return
end
local f=g(b,l,l.attribute_name,true)if f==nil then
return
end
local L=l.maximum_length or 512
local s=aY.truncate(aX,L)if s==nil then
return
end
aQ.info(string.format("[%s] Driver message emit requested: %s",u(b),s))K(b,d,f{value=s})
end
local function ak(b,c,a,i,bv)
if type(a)~="table"or type(a.attribute_name)~="string"or i==nil then
return
end
local f=g(b,a,a.attribute_name,true)if f==nil then
return
end
local aM=bv~=nil and{value=i,unit=bv}or{value=i}aQ.info(string.format("[%s] Custom numeric emit requested: %s=%s",u(b),a.capability_id,tostring(i)))K(b,c,f(aM))
end
local function aw(b,c,a,i)
if type(a)~="table"or type(a.attribute_name)~="string"or type(i)~="string"or i==""then
return
end
local f=g(b,a,a.attribute_name,true)if f==nil then
return
end
aQ.info(string.format("[%s] Custom enum emit requested: %s=%s",u(b),a.capability_id,tostring(i)))K(b,c,f{value=i})
end
local function ax(b,c,a,i)
if type(a)~="table"or type(a.attribute_name)~="string"or type(i)~="string"then
return
end
local f=g(b,a,a.attribute_name,true)if f==nil then
return
end
aQ.info(string.format("[%s] Custom text emit requested: %s=%s",u(b),a.capability_id,i))K(b,c,f{value=i})
end
local function af(b)
if type(b)~="table"then
return
end
local P=al(b)if P.__complete==true then
return
end
local bu,ad={},false
local function bi(j)
if type(j)~="string"or j==""or bu[j]then
return
end
if not o(b,d,j)then
return
end
if P[j]==true then
return
end
bu[j]=true
local ok,bA=pcall(aK.get_capability_definition,j,1,true)if not ok then
ad=true
aQ.warn(string.format("[%s] Failed to refresh capability definition for %s: %s",u(b),j,tostring(bA)))return
end
P[j]=true
end
I(function(x)
for _,a in ipairs(x)do
bi(a.capability_id)end
end)
bi(l.capability_id)if not ad then
P.__complete=true
end
end
local function az(b,q)
E(b,H,d,function(a)
local p,av=U(b,q,a,d),g(b,a,a.range_attribute_name,false)if p~=nil and av~=nil then
local aM={value={minimum=p.minimum,maximum=p.maximum,step=p.step}}if p.unit~=nil then
aM.unit=p.unit
end
K(b,d,av(aM))end
end)
end
local function aL(b,q)
E(b,Q,d,function(a)
local f,e=g(b,a,a.supported_attribute_name,false),Y(q,a)if f~=nil and type(e)=="table"and e[1]~=nil then
K(b,d,f{value=e})end
end)
end
local function aN(b)
if type(b)~="table"then
return
end
local function aq(a,c)
c=c or d
if not o(b,c,a.capability_id)then
return
end
local f=g(b,a,a.attribute_name,true)if f==nil then
return
end
aQ.info(string.format("[%s] Custom capability ready: %s.%s",u(b),a.capability_id,a.attribute_name))
end
I(function(x)
for _,a in ipairs(x)do
aq(a)end
end)
aq(l)
end
local function ai(b,x)
for _,a in ipairs(x)do
if o(b,d,a.capability_id)and at(b,d,a)then
return true
end
end
return false
end
local function V(b)
for _,aF in ipairs(au)do
if ai(b,aF.definitions)then
return true
end
end
return false
end
local function M(b,n)
if n==nil or n.datapoints==nil then
return false
end
if n.initial_custom_state_query==false then
return false
end
if not V(b)then
return false
end
if b:get_field(B)then
return false
end
b:set_field(B,true,{persist=false})h(b,"Initial custom state query requested.")
if aH(b,2,"initial custom state query",function()
n:send_state_request(b)h(b,"Initial custom state query sent.")
end)then
return true
end
n:send_state_request(b)h(b,"Initial custom state query sent.")return true
end
local function R(b,c,v,i)
local n=aE(b)local aT=n and n.datapoints or nil
if type(aT)~="table"then
return i
end
local ah=c or d
for _,m in ipairs(aT)do
if type(m)=="table"and(m.name==v or m.key==v)and(m.component==nil or m.component==ah)and type(m.optimistic_value)=="function"then
local ok,bf=pcall(m.optimistic_value,i,b,{component_id=ah,mapping=m})if ok and type(bf)=="number"then
return bf
end
return i
end
end
return i
end
local function y(b,a,aU)
h(b,string.format("%s %s No change applied.",a.label,aU))
end
local function ar(t,a)
t[a.capability_id]=t[a.capability_id]or{}
t[a.capability_id][a.command_name]=function(_,b,z)
local c=z.component or d
if not ap(b,c,a.mapping_name)then
y(b,a,"is not supported by this device.")return
end
local k,q=z.args and z.args[a.argument_name]or nil,ag(b)
local p=U(b,q,a,c)local s,an=W(k,p and p.minimum or nil,p and p.maximum or nil,p and p.step or nil,p and p.allowed_values or nil)if s==nil then
y(b,a,"value is invalid.")return
end
if an then
h(b,string.format("%s adjusted from %s to %s.",a.label,tostring(k),tostring(s)))end
local aC,T=pcall(bm,b,z,a.mapping_name,s)if not aC then
y(b,a,"command failed.")aQ.error(string.format("[%s] Failed to send %s: %s",u(b),a.capability_id,tostring(T)))return
end
if not T then
y(b,a,"is not supported by this device.")return
end
if F(b,c,a.mapping_name)then
return
end
local aR=R(b,c,a.mapping_name,s)ak(b,c,a,aR,aj(a,p))
end
end
local function aA(t,a)
t[a.capability_id]=t[a.capability_id]or{}
t[a.capability_id][a.command_name]=function(_,b,z)
local q,k=ag(b),z.args and z.args[a.argument_name]or nil
local e=Y(q,a)local s=ae(k,e)if s==nil then
local aV=type(e)=="table"and table.concat(e,", ")or"none"h(b,string.format("%s value is invalid. Supported values: %s.",a.label,aV))return
end
local aC,T=pcall(bm,b,z,a.mapping_name,s)if not aC then
h(b,string.format("%s command failed. No change applied.",a.label))aQ.error(string.format("[%s] Failed to send %s: %s",u(b),a.capability_id,tostring(T)))return
end
if not T then
h(b,string.format("%s is not supported by this device. No change applied.",a.label))return
end
local c=z.component or d
if F(b,c,a.mapping_name)then
return
end
aw(b,c,a,s)
end
end
local function aB(t,a)
t[a.capability_id]=t[a.capability_id]or{}
t[a.capability_id][a.command_name]=function(_,b,z)
local c,k=z.component or d,z.args and z.args[a.argument_name]or nil

if type(k)~="string"then
return
end
local L,ao=a.maximum_length,aY.length(k)
if ao==nil
or(type(L)=="number"and ao>L)then
return
end
if not ap(b,c,a.mapping_name)then
return
end
local aC,T=pcall(bm,b,z,a.mapping_name,k)if not aC then
aQ.error(string.format("[%s] Failed to send %s: %s",u(b),a.capability_id,tostring(T)))return
end
if not T then
return
end
if F(b,c,a.mapping_name)then
return
end
ax(b,c,a,k)
end
end
local function aO(t)
for _,aF in ipairs(aW)do
local x,bl=aF.definitions,aF.kind

for _,a in ipairs(x)do
if type(a.command_name)=="string"and a.command_name~=""and type(a.mapping_name)=="string"and a.mapping_name~=""then
if bl=="numeric"then
ar(t,a)elseif bl=="enum"then
aA(t,a)elseif bl=="text"then
aB(t,a)end
end
end
end
end
return{diagnose_bindings=aN,emit_driver_message=h,emit_enum_metadata=aL,emit_numeric_metadata=az,maybe_request_initial_custom_state=M,refresh_definitions=af,register_handlers=aO}
end
return{create=bt}
